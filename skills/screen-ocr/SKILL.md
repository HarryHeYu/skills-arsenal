---
name: screen-ocr
description: 读取用户给出的截图/图片文件，提取文字、表格转 Markdown、识别代码与报错。当用户说"读一下这张截图"、"把这个表格截图转成 Markdown"、"这段报错截图什么意思"、"把图里的代码抠出来"、"OCR this screenshot"、"extract this table from the image"时使用。只处理用户显式给出的图片文件，不做实时截屏。
---

# 图片读字：OCR / 表格 / 代码 / 报错

## 何时用

用户给出一张**图片文件路径**（截图、照片），要求提取其中文字、把表格
转成 Markdown/CSV/JSON、还原代码块、解释报错内容。离线本地 OCR，不上传。

## 前置检查

**仅 Windows 10 1809+**（用内置 Windows.Media.Ocr 引擎，需装中/英语言包）。

```bash
python -m screen_command providers
```

- 列出 `windows available=True` → 可用（适配 **screen_command 0.4.0**，
  Python 3.11–3.13）。本机以项目 venv 运行：
  `E:\code\screen-command\.venv\Scripts\python -m screen_command ...`
- 未安装 → 克隆 `https://github.com/HarryHeYu/screen-command` 后按其
  README 建 venv 并 `pip install -e .`；非 Windows 平台直接告知限制并停。

## 命令配方

```bash
python -m screen_command process <图片> --action ocr          # 提取纯文字
python -m screen_command process <图片> --action table --md   # 表格→Markdown
python -m screen_command process <图片> --action table --format CSV    # 表格→CSV
python -m screen_command process <图片> --action code --md    # 还原代码块
python -m screen_command process <图片> --action formula --md # 公式→LaTeX
python -m screen_command process <图片> --action explain      # 解读报错内容
python -m screen_command process <图片> --action markdown --md # 整理成 Markdown
python -m screen_command process <图片> --action ocr --language zh-Hans-CN  # 指定语言
python -m screen_command process <图片> --action ocr --output result.txt    # 结果落盘
```

## 输出解读

stdout 首行是元信息头 `[ocr · windows-media-ocr · zh-Hans-CN · 147 ms]`
（方括号开头），其后才是正文——解析/引用时跳过首行。stderr 的 INFO 日志
忽略即可。OCR 偶有错字（如 讠练/IOSS），转述给用户时对明显错字做合理
修正并提示"OCR 结果仅供参考"；表格对齐靠词框重建，比纯 OCR 可靠。

## 失败处理

- `WinError -2003292336 无法找不到组件` 且换个正常图片就成功 → **这张图
  本身是损坏文件**（常见：图片被文本模式转存，字节 ≥0x80 处全变成
  EF BF BD）。用 binary-anatomy skill 跑 `python -m ffe info <图片>` 验证
  魔数，向用户说明图片损坏。
- 提示未识别到表格/公式 → 选区内容真没有表格结构，如实说明，可建议
  用户改用 `--action ocr` 拿纯文字。
- 非 Windows、缺语言包、provider 全不可用 → 明确告知平台/环境限制，停。

## 红线

- 只处理用户**显式给出**的图片**文件**路径；不主动截屏（截屏需要真屏且
  用户在场，不属于 agent 自主行为），不替用户启动 GUI 模式。
- OCR 结果是推断不是事实，逐字引用原文时保留原样，不静默篡改。
