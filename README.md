# skills-arsenal 🧰

[![Release](https://img.shields.io/github/v/release/HarryHeYu/skills-arsenal)](https://github.com/HarryHeYu/skills-arsenal/releases)
[![License: MIT](https://img.shields.io/badge/License-MIT-blue.svg)](LICENSE)
![Platform](https://img.shields.io/badge/platform-ZCode%20%7C%20Claude%20Code-black)
![Bench](https://img.shields.io/badge/skills-4%20verified%20%2B%20cold--start%20tested-brightgreen)

Four [Agent Skills](https://code.claude.com/docs/en/skills) (SKILL.md, works in **ZCode** and **Claude Code**) that teach your coding agent to drive four battle-tested local CLI tools.

> Skills implement no logic — they are the manual. The tools are the engine.
> Every skill below wraps a tool that is already published, already verified, and already used daily by its author.

[简体中文](README.zh-CN.md)

## The arsenal

| Skill | What your agent learns to do | Underlying tool | Platform |
|---|---|---|---|
| [`repo-archaeology`](skills/repo-archaeology/SKILL.md) | Understand an unfamiliar repo: purpose, hot files, history, maintainers | [repo-archaeologist](https://github.com/HarryHeYu/archaeologist) v0.4.0 (`arch`; PyPI only has 0.1.x — install from git) | any |
| [`binary-anatomy`](skills/binary-anatomy/SKILL.md) | See through any binary: real format by magic, structure tree, corruption check, file diff | [file-format-explorer](https://github.com/HarryHeYu/file-format-explorer) (`python -m ffe`) | any |
| [`disk-whale`](skills/disk-whale/SKILL.md) | Dissect a disk: who ate the space, type breakdown, full-tree JSON | [dirwhale](https://github.com/HarryHeYu/dirwhale) v0.2.2 (`dirwhale.exe`) | any (exe ships for Windows) |
| [`screen-ocr`](skills/screen-ocr/SKILL.md) | Read images: OCR, table → Markdown/CSV, code & formula extraction, error explanation | [screen-command](https://github.com/HarryHeYu/screen-command) v0.4.0 (`python -m screen_command`) | Windows 10 1809+ |

Skill names are functional, not tool names — the agent triggers on *what the user wants* ("what's eating my disk"), never on knowing what `dirwhale` is.

## Install the tools

```bash
# 1. repo-archaeology — PyPI only has 0.1.x; the skills target v0.4.0 (12 subcommands)
pip install git+https://github.com/HarryHeYu/archaeologist.git

# 2. binary-anatomy (ffe runs from its source tree; no packaging needed; adapted to main @ 2026-10-31)
git clone https://github.com/HarryHeYu/file-format-explorer

# 3. disk-whale (single zero-dependency exe lives in the repo root)
git clone https://github.com/HarryHeYu/dirwhale   # add dirwhale.exe to PATH, or:
#   gcc -O2 -o dirwhale src/main.c

# 4. screen-ocr (Windows 10 1809+, Python 3.11–3.13)
git clone https://github.com/HarryHeYu/screen-command
cd screen-command
python -m venv .venv
.venv\Scripts\python -m pip install -e .
```

Then verify everything in one shot:

```bash
bash scripts/check-env.sh          # or: powershell -File scripts/check-env.ps1
```

Optional: point `FFE_HOME`, `DIRWHALE_HOME`, `SCREEN_COMMAND_HOME` at your checkouts so `check-env` can find them.

## Install the skills

Copy each skill folder into your harness's skills directory:

```bash
# ZCode / Claude Code (user scope)
cp -r skills/<skill-name> ~/.claude/skills/      # Claude Code
cp -r skills/<skill-name> ~/.agents/skills/      # ZCode
```

Or reference this repo directly if your harness supports workspace skills.

## Install as a plugin (marketplace)

This repo is itself a plugin marketplace — one plugin bundles all four skills.

**Claude Code:**

```text
/plugin marketplace add HarryHeYu/skills-arsenal
/plugin install skills-arsenal@skills-arsenal
```

**ZCode:** open **Plugin Marketplace → Add → Add Plugin Marketplace**, paste
`https://github.com/HarryHeYu/skills-arsenal`, then install **Skills Arsenal**.

After installing, the four skills trigger on natural language as usual — check
`Settings → Plugins` to manage them.

## Three-line demos

**repo-archaeology** — *"what is this repo?"*

```text
you:   这个仓库是干嘛的？核心代码在哪？
agent: arch scan E:\code\dirwhale
       → C 64.8%（777 行），入口 src/main.c，热点 src/main.c（4 commits, score 92）
       一句话总结：一个 800 行的单文件 C 磁盘分析器，测试在 tests/run.py。
```

**binary-anatomy** — *"why won't this file open?"*

```text
you:   这张图怎么 OCR 一直报错？
agent: python -m ffe info table.png
       → Unrecognized format —— 文件头是 EF BF BD 50 4E 47…（xxd 实测），PNG 魔数
       前混入了 UTF-8 替换符：图片被文本模式转存损坏了，不是 OCR 的问题。
```

**disk-whale** — *"disk full again"*

```text
you:   D 盘怎么又满了？
agent: dirwhale -d 2 -n 10 -t D:\
       → games/  (214 GiB, 3,102 files)，类型里 iso 占 180 GiB (89 files)
       建议：三个旧镜像可以删，命令给你，执行由你决定。
```

**screen-ocr** — *"read this screenshot"*

```text
you:   把这个表格截图转成 Markdown
agent: python -m screen_command process table.png --action table --md
       → [table · windows-media-ocr · zh-Hans-CN · 210 ms]
       | 模型 | 准确率 |，已按词框对齐列，可直接粘贴。
```

## Why trust the recipes

Every skill ships with a real verification record in [`docs/verification/`](docs/verification/): the exact question phrasing, the command the agent ran, and the actual output — captured on 2026-10-31. Nothing in the SKILL.md files was written from memory.

- [repo-archaeology](docs/verification/repo-archaeology.md) · [binary-anatomy](docs/verification/binary-anatomy.md) · [disk-whale](docs/verification/disk-whale.md) · [screen-ocr](docs/verification/screen-ocr.md)

The records also caught two real-world traps now encoded into the skills: Git Bash's GNU coreutils `arch` shadowing the real tool, and a cryptic Windows OCR error (`WinError -2003292336`) whose root cause is a corrupted PNG that `ffe` identifies instantly.

Before release, two independent review agents audited spec compliance and re-verified every claim against the live tools, and four cold-start agents executed each skill using *nothing but its SKILL.md* — their findings (nine fixes, including a silent window-fallback in `arch recent`, the stdout/stderr split of the OCR output, and a wrong failure-handling branch for corrupted-but-supported formats) are recorded in the same files.

## License

[MIT](LICENSE)
