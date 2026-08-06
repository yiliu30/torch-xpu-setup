---
layout: default
title: BKC — PyTorch 2.13 + oneAPI 2026
nav_order: 3
---

# BKC: PyTorch XPU 2.13 with oneAPI 2026 on Intel Battlemage (BMG)

* TOC
{:toc}

Best Known Configuration for running PyTorch 2.13 XPU wheels on Intel Battlemage with the 2026 Intel runtime stack and a compatible XPU compiler path for `torch.compile`.

## Validated Configuration

| Component | Version / Detail |
|-----------|------------------|
| OS | Ubuntu 25.04 (Plucky Puffin) |
| Kernel | 6.14.0-37-generic |
| GPU | Intel Battlemage G21 `[0xe211]`, 160 EUs |
| Python | 3.12.13 |
| PyTorch | 2.13.0+xpu |
| torchvision | 0.28.0+xpu |
| torchaudio | 2.11.0+xpu |
| triton-xpu | 3.7.2 |
| oneAPI wheel runtime | `dpcpp-cpp-rt` 2026.0.0, `intel-sycl-rt` 2026.0.0, `intel-cmplr-lib-ur` 2026.0.0, `intel-pti` 0.17.0 |
| XPU compiler/userspace stack | `ocloc` 26.22.38646.4, IGC 2.36.3, `libze1` 1.28.6, `libze-intel-gpu1` 26.22.38646.4 |

## Important Scope

This BKC is for **PyTorch wheel installs** from `https://download.pytorch.org/whl/xpu`.

- The Python environment already pulls in the matching oneAPI **2026 runtime** packages.
- `torch.compile` on XPU still requires a compatible external Intel GPU compiler path, specifically `ocloc` and matching GPU userspace libraries.
- Full system-wide oneAPI 2026 toolkit installation is **optional** for wheel users, but if you use it, do not mix older `/opt/intel/oneapi` runtime libraries into `LD_LIBRARY_PATH`.

For this repo, keep the original root `pyproject.toml` / `uv.lock` on PyTorch 2.11 and use the separate [`torch213/`](./torch213) project for PyTorch 2.13.

## Setup Steps

### 1. Install `uv`

```bash
curl -LsSf https://astral.sh/uv/install.sh | sh
export PATH="$HOME/.local/bin:$PATH"
```

### 2. Install baseline Intel GPU userspace packages

```bash
sudo apt install -y libze1 libze-dev libze-intel-gpu1 intel-opencl-icd xpu-smi
```

### 3. Add your user to the GPU access groups

```bash
sudo usermod -aG render,video $USER
# Start a new login session after this change.
```

### 4. Create the PyTorch 2.13 project

```bash
mkdir -p ~/torch-xpu-test-213 && cd ~/torch-xpu-test-213
uv init --python 3.12
```

### 5. Configure `pyproject.toml`

```toml
[project]
name = "torch-xpu-test-213"
version = "0.1.0"
description = "PyTorch XPU 2.13 + oneAPI 2026 runtime environment for Intel BMG"
readme = "README.md"
requires-python = ">=3.12"
dependencies = [
    "torch>=2.13,<2.14",
    "torchvision>=0.28,<0.29",
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
uv sync
```

After sync, verify the oneAPI 2026 runtime packages inside the environment:

```bash
uv run python - <<'PY'
import importlib.metadata as m
for name in [
    "torch", "torchvision", "torchaudio", "triton-xpu",
    "dpcpp-cpp-rt", "intel-cmplr-lib-ur", "intel-sycl-rt", "intel-pti"
]:
    print(f"{name}={m.version(name)}")
PY
```

Expected key versions:

```text
torch=2.13.0+xpu
torchvision=0.28.0+xpu
triton-xpu=3.7.2
dpcpp-cpp-rt=2026.0.0
intel-cmplr-lib-ur=2026.0.0
intel-sycl-rt=2026.0.0
intel-pti=0.17.0
```

### 7. Run the eager XPU smoke test

```bash
uv run python test_xpu.py
```

Expected output includes:

```text
PyTorch version : 2.13.0+xpu
XPU available   : True
...
✅ All XPU tests passed!
```

### 8. Enable a compatible `ocloc` path for `torch.compile`

PyTorch 2.13 XPU wheels do **not** include the `ocloc` executable. You need a newer Intel GPU compiler path in `PATH`.

Options:

1. Install the official Intel Deep Learning Essentials / oneAPI 2026 compiler stack system-wide.
2. Use a local compatible `ocloc` stack in front of the system one.

For this repo, the local wrapper path is:

```bash
./scripts/run_test_compiler.sh
```

Expected output:

```text
tensor(..., device='xpu:0')
```

## Troubleshooting

| Symptom | Cause | Fix |
|---------|-------|-----|
| `Invalid SPIR-V module: input SPIR-V module uses unknown extension 'SPV_INTEL_predicated_io'` | `ocloc` is older than the Triton/XPU compiler path required by PyTorch 2.13 | Use a newer `ocloc` and matching GPU userspace stack |
| `undefined symbol: urDeviceWaitExp, version LIBUR_LOADER_0.12` | An older system oneAPI runtime is overriding the wheel runtime | Remove old `/opt/intel/oneapi/...` entries from `LD_LIBRARY_PATH` |
| `XPU available: False` | Broken or missing Intel GPU userspace stack | Reinstall `libze-intel-gpu1` and `intel-opencl-icd`; verify with `xpu-smi discovery` |
| `ocloc: command not found` | No Intel GPU offline compiler available in `PATH` | Install oneAPI 2026 / Deep Learning Essentials, or prepend a compatible local `ocloc` |

## Key Notes

- Intel’s PyTorch 2.13 compatibility article maps source builds to Intel Deep Learning Essentials 2026.0.
- For wheel installs, the oneAPI **runtime** arrives through the Python packages, but the `ocloc` binary still comes from outside the wheel.
- Avoid mixing wheel-bundled 2026 runtime libraries with older sourced oneAPI runtimes from `/opt/intel/oneapi`.
