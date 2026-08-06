---
layout: default
title: CUDA to Intel XPU Command Comparison
description: Practical equivalents for common NVIDIA CUDA and Intel XPU workflows.
nav_order: 1
---

# CUDA and Intel XPU Command Comparison

* TOC
{:toc}

Practical equivalents for common NVIDIA CUDA and Intel XPU workflows.

> **Verified:** August 6, 2026  
> **Note:** Some commands are practical equivalents rather than exact one-to-one mappings.

## Device Selection

| Task | CUDA | Intel XPU |
|---|---|---|
| Select device ordinal 7 | `CUDA_VISIBLE_DEVICES=7` | `ZE_AFFINITY_MASK=7 ONEAPI_DEVICE_SELECTOR=level_zero:gpu` |
| Select device ordinals 3 and 7 | `CUDA_VISIBLE_DEVICES=3,7` | `ZE_AFFINITY_MASK=3,7 ONEAPI_DEVICE_SELECTOR=level_zero:gpu` |
| Select SYCL Level Zero device 7 | — | `ONEAPI_DEVICE_SELECTOR=level_zero:7` |

`ZE_AFFINITY_MASK` and `ONEAPI_DEVICE_SELECTOR` can be used together:

```bash
ZE_AFFINITY_MASK=7 \
ONEAPI_DEVICE_SELECTOR=level_zero:gpu \
python app.py
```

- `ZE_AFFINITY_MASK=7` limits the devices exposed by the Level Zero driver.
- `ONEAPI_DEVICE_SELECTOR=level_zero:gpu` keeps GPU devices from the Level Zero backend at the SYCL layer.
- When only one device remains visible, it normally appears as logical device `xpu:0` inside PyTorch.
- The meaning of ordinal `7` may depend on the device hierarchy. Check the mapping with `sycl-ls` and `xpu-smi --list-gpus`.

The following syntax is invalid:

```bash
# Invalid
ONEAPI_DEVICE_SELECTOR=level_zero:gpu:7
```

Use one of these instead:

```bash
# Select all Level Zero GPUs
ONEAPI_DEVICE_SELECTOR=level_zero:gpu

# Select Level Zero device index 7
ONEAPI_DEVICE_SELECTOR=level_zero:7
```

## Device Information and Monitoring

| Task | NVIDIA GPU | Intel XPU |
|---|---|---|
| Show GPU status | `nvidia-smi` | `xpu-smi` |
| List GPUs | `nvidia-smi -L` | `sudo xpu-smi discovery` |
| Show GPU processes | `nvidia-smi pmon` | `xpu-smi ps` |
| Show topology matrix | `nvidia-smi topo -m` | `xpu-smi topology -m` |
| List SYCL-visible devices | — | `sycl-ls` |

> **Note:** `nvidia-smi pmon` periodically reports per-process monitoring data.
> `xpu-smi ps` lists processes and their GPU memory usage, so it is the closest
> simple equivalent rather than an exact match.

## PyTorch Installation
```bash
uv pip install torch torchvision torchaudio --index-url https://download.pytorch.org/whl/xpu
```


## PyTorch Device APIs

| CUDA | Intel XPU |
|---|---|
| `torch.cuda.is_available()` | `torch.xpu.is_available()` |
| `torch.cuda.device_count()` | `torch.xpu.device_count()` |
| `torch.device("cuda")` | `torch.device("xpu")` |
| `.to("cuda")` | `.to("xpu")` |

## Synchronization and Memory

| CUDA | Intel XPU |
|---|---|
| `torch.cuda.synchronize()` | `torch.xpu.synchronize()` |
| `torch.cuda.memory.empty_cache()` | `torch.xpu.memory.empty_cache()` |

> `empty_cache()` releases unused cached memory. It does not increase the memory
> available to PyTorch itself.

## Automatic Mixed Precision

| CUDA | Intel XPU |
|---|---|
| `torch.autocast(device_type="cuda", dtype=torch.float16)` | `torch.autocast(device_type="xpu", dtype=torch.float16)` |

BF16 can be selected by changing the data type:

```python
with torch.autocast(device_type="xpu", dtype=torch.bfloat16):
    output = model(inputs)
```

## Distributed Training

| CUDA | Intel XPU |
|---|---|
| `dist.init_process_group(backend="nccl")` | `dist.init_process_group(backend="xccl")` |
| `torch.cuda.set_device(local_rank)` | `torch.xpu.set_device(local_rank)` |
| `torchrun --nproc-per-node=2 train.py` | `torchrun --nproc-per-node=2 train.py` |

Example:

```bash
ZE_AFFINITY_MASK=3,7 \
ONEAPI_DEVICE_SELECTOR=level_zero:gpu \
torchrun --nproc-per-node=2 train.py
```

The XCCL backend must be available in the installed PyTorch build:

```python
import torch.distributed as dist

print(dist.is_xccl_available())
```

## Docker

| NVIDIA GPU | Intel XPU |
|---|---|
| `docker run --rm --gpus all <image>` | `docker run --rm --device=/dev/dri <image>` |

Notes:

- NVIDIA Docker GPU access requires the NVIDIA Container Toolkit.
- Intel XPU containers require a compatible host GPU driver and the required Level Zero, SYCL, or PyTorch XPU runtime.
- `--ipc=host` may help applications that use large shared-memory regions, but it is not required merely to expose the GPU.

## Basic Validation

```python
import torch

print("XPU available:", torch.xpu.is_available())
print("XPU count:", torch.xpu.device_count())

if torch.xpu.is_available():
    device = torch.device("xpu:0")
    x = torch.randn(1024, 1024, device=device)
    y = x @ x
    torch.xpu.synchronize()

    print("Device:", device)
    print("Result shape:", y.shape)
```
