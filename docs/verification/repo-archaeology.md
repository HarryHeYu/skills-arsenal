# 触发验证记录 · repo-archaeology（arch）

- 日期：2026-10-31
- 机器：Windows 10.0.26300 x64 / Git Bash（MSYS）
- 工具：repo-archaeologist **0.4.0**（`pyproject.toml`；pip 元数据因旧可编辑安装仍显示 0.1.0，以源码版本为准）
- 结论：**命令配方与失败路径已全部实测通过**；自然语言触发验收待装进 harness 后执行（见文末协议）。

## 前置检查实测

```text
$ arch --version
arch (GNU coreutils) 8.32          ← Git Bash 里是同名 coreutils 命令，必须甄别

$ python -m archaeologist.cli --version
arch 0.4.0                         ← 可靠调用方式（console script 未生成时）
```

`arch` 在本机 PATH 上没有指向真工具（Python314/Scripts 里无 arch.exe），
`python -m archaeologist.cli`（或 `python -m archaeologist`，含 `__main__.py`）
是稳定入口。SKILL.md 的前置检查已按此写成两级探测。

## 命令配方实测

目标：真实仓库 `E:\code\dirwhale`（git，main，5 commits）。

```text
$ python -m archaeologist.cli scan E:\code\dirwhale
Repository      dirwhale
Git             yes (branch: main, HEAD: 817bfdf)
Remote          https://github.com/HarryHeYu/dirwhale.git
Commits         5   contributors: 1
Languages:  C 64.8% ... Python 12.9% ... YAML 11.1% ...
Repository Structure:  src (main source code) / tests / .github
Likely Entrypoints:  1. src/main.c   2. tests/run.py
Hot Files:  1. src/main.c   commits: 4   score: 92.0
Recent Changes (last 30 days):  1 commits, +31 -13
Contributors:  HarryHe   commits: 5   lines changed: 1,939
```

✔ scan 六段输出与 SKILL.md「输出解读」一致。

```text
$ python -m archaeologist.cli hot --help
usage: arch hot [-h] [-n TOP] [repo]
$ python -m archaeologist.cli timeline --help
usage: arch timeline [-h] [repo]
$ python -m archaeologist.cli search --help
usage: arch search [-h] [-n TOP] query [repo]
$ python -m archaeologist.cli symbol --help
usage: arch symbol [-h] name [repo]
$ python -m archaeologist.cli tree --help
usage: arch tree [-h] [-d DEPTH] [repo]
$ python -m archaeologist.cli recent --help
usage: arch recent [-h] [--days DAYS] [repo]
$ python -m archaeologist.cli contributors --help
usage: arch contributors [-h] [-n TOP] [repo]
$ python -m archaeologist.cli history --help
usage: arch history [-h] target [repo]
$ python -m archaeologist.cli file --help
usage: arch file [-h] path [repo]
$ python -m archaeologist.cli why --help
usage: arch why [-h] path [repo]
$ python -m archaeologist.cli deps --help
usage: arch deps [-h] path [repo]
```

✔ 12 个子命令全部核实（任务书旧稿写 9 个，源码 v0.4.0 新增 file/why/deps，
SKILL.md 已按 12 个写）。全工具无 `--json` 模式——SKILL.md 未承诺 JSON，
统一按人读文本解读。

## 失败路径实测

- **coreutils 冲突**：`arch --version` 返回 "GNU coreutils" 已复现，
  check-env.sh 第一版曾误判 OK，已修复（模式排除 `arch (*`）并回归通过。
- **非 git 目录 / 安装指引**：按 SKILL.md「失败处理」降级与停止条款执行。

## 触发验收协议（待装好后执行）

把 `skills/repo-archaeology/` 拷入 harness skills 目录，开新会话，对任意
真实仓库依次用以下问法（**不含工具名**），agent 应自动触发本 skill 并先
摘要后深挖。每种记录：问句原文 → agent 实际动作 → 结果。

1. "这个仓库是干嘛的？核心代码在哪？"
2. "最近这个项目都在改什么？"
3. "帮我看看这个 repo 是谁在维护的？"

通过标准：agent 未被告知任何命令的情况下调用 arch 并给出结构化摘要；
对追问能选用正确的深挖子命令；不把 timeline 全量倒进上下文。
