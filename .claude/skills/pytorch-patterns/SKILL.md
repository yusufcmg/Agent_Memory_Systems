---
disable-model-invocation: true
name: pytorch-patterns
description: PyTorch deep learning patterns and best practices for building robust, efficient, and reproducible training pipelines, model architectures, and data loading.
origin: ECC
---

# PyTorch Development Patterns

Idiomatic PyTorch patterns and best practices for building robust, efficient, and reproducible deep learning applications.

## Core Principles

1. **Device-Agnostic Code** — Use `torch.device("cuda" if torch.cuda.is_available() else "cpu")`, never hardcode `.cuda()`
2. **Reproducibility First** — Set all seeds: `torch.manual_seed`, `torch.cuda.manual_seed_all`, `np.random.seed`, `random.seed`, plus `cudnn.deterministic = True`
3. **Explicit Shape Management** — Document tensor shapes in forward pass with comments like `# x: (batch_size, channels, H, W)`

## Model Architecture Patterns

```python
class MyModel(nn.Module):
    def __init__(self, input_dim: int, hidden_dim: int, output_dim: int):
        super().__init__()
        self.layers = nn.Sequential(
            nn.Linear(input_dim, hidden_dim),
            nn.ReLU(),
            nn.Dropout(0.3),
            nn.Linear(hidden_dim, output_dim),
        )
        self._init_weights()

    def _init_weights(self):
        for m in self.modules():
            if isinstance(m, nn.Linear):
                nn.init.kaiming_normal_(m.weight, nonlinearity="relu")
                nn.init.zeros_(m.bias)

    def forward(self, x: torch.Tensor) -> torch.Tensor:
        # x: (batch_size, input_dim)
        return self.layers(x)  # (batch_size, output_dim)
```

## Training Loop Patterns

```python
def train_epoch(model, loader, optimizer, criterion, scaler, device):
    model.train()
    for batch in loader:
        x, y = batch[0].to(device), batch[1].to(device)
        optimizer.zero_grad(set_to_none=True)  # more efficient than zero_grad()

        with torch.amp.autocast("cuda"):        # mixed precision
            out = model(x)
            loss = criterion(out, y)

        scaler.scale(loss).backward()
        scaler.unscale_(optimizer)
        torch.nn.utils.clip_grad_norm_(model.parameters(), max_norm=1.0)
        scaler.step(optimizer)
        scaler.update()

@torch.no_grad()
def evaluate(model, loader, criterion, device):
    model.eval()                               # ALWAYS set eval mode
    total_loss = 0.0
    for batch in loader:
        x, y = batch[0].to(device), batch[1].to(device)
        with torch.amp.autocast("cuda"):
            out = model(x)
            total_loss += criterion(out, y).item()
    return total_loss / len(loader)
```

## Data Pipeline Patterns

```python
class MyDataset(Dataset):
    def __init__(self, data: list[dict], transform=None):
        self.data = data
        self.transform = transform

    def __len__(self) -> int:
        return len(self.data)

    def __getitem__(self, idx: int) -> tuple[torch.Tensor, torch.Tensor]:
        item = self.data[idx]
        x = torch.tensor(item["features"], dtype=torch.float32)
        y = torch.tensor(item["label"], dtype=torch.long)
        if self.transform:
            x = self.transform(x)
        return x, y

# Optimized DataLoader
loader = DataLoader(
    dataset,
    batch_size=64,
    shuffle=True,
    num_workers=4,
    pin_memory=True,           # faster CPU → GPU transfer
    persistent_workers=True,   # avoid worker respawn overhead
    drop_last=True,
)
```

## Checkpointing

```python
# Save — always state_dict, never the model object
torch.save({
    "epoch": epoch,
    "model_state_dict": model.state_dict(),
    "optimizer_state_dict": optimizer.state_dict(),
    "loss": best_loss,
}, "checkpoint.pt")

# Load — map_location="cpu" for portability, weights_only=True for security
checkpoint = torch.load("checkpoint.pt", map_location="cpu", weights_only=True)
model.load_state_dict(checkpoint["model_state_dict"])
optimizer.load_state_dict(checkpoint["optimizer_state_dict"])
```

## Performance Optimization

```python
# Mixed precision (2x speed on modern GPUs)
scaler = torch.amp.GradScaler()

# Gradient checkpointing (trade compute for memory)
from torch.utils.checkpoint import checkpoint
out = checkpoint(expensive_layer, x)

# torch.compile (PyTorch 2.0+, significant speedup)
model = torch.compile(model, mode="reduce-overhead")

# Profile to find bottlenecks
with torch.profiler.profile(activities=[ProfilerActivity.CPU, ProfilerActivity.CUDA]) as prof:
    train_step(model, batch)
print(prof.key_averages().table(sort_by="cuda_time_total", row_limit=10))
```

## Quick Reference Idioms

| Idiom | Description |
|-------|-------------|
| `model.train()` / `model.eval()` | Always set mode before train/eval |
| `torch.no_grad()` | Disable gradients for inference |
| `optimizer.zero_grad(set_to_none=True)` | More efficient gradient clearing |
| `.to(device)` | Device-agnostic tensor/model placement |
| `torch.amp.autocast` | Mixed precision for 2x speed |
| `pin_memory=True` | Faster CPU → GPU data transfer |
| `torch.compile` | JIT compilation for speed (2.0+) |
| `weights_only=True` | Secure model loading |
| `torch.manual_seed` | Reproducible experiments |
| `gradient_checkpointing` | Trade compute for memory |

## Anti-Patterns to Avoid

- Forgetting `model.eval()` during validation (dropout stays active, BatchNorm uses batch stats)
- In-place operations like `F.relu(x, inplace=True)` or `x += residual` that break autograd
- Moving model to GPU inside the training loop (move once before the loop)
- Calling `.item()` before `.backward()` (detaches from computation graph)
- Saving entire model object with `torch.save(model, ...)` instead of `state_dict()`
- Hardcoding `.cuda()` — use `.to(device)` for MPS/CPU/CUDA portability

**Remember**: PyTorch code should be device-agnostic, reproducible, and memory-conscious. Profile with `torch.profiler` and check GPU memory with `torch.cuda.memory_summary()`.
