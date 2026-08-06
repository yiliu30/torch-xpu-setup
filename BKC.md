---
layout: default
title: BKC — PyTorch XPU 2.11 on Intel Battlemage
nav_order: 2
---

# BKC: PyTorch XPU 2.11 on Intel Battlemage (BMG)

Best Known Configuration for running PyTorch with XPU support on Intel Battlemage GPUs.

## Validated Configuration

| Component          | Version / Detail                          |
|--------------------|-------------------------------------------|
| OS                 | Ubuntu 25.10 (Questing Quokka)            |
| Kernel             | 6.17.0-5-generic (xe driver)              |
| GPU                | Intel Battlemage G21 (0xe211), 160 EUs    |
| GPU Memory         | ~24 GB                                    |
| Python             | 3.12                                      |
| PyTorch            | 2.11.0+xpu                                |
| torchvision        | 0.26.0+xpu                                |
| torchaudio         | 2.11.0+xpu                                |
| triton-xpu         | 3.7.0                                     |
| Level Zero Loader  | libze1 1.24.1                             |
| Level Zero GPU     | libze-intel-gpu1 25.31.34666.3            |
| Intel OpenCL ICD   | intel-opencl-icd 25.31.34666.3            |

## Setup Steps

### 1. Install uv (Python project manager)

```bash
curl -LsSf https://astral.sh/uv/install.sh | sh
export PATH="$HOME/.local/bin:$PATH"
```

### 2. Install GPU userspace driver packages

```bash
sudo apt install -y libze1 libze-dev libze-intel-gpu1 intel-opencl-icd
```

### 3. Add user to GPU access groups

```bash
sudo usermod -aG render,video $USER
# Log out and log back in, or use `newgrp render` for the current session
```

### 4. Create the PyTorch XPU project

```bash
mkdir -p ~/torch-xpu-test && cd ~/torch-xpu-test
uv init --python 3.12
```

### 5. Configure `pyproject.toml`

Replace the contents with:

```toml
[project]
name = "torch-xpu-test"
version = "0.1.0"
description = "PyTorch XPU 2.11 test environment for Intel BMG"
readme = "README.md"
requires-python = ">=3.12"
dependencies = [
    "torch>=2.11,<2.12",
    "torchvision>=0.26,<0.27",
    "torchaudio>=2.11,<2.12",
]

[tool.uv.sources]
torch = [{ index = "pytorch-xpu" }]
torchvision = [{ index = "pytorch-xpu" }]
torchaudio = [{ index = "pytorch-xpu" }]

[[tool.uv.index]]
name = "pytorch-xpu"
url = "https://download.pytorch.org/whl/xpu"
```

### 6. Install dependencies

```bash
cd ~/torch-xpu-test
uv sync
```

### 7. Run the smoke test

```bash
uv run python test_xpu.py
```

Expected output:

```
PyTorch version : 2.11.0+xpu
XPU available   : True
XPU device count: 1
Device name     : Intel(R) Graphics [0xe211]
...
✅ All XPU tests passed!
```

## Troubleshooting

| Symptom                        | Cause                              | Fix                                              |
|--------------------------------|------------------------------------|--------------------------------------------------|
| `XPU available: False`         | Missing Level Zero GPU driver      | `sudo apt install libze-intel-gpu1`               |
| `XPU device count: 0`          | User not in `render` group         | `sudo usermod -aG render,video $USER` + re-login  |
| `libze_loader.so` not found    | Level Zero loader not installed    | `sudo apt install libze1`                         |
| torchvision version mismatch   | Wrong version specifier            | Use `torchvision>=0.26,<0.27` with torch 2.11     |

## Key Notes

- The XPU wheels from `https://download.pytorch.org/whl/xpu` bundle Intel oneAPI runtime libraries (MKL, oneCCL, SYCL runtime, etc.), so a separate oneAPI toolkit installation is **not** required.
- BMG (Battlemage) uses the Xe2 architecture. Ensure your kernel has the `xe` driver (check with `xpu-smi discovery`).
- The `render` group permission is required to access `/dev/dri/renderD*` device nodes.

## BKC: Building a local vLLM-Omni XPU environment with uv

This is a validated flow for building a working local `vllm` + `vllm-omni`
environment on Intel XPU using `uv`, with `vllm` built from source first and
`vllm-omni` installed into the same environment.

### Validated versions

| Component   | Version / Detail |
|-------------|------------------|
| Python      | 3.12.3 |
| uv          | 0.11.25 |
| torch       | 2.11.0+xpu |
| torchvision | 0.26.0+xpu |
| torchaudio  | 2.11.0+xpu |
| triton-xpu  | 3.7.0 |
| triton      | not installed |
| vllm        | 0.23.0+xpu |
| vllm-omni   | 0.23.0+xpu |

### Repo layout

Assume both repos are cloned locally:

```bash
export OMNI_REPO=/path/to/vllm-omni
export VLLM_REPO=/path/to/vllm
export OMNI_VENV=$OMNI_REPO/.venv-xpu
```

They can live anywhere. They do not need to share the same parent directory.

### 1. Create the uv environment

```bash
cd "$OMNI_REPO"
uv venv --python 3.12 "$OMNI_VENV"
source "$OMNI_VENV/bin/activate"
```

### 2. Install the XPU PyTorch stack

```bash
uv pip install \
  --index-url https://download.pytorch.org/whl/xpu \
  torch==2.11.0+xpu \
  torchvision==0.26.0+xpu \
  torchaudio==2.11.0+xpu

uv pip install \
  --extra-index-url https://download.pytorch.org/whl/xpu \
  triton-xpu==3.7.0
```

### 3. Build and install local vLLM first

Follow the vLLM XPU source-build path, then install into the same `uv` env:

```bash
cd "$VLLM_REPO"
source "$OMNI_VENV/bin/activate"
VLLM_TARGET_DEVICE=xpu uv pip install --no-build-isolation -e . -v
```

### 4. Install local vLLM-Omni

```bash
cd "$OMNI_REPO"
source "$OMNI_VENV/bin/activate"
uv pip install -e . -v
```

### 5. Verify the environment

Check XPU visibility:

```bash
cd "$OMNI_REPO"
source "$OMNI_VENV/bin/activate"
python - <<'PY'
import torch
print("torch", torch.__version__)
print("xpu_available", torch.xpu.is_available())
print("xpu_count", torch.xpu.device_count())
PY
```

Check key packages:

```bash
cd "$OMNI_REPO"
source "$OMNI_VENV/bin/activate"
uv pip list | rg '^(torch|torchaudio|torchvision|transformers|triton|triton-xpu|vllm|vllm-omni)\b'
```

Check imports:

```bash
cd "$OMNI_REPO"
source "$OMNI_VENV/bin/activate"
python - <<'PY'
import vllm
import vllm_omni
print("vllm ok")
print("vllm_omni ok")
PY
```

Expected high-level result:

- `torch.xpu.is_available()` is `True`
- `triton-xpu==3.7.0` is installed
- plain `triton` is absent
- both `vllm` and `vllm-omni` import successfully

### Runtime notes

- Install `vllm` before `vllm-omni` in this XPU flow.
- Do not install plain `triton` into this environment. Keep only `triton-xpu`.
- For multi-card runs, a validated example is:

```bash
ZE_AFFINITY_MASK=4,5,6,7
VLLM_WORKER_MULTIPROC_METHOD=spawn
```

This exposes 4 visible XPU devices to the process and matches TP=4 serving.
