# 触发验证记录 · disk-whale（dirwhale）

- 日期：2026-10-31
- 机器：Windows 10.0.26300 x64 / Git Bash（MSYS）
- 工具：dirwhale **0.2.2**（单文件 exe，位于 `E:\code\dirwhale\dirwhale.exe`，未在 PATH）
- 结论：**命令配方与输出形态已全部实测通过**；自然语言触发验收待装进 harness 后执行（见文末协议）。

## 前置检查实测

```text
$ dirwhale -V
bash: dirwhale: command not found            ← 未加 PATH

$ E:\code\dirwhale\dirwhale.exe -V
dirwhale 0.2.2

$ E:\code\dirwhale\dirwhale.exe -h
dirwhale — zero-dependency disk usage analyzer
usage: E:\code\dirwhale\dirwhale.exe [options] [path]
  -d, --depth N      show children down to depth N (default 1)
  -n, --top N        biggest N entries per level (default 15)
  -e, --exclude PAT  skip wildcard pattern, may repeat
  -t, --types        show file-type breakdown
  -j, --json FILE    also write results as JSON
  -q, --quiet        no scan-progress on stderr
  -V, --version      print version and exit
```

✔ SKILL.md 的前置检查按「PATH 未命中 → 完整路径 / DIRWHALE_HOME」写。

## 命令配方实测

```text
$ dirwhale.exe -d 2 -n 5 -t -q E:\code\skills-arsenal
E:\code\skills-arsenal [33.3 KiB, 20 files]
  |- .git/  (26.7 KiB, 18 files)
  | |- hooks/  (26.2 KiB, 14 files)
  | |- config  (248 B, 1 file)
  | |- info/  (240 B, 1 file)
  | `- ... and 2 more entries (0 B)
  |- 任务书.md  (6.52 KiB, 1 file)
  `- scratch/  (28 B, 1 file)
    `- unknown.bin  (28 B, 1 file)

file types:
  sample       26.2 KiB  (14 files)
  md           6.52 KiB  (1 file)
  (none)       584 B  (4 files)
  bin          28 B  (1 file)
```

✔ 树形结构、`... and N more entries` 截断、`-t` 类型分布（含 `(none)`
类目）与 SKILL.md「输出解读」一致；中文文件名（任务书.md）显示正常。

```text
$ dirwhale.exe -d 2 -n 6 --json tree.json -q E:\code\dirwhale
JSON written to E:\code\skills-arsenal\scratch\dirwhale.json

$ head -c 400 tree.json
{"name":"E:\\code\\dirwhale","path":"E:\\code\\dirwhale","is_dir":true,
 "size":324335,"files":78,"children":[{"name":".git","path":"...",
 "children":[{"name":"objects",...{"name":"41",...{"name":"b7e2d4395dec..."}}]}]}]}
```

✔ 重要事实：JSON 落盘的是**完整树**（含 -d 2 之外的深层节点
.git/objects/41/b7e2…），印证 SKILL.md「不要整个 cat 进上下文，按需解析」。

## 失败路径实测

- check-env 在无环境变量、无 PATH 命中时正确报 MISS 并给安装/构建提示
  （bash 版与 PowerShell 版均实测，见 scripts 自测记录）。
- 长路径/权限类错误：本次未复现；SKILL.md 按「如实转述工具报错」处理。

## 触发验收协议（待装好后执行）

对真实磁盘/目录依次用以下问法（不含工具名），记录：问句原文 → agent
实际动作 → 结果。

1. "C 盘怎么又满了？谁吃的？"
2. "这个项目目录里 node_modules 到底占了多少？"
3. "D 盘里什么类型的文件占大头？"

通过标准：agent 起步即用 `-d 2 -n 10 -t` 级别的克制参数而非全量深扫；
给结论时附**建议**清理项且明确"删除由你决定"；全程零删除动作。
