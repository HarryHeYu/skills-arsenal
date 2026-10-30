---
name: disk-whale
description: 磁盘解剖——看清空间都被谁吃了。当用户问"盘怎么又满了"、"这个目录谁吃的"、"node_modules 在哪"、"什么类型的文件占大头"、"C 盘红色了帮我看看"、"what's eating my disk space"、"which folder is the biggest"时使用。只分析，绝不删除。
---

# 磁盘解剖：谁吃了空间

## 何时用

用户抱怨磁盘/目录满、想找占用大户、想知道某类文件（如 node_modules、
视频、日志）占多少。给结论时附**建议**清理项，删除动作永远归用户。

## 前置检查

```bash
dirwhale -V
```

- 输出 `dirwhale 0.2.2` → 可用（适配 **0.2.x**）。
- 未找到 → 单文件 exe，克隆即用：
  `git clone https://github.com/HarryHeYu/dirwhale`，Windows 用其中
  `dirwhale.exe`（或 `gcc -O2 -o dirwhale src/main.c` 自编译），
  然后把它加入 PATH 或下面所有命令用完整路径。
- 零依赖，无需安装任何运行时。

## 命令配方

```bash
dirwhale -d 2 -n 10 -t <路径>       # 起步配方：下钻2层、每层前10名、类型分布
dirwhale -d 1 -n 10 -q <盘符或目录>  # 快速概览顶层（-q 静默进度条）
dirwhale -e node_modules -e .git -d 2 <路径>   # 排除干扰项再看
dirwhale -d 2 --json tree.json <路径>          # 全树 JSON 落盘，供后续按需解析
```

`--json` 写入的是**完整树**（不受 -d/-n 截断），文件可能很大——
不要整个 cat 进上下文，用 `jq` 或 python 按需取节点，例如：

```bash
python -c "import json;d=json.load(open('tree.json'));print(d['size'],d['files'])"
```

## 输出解读

- 首行 `<路径> [总大小, 文件数]`；树里 `名字/` 是目录，`|- ... and N more
  entries` 表示本级还有 N 项未展示（`-n` 调大即可看全）。
- `-t` 的类型分布按扩展名聚合：`<扩展名> <大小> (<文件数>)`，
  `(none)` 表示无扩展名文件——定位"什么类型占大头"看这里。
- 给用户的建议格式：3 个最大目录/类型 + 各一句"这通常是什么、
  能不能动"，并明确"是否删除由你决定"。

## 失败处理

- 长路径、无权限目录：工具已用 Win32 宽字符 API，遇错会照常输出其余部分
  并在对应位置报错——如实转述，不要建议用户改系统策略。
- 路径不存在 → 原样转述工具报错，确认用户给的路径拼写。
- 输出巨大时（整个盘 -d 4+）：主动降级到 `-d 2`，或改用 `--json` 落盘
  按需读，避免撑爆上下文。

## 红线

- **只分析，不删除**。不执行任何 delete/rm/move；发现"建议删除项"
  只列出并说明理由，执行交给用户亲自操作或显式确认后仍由用户命令完成。
- 只扫描用户指明的路径，不主动扫别的盘。
