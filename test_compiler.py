import torch

@torch.compile
def add(x, y):
    return x + y


with torch.device("xpu"):
    x = torch.randn(10, 10, dtype=torch.float32)
    y = torch.randn(10, 10, dtype=torch.float32)
    z = add(x, y)
    print(z)