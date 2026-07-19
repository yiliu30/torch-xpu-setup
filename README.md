# torch-xpu-setup

Validated setup notes and helper scripts for PyTorch XPU on Intel Battlemage.

## Projects

- `pyproject.toml` / `uv.lock`: original PyTorch 2.11 environment
- `torch213/pyproject.toml` / `torch213/uv.lock`: separate PyTorch 2.13 + oneAPI 2026 environment

## Docs

- [BKC.md](./BKC.md): original PyTorch 2.11 BKC
- [BKC_NEW_USER.md](./BKC_NEW_USER.md): original 2.11 new-user setup
- [BKC_2.13_ONEAPI_2026.md](./BKC_2.13_ONEAPI_2026.md): new PyTorch 2.13 + oneAPI 2026 runtime/compiler-path BKC

## Quick Start

```bash
uv sync
uv run python test_xpu.py

uv sync --project torch213
uv run --project torch213 python test_xpu.py
./scripts/run_test_compiler.sh
```
```
uv pip install torch torchvision torchaudio --index-url https://download.pytorch.org/whl/xpu
```

```bash
ZE_AFFINITY_MASK=3 bash run_xpu.py 
ONEAPI_DEVICE_SELECTOR=level_zero:0
```
```bash
cmake -S . -B build \
  -DCMAKE_C_COMPILER=icx \
  -DCMAKE_CXX_COMPILER=icpx

cmake --build build -j
```
