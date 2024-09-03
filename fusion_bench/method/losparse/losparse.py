import gc
import logging
from typing import Dict, List, Literal, Optional, Tuple, Union, cast

import lightning as L
import torch
import torch.utils.hooks
from accelerate import init_empty_weights
from torch import Tensor, nn
from tqdm.auto import tqdm
from transformers import LlamaForCausalLM
from typing_extensions import override

from fusion_bench.method import BaseModelFusionAlgorithm
from fusion_bench.method.pruning.prune_utils import (
    PruningType,
    find_linear_layers,
    semistructured_magnitude_prune_,
    unstructured_magnitude_prune_,
)
from fusion_bench.method.pruning.wanda_utils.data import get_loaders
from fusion_bench.method.pruning.wanda_utils.prune import prepare_calibration_input
from fusion_bench.mixins import SimpleProfilerMixin
from fusion_bench.modelpool import CausalLMPool
from fusion_bench.models.utils import get_attr, set_attr
from fusion_bench.utils import timeit_context
from fusion_bench.utils.devices import get_device

from .modeling_losparse_llama import LoSparseLlamaConfig, LoSparseLlamaForCausalLM
from .modeling_losparse_llama.losparse_linear import LoSparseLinear

log = logging.getLogger(__name__)


def convert_to_losparse_llama(model: LlamaForCausalLM, *, rank: int):
    config = model.config
    new_config = LoSparseLlamaConfig(rank=rank, **config.to_dict())

    with init_empty_weights():
        new_model = LoSparseLlamaForCausalLM(new_config)
    new_model.to(dtype=model.dtype)
    if hasattr(model, "hf_device_map"):
        new_model.hf_device_map = model.hf_device_map
        for k, v in model.hf_device_map.items():
            new_model.get_submodule(k).to_empty(device=v)
    else:
        new_model.to_empty(device=get_device(model))
    result = new_model.load_state_dict(model.state_dict(), strict=False)
    assert (
        len(result.unexpected_keys) == 0
    ), f"Unexpected keys: {result.unexpected_keys}"
    return new_model


@torch.no_grad()
def extract_low_rank_part_(linear: LoSparseLinear, rank: int):
    assert isinstance(
        linear, LoSparseLinear
    ), f"Expected LoSparseLinear, got {type(linear)}"

    u, s, vh = cast(
        Tuple[Tensor, Tensor, Tensor],
        torch.linalg.svd(linear.weight.float(), full_matrices=False),
    )
    v = vh.T
    uk = u[:, :rank]
    sk = s[:rank]
    vk = v[:, :rank]
    linear.lo_B.data = (uk * sk).to(linear.lo_B.dtype)
    linear.lo_A.data = vk.T.to(linear.lo_A.dtype)
    linear.weight.data = (linear.weight - linear.lo_B @ linear.lo_A).to(
        linear.weight.dtype
    )
    return linear


class WandaHookFn:
    R"""
    Here in this class, the `scalar_row` is the mean of the squared sum of the input to the linear layer along a specific input dimension.

    $$\frac{\sum_{i=1}^{N L} X_{ij}^2}{N L}$$
    """

    def __init__(self, linear: nn.Linear):
        self.linear = linear
        self.scalar_row = torch.zeros(
            (linear.weight.size(1),), device=linear.weight.device
        )
        self.nsamples = 0

    def compute(self):
        return torch.abs(self.linear.weight) * torch.sqrt(
            self.scalar_row.reshape(1, -1)
        )

    def __call__(self, linear: nn.Linear, inp: Tensor, out: Tensor):
        if len(inp.shape) == 2:
            inp = inp.unsqueeze(0)

        batch_size = inp.shape[0]
        if len(inp.shape) == 3:
            inp = inp.reshape((-1, inp.shape[-1]))
        # (NxL, C) -> (C, NxL)
        inp = inp.t()

        self.scalar_row *= self.nsamples / (self.nsamples + batch_size)
        self.nsamples += batch_size

        inp = inp.type(torch.float32)
        self.scalar_row += torch.norm(inp, p=2, dim=1) ** 2 / self.nsamples


class LoSparseForLlama(BaseModelFusionAlgorithm, SimpleProfilerMixin):
    _config_mapping = BaseModelFusionAlgorithm._config_mapping | {
        "nsamples": "nsamples",
        "seed": "seed",
        "rank": "rank",
        "sparsity_ratio": "sparsity_ratio",
        "prune_type": "prune_type",
        "n": "n",
        "m": "m",
        "device": "device",
        "variant": "variant",
    }

    def __init__(
        self,
        *,
        nsamples: int,
        variant: Literal["wanda"],
        seed: int,
        rank: int,
        sparsity_ratio: float,
        prune_type: PruningType,
        n: int,
        m: int,
        device: Optional[str] = None,
        **kwargs,
    ):
        super().__init__(**kwargs)
        self.nsamples = nsamples
        self.variant = variant
        self.seed = seed
        self.rank = rank
        self.sparsity_ratio = sparsity_ratio
        self.prune_type = prune_type
        self.device = device
        self.n = n
        self.m = m

    @override
    def run(self, modelpool: CausalLMPool):
        if self.seed is not None:
            L.seed_everything(self.seed)

        # load pre-trained model or the first model in the pool
        with self.profile("load_model"):
            model = modelpool.load_pretrained_or_first_model()
            model.seqlen = model.config.max_position_embeddings
            tokenizer = modelpool.load_tokenizer(use_fast=False)

        if not isinstance(model, (LlamaForCausalLM,)):
            log.warning(f"Model type {type(model)} may not supported.")

        with timeit_context("loading calibdation data"):
            dataloader, _ = get_loaders(
                "c4",
                nsamples=self.nsamples,
                seed=self.seed,
                seqlen=model.seqlen,
                tokenizer=tokenizer,
            )

        with torch.no_grad():
            # collect input to the first layer
            inps, outs, attention_mask, position_ids = prepare_calibration_input(
                model, dataloader, self.device
            )

        model = convert_to_losparse_llama(model, rank=self.rank)
        gc.collect()
        if torch.cuda.is_available():
            torch.cuda.empty_cache()

        for layer in tqdm(list(model.model.layers), "Extract Low-Rank Parts (Layers)"):
            for losparse_linear in layer.modules():
                if isinstance(losparse_linear, LoSparseLinear):
                    if self.device is not None:
                        original_device = get_device(losparse_linear)
                        losparse_linear.to(self.device)
                    extract_low_rank_part_(losparse_linear, self.rank)
                    if self.device is not None:
                        losparse_linear.to(original_device)

        # compute importance scores and prune
        layers = model.model.layers
        for layer_idx, layer in tqdm(
            enumerate(layers), "Pruning Layers", total=len(layers)
        ):
            if (
                hasattr(model, "hf_device_map")
                and f"model.layers.{layer_idx}" in model.hf_device_map
            ):  ## handle the case for llama-30B and llama-65B, when the device map has multiple GPUs;
                dev = model.hf_device_map[f"model.layers.{layer_idx}"]
                inps, outs, attention_mask, position_ids = (
                    inps.to(dev),
                    outs.to(dev),
                    attention_mask.to(dev) if attention_mask is not None else None,
                    position_ids.to(dev) if position_ids is not None else None,
                )

            # collect the importance scores
            linear_layers = cast(
                Dict[str, LoSparseLinear],
                find_linear_layers(layer, layers=[LoSparseLinear]),
            )

            # register hooks to collect the importance scores
            def get_hook_fn(linear: LoSparseLinear):
                if self.variant == "wanda":
                    hook_fn = WandaHookFn(linear)
                else:
                    raise ValueError(f"Invalid variant: {self.variant}")
                return hook_fn

            hooks = {}
            handles: List[torch.utils.hooks.RemovableHandle] = []
            for name, linear in linear_layers.items():
                hook_fn = get_hook_fn(linear)
                hooks[name] = hook_fn
                handles.append(linear.register_forward_hook(hook_fn))

            with torch.no_grad():
                for j in range(self.nsamples):
                    outs[j] = layer(
                        inps[j].unsqueeze(0),
                        attention_mask=attention_mask,
                        position_ids=position_ids,
                    )[0]

            # compute the importance scores and remove the hooks
            metrics = {}
            for name, hook in hooks.items():
                metrics[name] = hook.compute()
            for h in handles:
                h.remove()

            # prune the weights based on the importance scores
            if self.prune_type == PruningType.UNSTRUCTURED:
                for name, linear in linear_layers.items():
                    print(f"Pruning {name}")
                    unstructured_magnitude_prune_(
                        linear.weight,
                        metrics[name],
                        sparsity_ratio=self.sparsity_ratio,
                    )
            elif self.prune_type == PruningType.SEMISTRUCTURED:
                for name, linear in linear_layers.items():
                    print(f"Pruning {name}")
                    semistructured_magnitude_prune_(
                        linear.weight,
                        metrics[name],
                        n=self.n,
                        m=self.m,
                    )
            else:
                raise ValueError(f"Invalid pruning type: {self.prune_type}")

            # compute the input to the next layer
            with torch.no_grad():
                for j in range(self.nsamples):
                    outs[j] = layer(
                        inps[j].unsqueeze(0),
                        attention_mask=attention_mask,
                        position_ids=position_ids,
                    )[0]
            inps, outs = outs, inps

        return model
