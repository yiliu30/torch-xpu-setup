```
uv pip install torch torchvision torchaudio --index-url https://download.pytorch.org/whl/xpu
```

```bash
ZE_AFFINITY_MASK=3 bash run_xpu.py 
ONEAPI_DEVICE_SELECTOR=level_zero:0
```
