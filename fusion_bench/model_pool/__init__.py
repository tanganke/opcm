from omegaconf import DictConfig
from .huggingface_clip_vision import HuggingFaceClipVisionPool


def load_model_pool(config: DictConfig):
    if hasattr(config, "type"):
        if config.type == "huggingface_clip_vision":
            return HuggingFaceClipVisionPool(config)
        else:
            raise ValueError(f"Unknown model pool type: {config.type}")
    else:
        raise ValueError("Model pool type not specified")
