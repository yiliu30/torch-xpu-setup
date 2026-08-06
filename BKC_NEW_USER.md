---
layout: default
title: BKC — New User Setup
nav_order: 4
---

# BKC: New User Setup for PyTorch XPU on Intel Battlemage (BMG)

* TOC
{:toc}

Guide for setting up a **new user account** on a node where the Intel GPU driver and userspace packages are already installed by root.

## Prerequisites

- Intel GPU driver and userspace packages (`libze1`, `libze-intel-gpu1`, `intel-opencl-icd`) are already installed system-wide
- GPU devices are visible at `/dev/dri/` (e.g., `renderD128`, `renderD129`)
- The XPU smoke test has already passed under the root (or another) account

Verify the prerequisites:

```bash
ls /dev/dri/renderD*
# Should list render nodes, e.g.: /dev/dri/renderD128  /dev/dri/renderD129
```

## Setup Steps

### 1. Add user to GPU access groups

The `render` and `video` groups are required to access `/dev/dri/renderD*` device nodes.

```bash
sudo usermod -aG render,video $USER
```

Verify:

```bash
id $USER
# Should include render and video, e.g.:
# uid=1001(yiliu7) gid=1001(yiliu7) groups=...,44(video),...,991(render)
```

**Important:** Group changes require a new login session. Either:
- Log out and log back in, **or**
- Use `sg render -c "<command>"` to run commands with the new group in the current session

### 2. Install uv (Python project manager)

```bash
curl -LsSf https://astral.sh/uv/install.sh | sh
export PATH="$HOME/.local/bin:$PATH"
```

### 3. Clone or create the project

```bash
git clone <repo-url> ~/torch-xpu-setup && cd ~/torch-xpu-setup
```

Or if creating from scratch:

```bash
mkdir -p ~/torch-xpu-setup && cd ~/torch-xpu-setup
uv init --python 3.12
```

### 4. Configure `pyproject.toml`

Ensure the file contains:

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

### 5. Install dependencies

```bash
cd ~/torch-xpu-setup
sg render -c "uv sync"
```

> Use `sg render -c "..."` if you haven't re-logged since adding groups in Step 1. After a fresh login, `uv sync` works directly.

### 6. Run the XPU smoke test

```bash
sg render -c "uv run python test_xpu.py"
```

Expected output:

```
PyTorch version : 2.11.0+xpu
XPU available   : True
XPU device count: 1
Device name     : Intel(R) Graphics [0xe211]
Device props    : total_memory=23256MB, gpu_eu_count=160, ...

Matmul 1024x1024 : OK  (result sum=...)
FP16 matmul      : OK  (result sum=...)
Conv2d (3→16)    : OK  (output shape=(1, 16, 64, 64))

Total GPU memory : 24385.7 MB
Memory allocated : 19.2 MB
Memory reserved  : 23.1 MB

✅ All XPU tests passed!
```

## Quick Reference

| Step | Command | Purpose |
|------|---------|---------|
| Groups | `sudo usermod -aG render,video $USER` | GPU device access |
| uv | `curl -LsSf https://astral.sh/uv/install.sh \| sh` | Python project manager |
| Sync | `uv sync` | Install PyTorch XPU + deps |
| Test | `uv run python test_xpu.py` | Validate XPU works |

## Troubleshooting

| Symptom | Cause | Fix |
|---------|-------|-----|
| `XPU available: False` | Missing Level Zero GPU driver | Ask admin to run `sudo apt install libze-intel-gpu1` |
| `XPU device count: 0` | User not in `render` group | `sudo usermod -aG render,video $USER` + re-login |
| Permission denied on `/dev/dri/renderD*` | Group not active in session | Log out/in, or use `sg render -c "..."` |
| `uv: command not found` | uv not installed or not in PATH | Run Step 2; add `export PATH="$HOME/.local/bin:$PATH"` to `~/.bashrc` |

## Key Notes

- The XPU wheels from `https://download.pytorch.org/whl/xpu` bundle Intel oneAPI runtime libraries (MKL, oneCCL, SYCL runtime), so a separate oneAPI toolkit installation is **not** required.
- System-level driver packages only need to be installed once by root; per-user setup only requires group membership and Python environment.
- The `sg render -c "..."` trick avoids needing to log out/in after group changes.
