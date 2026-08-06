---
layout: default
title: BKC Template — Copy Me
nav_order: 99
nav_exclude: true
---

<!--
HOW TO ADD A NEW DOC / BKC TO THIS SITE
=======================================
1. Copy this file to a new name at the repo root, e.g. `BKC_<YOUR_SETUP>.md`.
   Every markdown file at the repo root becomes a page on GitHub Pages.
2. Edit the front matter above:
   - `title`: short sidebar label, e.g. `BKC — PyTorch 2.13 + oneAPI 2026`
   - `nav_order`: sidebar position (lower sorts first; default 99 = last)
   - remove `nav_exclude: true` so the new page appears in the sidebar
3. Keep the `* TOC` / `{:toc}` snippet below the H1 to index sub-sections.
4. Commit and push. The page builds automatically at
   https://yiliu30.github.io/torch-xpu-setup/<file-name>.html
-->

# BKC: <Short Title>

<One-sentence summary of what this BKC configures or validates.>

* TOC
{:toc}

## Validated Configuration

| Component | Version / Detail |
|-----------|------------------|
| OS | |
| Kernel | |
| GPU | |
| GPU Memory | |
| Python | |
| PyTorch | |
| torchvision | |
| torchaudio | |
| triton-xpu | |
| Level Zero Loader | |
| Level Zero GPU | |

## Setup Steps

### 1. <Step name>

```bash
# command or instructions
```

### 2. <Step name>

```bash
# command or instructions
```

<!-- add more steps as needed -->

## Expected Output

```
# paste expected output here
```

## Troubleshooting

| Symptom | Cause | Fix |
|---------|-------|-----|
| `<error>` | `<root cause>` | `<fix command>` |

## Key Notes

- <important note about this configuration>
- <version caveats, install ordering requirements, etc.>
