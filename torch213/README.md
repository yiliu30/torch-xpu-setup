---
layout: default
title: torch213 env
nav_order: 5
---

# torch213

* TOC
{:toc}

Separate `uv` project for PyTorch `2.13` XPU wheels and the oneAPI `2026` wheel runtime.

## Commands

```bash
uv sync --project torch213
uv run --project torch213 python test_xpu.py
PYTHON_BIN="$PWD/torch213/.venv/bin/python" ./scripts/run_test_compiler.sh
```
