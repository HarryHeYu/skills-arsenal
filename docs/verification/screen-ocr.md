# 触发验证记录 · screen-ocr（screen-command）

- 日期：2026-10-31
- 机器：Windows 10.0.26300 x64（Windows 10 1809+ 满足）/ Git Bash（MSYS）
- 工具：screen_command **0.4.0**，venv Python 3.12.7
  （调用方式 `E:\code\screen-command\.venv\Scripts\python -m screen_command`；
  venv Scripts 下无 console script，`python -m` 是稳定入口）
- 结论：**命令配方与失败路径已全部实测通过**；自然语言触发验收待装进 harness 后执行（见文末协议）。

## 前置检查实测

```text
$ python -m screen_command providers
windows      available=True  languages=['en-US', 'zh-Hans-CN']
mock         available=True  languages=['mock']
```

✔ windows provider 可用、双语种；SKILL.md 前置检查照此写。

## 命令配方实测

```text
$ python -m screen_command process tests\fixtures\zh_paragraph.png --action ocr
00:27:01 INFO  screen_command: ocr: windows-media-ocr done in 146.7 ms (46 chars)
[ocr · windows-media-ocr · zh-Hans-CN · 147 ms]
机器学习是人工智能的一个分支。深度学习模型需要大量讠川练数据。损失函数衡量预测与真实的差距。

$ python -m screen_command process tests\fixtures\en_paragraph.png --action ocr
[ocr · windows-media-ocr · zh-Hans-CN · 91 ms]
The quick brown fox jumps over the lazy dog. ...

$ python -m screen_command process tests\fixtures\mixed.png --action ocr
[ocr · windows-media-ocr · zh-Hans-CN · 84 ms]
使用 Python 实现 neural n etwo rk 训练准确率 accuracy 达到 92.5%参考文档 https://pytorch.org docs

$ python -m screen_command process tests\fixtures\code.png --action code --md
[code · windows-media-ocr · zh-Hans-CN · 83 ms]
```python
def train(model, loader):
    model.train()
...
```

✔ 输出分流（评审复测更正）：**stderr** 先后输出 INFO 日志与元信息头
`[action · provider · lang · ms]`（方括号开头）；**stdout 只有正文**，可
直接解析/引用。上面摘录把 stderr 的头行与 stdout 正文并列展示——
SKILL.md 与本记录均已按此更正。也证实 OCR 有真实错字（讠川练、IOSS、
n etwo rk），SKILL.md 要求转述时合理修正并声明"仅供参考"。

```text
$ python -m screen_command process tests\fixtures\table.png --action table --provider mock --md
error: 未识别到表格结构 —— 选区里可能没有表格，或列之间缺少清晰分隔
（需要明显的空白、制表符或 `|`）。可尝试框选更完整的表格区域后重试。
```

✔ 「未识别到表格」的明确报错与 SKILL.md「失败处理」一致。

## 失败路径实测（重要：真实根因案例）

```text
$ python -m screen_command process tests\fixtures\table.png --action ocr
00:27:19 ERROR screen_command: action ocr: Windows OCR failed:
[WinError -2003292336] 无法找不到组件。
error: Windows OCR failed: [WinError -2003292336] 无法找不到组件。
```

table.png / formula.png 两个夹具**稳定复现**，其他夹具全部正常——排除
引擎问题后用 binary-anatomy（`python -m ffe info`）检查：Unrecognized
format；xxd 文件头：`EF BF BD 50 4E 47 ...`（UTF-8 替换符 EF BF BD 混在
PNG 魔数 `89 50 4E 47` 前）。根因：**图片文件本身被文本模式转存损坏**，
Windows OCR 对损坏文件只给得出 `WinError -2003292336` 这种无指向报错。

已写进 screen-ocr SKILL.md「失败处理」：遇此 WinError 且换图正常 →
先用 binary-anatomy 验证图片完整性，向用户说明图片损坏。

## 平台边界

- 仅 Windows（Windows.Media.Ocr）：非 Windows 上 SKILL.md 要求明确报
  平台限制并停止，check-env 亦如此（非 Windows 分支报 MISS + 说明）。
- 本次所有验证均为**文件模式**（`process <图片文件>`），未截屏——
  符合 SKILL.md 红线"不主动截屏"。

## 触发验收协议（待装好后执行）

对真实图片文件依次用以下问法（不含工具名），记录：问句原文 → agent
实际动作 → 结果。

1. "读一下这张截图，里面写了什么？"
2. "把这个表格截图转成 Markdown"
3. "这段报错截图是什么意思？"

通过标准：agent 只处理用户给出的图片文件路径；选用正确 action
（表格用 table --md 而非纯 ocr）；转述时保留原文并声明 OCR 仅供参考；
全程零截屏动作。

## 冷启动复测（独立子代理，2026-10-31）

**VERDICT：两问全 PASS。** 子代理仅凭 SKILL.md 完成：第 1 问逐字引用
zh_paragraph.png 的 OCR 正文（保留"讠川练"原样、错字单独转述修正）；
第 2 问独立完成根因链——WinError -2003292336 = HRESULT 0x88982F50
（WIC 找不到解码组件）→ ffe info 报 Unrecognized format → od 取头证实
`EF BF BD` 替换符并数出全文件 14330 个 → 健康对照图 `"ok": true` →
结论"图片被文本模式转存损坏，不可逆，请找回原始文件"。全程零截屏、
stdout/stderr 分流验证与 SKILL.md 一致。

复测建议（已全部修复进 SKILL.md）：

1. 跨 skill 调用 ffe 时未给运行位置 → 已补"在其检出目录内运行"。
2. "换个正常图片就成功"的对照判据与"只处理用户给的图"红线有张力 →
   已改为"ffe 魔数验证为首要诊断，对照 OCR 仅在用户已给出/同意时做"。
3. 未预告 ffe 两种输出形态（健康=JSON ok:true；损坏=一行 Unrecognized +
   非零退出）→ 已补。
