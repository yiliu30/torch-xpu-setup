# torch-xpu-setup

Validated setup notes and helper scripts for PyTorch XPU on Intel Battlemage.

## Projects

- `pyproject.toml` / `uv.lock`: original PyTorch 2.11 environment
- `torch213/pyproject.toml` / `torch213/uv.lock`: separate PyTorch 2.13 + oneAPI 2026 environment

## Docs

- [BKC.md](./BKC.md): original PyTorch 2.11 BKC
- [BKC_NEW_USER.md](./BKC_NEW_USER.md): original 2.11 new-user setup
- [BKC_2.13_ONEAPI_2026.md](./BKC_2.13_ONEAPI_2026.md): new PyTorch 2.13 + oneAPI 2026 runtime/compiler-path BKC
- [CUDA ↔ Intel XPU Comparison](./index.md): CUDA-to-XPU equivalents for common workflows (also the GitHub Pages homepage)
- [BKC_TEMPLATE.md](./BKC_TEMPLATE.md): copy this template to add a new BKC/doc to the site

## GitHub Pages

This repo is set up as a GitHub Pages site (Jekyll + Just the Docs theme). To enable:

1. **Settings → Pages → Source → Deploy from a branch**
2. Branch: `master` — folder: `/` (root)

The homepage renders the CUDA ↔ XPU comparison at
`https://yiliu30.github.io/torch-xpu-setup/`.

Any markdown file added at the repo root is automatically built and published as
a themed page on push — no per-file setup needed.

### Adding a heading table of contents

Just the Docs provides the sidebar (page navigation) but no per-page heading
index. To index a page's sub-sections (e.g. `PyTorch Device APIs`), add
Kramdown's built-in TOC right after the title:

```markdown
# Title

* TOC
{:toc}
```

This renders a list of the page's headings with anchor links.

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
