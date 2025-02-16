"""
Example:

```bash
fusion_bench \
    method=task_singular_vector/TaskSingularVectorMerging \
    modelpool=CLIPVisionModelPool/clip-vit-base-patch32_TALL20_model_only \
    taskpool=CLIPVisionModelTaskPool/clip-vit-classification_TALL20
```
"""

from typing import List, Optional

import torch
from torch import Tensor, nn

from fusion_bench import BaseAlgorithm
from fusion_bench.mixins import LightningFabricMixin
from fusion_bench.utils import timeit_context
from fusion_bench.utils.state_dict_arithmetic import state_dict_sub, state_dict_add
from fusion_bench.utils.type import StateDictType

from .utils import (
    TSVM_utils,
    check_parameterNamesMatch,
    check_state_dicts_equal,
    state_dict_to_vector,
    vector_to_state_dict,
)


class TaskSingularVectorMerging(BaseAlgorithm, LightningFabricMixin):

    def __init__(
        self,
        remove_keys: Optional[List[str]] = None,
        **kwargs,
    ):
        self.remove_keys = remove_keys if remove_keys is not None else []
        super().__init__(**kwargs)

    def run(self, modelpool):
        # Load the pre-trained model and the fine-tuned models
        pretrained_model = modelpool.load_pretrained_model()
        finetuned_models = list(modelpool.models())

        ptm_check = pretrained_model.state_dict()
        ft_checks = [model.state_dict() for model in finetuned_models]
        check_parameterNamesMatch(ft_checks + [ptm_check])

        with timeit_context("Flattening out Checkpoints"):
            task_vectors = [state_dict_sub(check, ptm_check) for check in ft_checks]

        new_merged_tv = TSVM_utils.compute_and_sum_svd_mem_reduction(
            task_vectors,
            exclude_keys=self.remove_keys,
            accelerator=self.fabric.device,
        )

        pretrained_model.load_state_dict(
            state_dict_add(new_merged_tv, pretrained_model.state_dict())
        )
        return pretrained_model
