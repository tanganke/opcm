import functools
import logging
from functools import cached_property
from typing import Optional

from omegaconf import DictConfig, open_dict
from torch.utils.data import DataLoader
from transformers import CLIPModel, CLIPProcessor, CLIPVisionModel

from fusion_bench.dataset import CLIPDataset, load_dataset_from_config
from fusion_bench.utils import timeit_context

from .base_pool import ModelPool

log = logging.getLogger(__name__)


class HuggingFaceClipVisionPool(ModelPool):
    """
    A model pool for managing Hugging Face's CLIP Vision models.

    This class extends the base `ModelPool` class and overrides its methods to handle
    the specifics of the CLIP Vision models provided by the Hugging Face Transformers library.
    """

    def __init__(self, modelpool_config: DictConfig):
        super().__init__(modelpool_config)

        self._clip_processor = None

    @property
    def clip_processor(self):
        if self._clip_processor is None:
            self._clip_processor = CLIPProcessor.from_pretrained(
                self.get_model_config("_pretrained_")["path"]
            )
        return self._clip_processor

    def load_model(self, model_config: str | DictConfig) -> CLIPVisionModel:
        """
        Load a CLIP Vision model from the given configuration.

        Args:
            model_config (str | DictConfig): The configuration for the model to load.

        Returns:
            CLIPVisionModel: The loaded CLIP Vision model.
        """
        if isinstance(model_config, str):
            model_config = self.get_model_config(model_config)

        with timeit_context(
            f"Loading CLIP vision model: '{model_config.name}' from '{model_config.path}'."
        ):
            vision_model = CLIPVisionModel.from_pretrained(model_config.path)
        return vision_model

    def get_tta_dataset_config(self, task: str):
        for task_config in self.config.tta_datasets:
            if task_config.name == task:
                return task_config
        raise ValueError(f"Task {task} not found in config")

    def prepare_dataset_config(self, dataset_config: DictConfig):
        if not hasattr(dataset_config, "type"):
            with open_dict(dataset_config):
                dataset_config["type"] = self.config.dataset_type
        return dataset_config

    @functools.cache
    def get_tta_test_dataset(
        self, tta_dataset: str, clip_processor: Optional[CLIPProcessor] = None
    ):
        """
        Load the test dataset for the task.
        This method is cached, so the dataset is loaded only once.
        """
        if clip_processor is None:
            # if clip_processor is not provided, try to load the clip_processor from pre-trained model
            clip_processor = self.clip_processor
        dataset_config = self.get_tta_dataset_config(tta_dataset)["dataset"]
        dataset_config = self.prepare_dataset_config(dataset_config)
        with timeit_context(f"Loading test dataset: {dataset_config.name}"):
            dataset = load_dataset_from_config(dataset_config)
        dataset = CLIPDataset(dataset, self.clip_processor)
        return dataset
