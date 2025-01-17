<div align='center'>

# Merging Models on the Fly Without Retraining: A Sequential Approach to Scalable Continual Model Merging

[![arXiv](https://img.shields.io/badge/arXiv-2501.09522-b31b1b.svg)](https://arxiv.org/abs/2501.09522)

</div>

## Abstract

Deep model merging represents an emerging research direction that combines multiple fine-tuned models to harness their specialized capabilities across different tasks and domains. Current model merging techniques focus on merging all available models simultaneously, with weight interpolation-based methods being the predominant approaches. However, these conventional approaches are not well-suited for scenarios where models become available sequentially, and they often suffer from high memory requirements and potential interference between tasks. In this study, we propose a training-free projection-based continual merging method that processes models sequentially through orthogonal projections of weight matrices and adaptive scaling mechanisms. Our method operates by projecting new parameter updates onto subspaces orthogonal to existing merged parameter updates while using an adaptive scaling mechanism to maintain stable parameter distances, enabling efficient sequential integration of task-specific knowledge. Our approach maintains constant memory complexity to the number of models, minimizes interference between tasks through orthogonal projections, and retains the performance of previously merged models through adaptive task vector scaling. Extensive experiments on CLIP-ViT models demonstrate that our method achieves a 5-8% average accuracy improvement while maintaining robust performance in different task orderings.

## Installation

install the latest version in development

```bash
pip install -e . # install the package in editable mode
```

## Project Structure

The project is structured as follows:

- `fusion_bench/`: the main package of the benchmark.
  - `method`: contains the implementation of the fusion methods.
    > **naming convention**: `fusion_bench/method/{method_name}/{variant}.py` contains the implementation of the specific method or its variants.
      For example, `fusion_bench/method/regmean/clip_regmean.py` contains the implementation of the RegMean algorithm for CLIP vision models.
  - `modelpool`: contains the implementation of the model pool, responsible for managing the models and dataset to be loaded.
  - `taskpool`: contains the implementation of the task pool, responsible for evaluating the performance of models returned by the algorithm.
- `config/`: configuration files for the benchmark. We use [Hydra](https://hydra.cc/) to manage the configurations.
  - `method`: configuration files for the fusion methods.
    > **naming convention**: `config/method/{method_name}/{variant}.yaml` contains the configuration for the specific method or its variants.
  - `modelpool`: configuration files for the model pool.
  - `taskpool`: configuration files for the task pool.
  - `model`: configuration files for the models.
  - `dataset`: configuration files for the datasets.
- `examples/`: example scripts for running some of the experiments.
  > **naming convention**: `examples/{method_name}/` contains the files such as bash scripts and jupyter notebooks for the specific method.
- `tests/`: unit tests for the benchmark.

## How to run the experiments

The experiments are conducted on the CLIP-ViT models.
The bash scripts to run the experiments are in the [`examples/opcm`](examples/opcm) folder.
