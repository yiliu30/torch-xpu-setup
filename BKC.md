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
