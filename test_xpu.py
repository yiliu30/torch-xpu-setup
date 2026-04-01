"""Quick smoke test for PyTorch XPU on Intel BMG."""
import torch

print(f"PyTorch version : {torch.__version__}")
print(f"XPU available   : {torch.xpu.is_available()}")
print(f"XPU device count: {torch.xpu.device_count()}")

if torch.xpu.is_available():
    dev = torch.device("xpu")
    print(f"Device name     : {torch.xpu.get_device_name(0)}")
    print(f"Device props    : {torch.xpu.get_device_properties(0)}")

    # Basic tensor ops
    a = torch.randn(1024, 1024, device=dev)
    b = torch.randn(1024, 1024, device=dev)
    c = a @ b
    torch.xpu.synchronize()
    print(f"\nMatmul 1024x1024 : OK  (result sum={c.sum().item():.4f})")

    # FP16 matmul
    a_fp16 = a.half()
    b_fp16 = b.half()
    c_fp16 = a_fp16 @ b_fp16
    torch.xpu.synchronize()
    print(f"FP16 matmul      : OK  (result sum={c_fp16.sum().item():.4f})")

    # Simple conv2d
    import torch.nn as nn
    conv = nn.Conv2d(3, 16, 3, padding=1).to(dev)
    x = torch.randn(1, 3, 64, 64, device=dev)
    y = conv(x)
    torch.xpu.synchronize()
    print(f"Conv2d (3→16)    : OK  (output shape={tuple(y.shape)})")

    # Memory info
    props = torch.xpu.get_device_properties(0)
    print(f"\nTotal GPU memory : {props.total_memory / 1e6:.1f} MB")
    print(f"Memory allocated : {torch.xpu.memory_allocated(0) / 1e6:.1f} MB")
    print(f"Memory reserved  : {torch.xpu.memory_reserved(0) / 1e6:.1f} MB")

    print("\n✅ All XPU tests passed!")
else:
    print("\n❌ XPU not available — check drivers and Intel GPU.")
