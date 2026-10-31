---
name: binary-anatomy
description: 看穿任意二进制文件的真实格式与内部结构。当用户问"这个文件打不开/是不是坏了"、"这是什么格式"、"文件头在哪"、"这两个文件差在哪"、"帮我看下这个 exe/dll/png/zip"、"what format is this file"、"is this file corrupted"、"why won't this file open"时使用。只读解析，不修改目标文件。
---

# 二进制解剖：看穿文件真实格式

## 何时用

用户拿到一个打不开、看不懂、疑似损坏的文件，或想知道两个文件差在哪。
基于**魔数**识别格式（不信任扩展名），给出逐字段的结构树、损坏检测、对比。

## 前置检查

```bash
python -m ffe --help
```

- 显示 `usage: ffe ...` → 可用。
- 报 `No module named ffe` → ffe 以源码目录运行：进入其检出目录后再跑
  （`git clone https://github.com/HarryHeYu/file-format-explorer`
  后进入该目录）。
  **所有命令都要带 `cd <ffe目录> &&`**，因为 shell 每次调用会重置工作目录。
- 支持 8 种格式：**PNG / WAV / JPEG / ZIP / PE(exe,dll) / ELF / SQLite / MP4**。
  适配：以 2026-10-31 的 main 分支检出为准（源码运行，工具本身无版本号）；
  CLI 与 GUI 共用 parser core，纯标准库，Python 3.10+。

## 命令配方

```bash
cd <ffe目录> && python -m ffe info <文件>        # JSON 摘要：格式/大小/ok（起步必用）
cd <ffe目录> && python -m ffe inspect <文件>     # 完整结构树（--depth N 限深，默认 3）
cd <ffe目录> && python -m ffe validate <文件>    # 结构校验，输出 VALID / INVALID
cd <ffe目录> && python -m ffe report <文件> -o report.md   # Markdown 报告落盘
cd <ffe目录> && python -m ffe diff <文件A> <文件B>          # 字节差异 + 结构差异
```

`inspect`/`report`/`diff` 支持 `--json`（供程序解析）；`info` 输出本身就
是 JSON。给人看时用默认文本树，`report` 默认即 Markdown（`-o` 落盘）。

## 输出解读

- `info`：`format` 是按魔数判定的真实格式；`messages` 列出解析中发现的疑点
  （坏 CRC、截断、超界指针都会出现在这，而不是崩溃）；`ok` 为解析成败；
  `image` 块仅 PNG 有值，其他格式为空对象。
- `inspect` 树：每层是字段名=值，offset 可回溯到原始字节。默认深度 3 已够
  PE 全貌；导入函数名在 `--depth 4`。
- `diff`：上半是字节级差异（"differing bytes: N in K run(s)"），下半
  "Structural differences" 把差异翻译成字段级，如
  `~ PNG/IHDR/Data/Width: 320 → 1024`——给用户讲差异就用这段。注意
  run 行的字节数是覆盖区间长度，可与 differing bytes 计数不同。
- `validate` 只答 VALID/INVALID，定位损坏点要靠 `inspect` 或 `report` 的
  errors/warnings 段。

## 失败处理

`Unrecognized format: <路径>`（退出码 1）分两支判断：

- **魔数不属于 8 种格式** → 如实说"无法解析"，列出支持的 8 种，**绝不猜测**。
- **扩展名/上下文指向 8 种之一但魔数不符** → 这是该格式的**损坏文件**
  （常见成因：图片被文本模式转存，高位字节全被替换成 EF BF BD）。
  用只读窥视取证：`head -c 16 <文件> | od -A x -t x1`，对照标准魔数
  （PNG `89 50 4E 47 0D 0A 1A 0D`、PE `4D 5A`、ZIP `50 4B`），告诉用户
  "疑似 X 格式的损坏文件，头部已毁"——不编造结构、不尝试修复。

- 文件不存在 / 无读权限 → 原样转述，不做二次猜测。
- 另一工具对某文件报出隐晦错误（如 OCR 报 `WinError -2003292336`）时，
  先用本 skill 的 `info` 查该文件是否本身就是坏的——魔数不对比报错
  信息更有说服力。

## 红线

- **只读解析**。绝不修改、重命名、移动目标文件；`report -o` 的输出路径
  必须先经用户确认，且不落在目标文件所在目录之外。
- 格式不在 8 种之内时明说"不支持"，不编造结构。
