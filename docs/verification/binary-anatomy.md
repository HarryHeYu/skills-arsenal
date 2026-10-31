# 触发验证记录 · binary-anatomy（ffe）

- 日期：2026-10-31
- 机器：Windows 10.0.26300 x64 / Git Bash（MSYS）/ Python 3.14.2
- 工具：file-format-explorer（源码目录运行，无版本号输出；CLI 5 子命令）
- 结论：**命令配方与失败路径已全部实测通过**；自然语言触发验收待装进 harness 后执行（见文末协议）。

## 前置检查实测

```text
$ cd E:\code\skills-arsenal && python -m ffe --help
C:\Python314\python.exe: No module named ffe      ← 未安装，模块不可导入

$ cd E:\code\file-format-explorer && python -m ffe --help
usage: ffe [-h] {inspect,validate,info,report,diff} ...
```

✔ 证实 ffe 只能在其检出目录内运行；SKILL.md 写明 `cd <ffe目录> &&` 前缀
（shell 每次调用重置工作目录），并支持 `FFE_HOME` 环境变量（check-env 用）。

## 命令配方实测（目标：真实 PE 文件 dirwhale.exe）

```text
$ python -m ffe info E:\code\dirwhale\dirwhale.exe
{
  "format": "PE",
  "fileSize": 77733,
  "messages": [],
  "image": {},
  "ok": true
}

$ python -m ffe validate E:\code\dirwhale\dirwhale.exe
VALID

$ python -m ffe inspect E:\code\dirwhale\dirwhale.exe
Format : PE
Size   : 77733 bytes
PE
  └─ DOS Header
    └─ e_magic = MZ
    └─ e_lfanew = 128
  └─ COFF Header
    └─ Machine = x64
    └─ NumberOfSections = 17
  └─ Optional Header (PE32+)
    └─ Subsystem = Windows Console
  └─ Section Table
    └─ .text ...
（--depth 默认 3；--json 可输出 JSON）

$ python -m ffe report E:\code\dirwhale\dirwhale.exe | head
# PE Analysis: dirwhale.exe
- File size: 77733 bytes
- Status: VALID
- Errors: 0, Warnings: 0
- PE: x64, Windows Console, entry point RVA 0x13F0, 17 sections
- Imports: 12 DLLs, 82 functions
```

## 命令旗标佐证（评审补充，2026-10-31）

```text
$ python -m ffe report --help
usage: ffe report [-h] [--json] [-o OUTPUT] [--depth DEPTH] file
  --json               JSON instead of Markdown
  -o, --output OUTPUT  Write to file (default: stdout)
  --depth DEPTH        Tree depth limit (default 3)

$ python -m ffe info --help
usage: ffe info [-h] file          ← info 没有 --json 旗标：它本身就是 JSON 输出
```

✔ SKILL.md 的 `report -o report.md` 旗标属实；"info 无 --json、本身就是
JSON"已据此在 SKILL.md 中更正。`inspect`/`report`/`diff` 的 `--json` 均在
各自 usage 行中。

## diff 实测（两张真实 PNG）

```text
$ python -m ffe diff samples/gradient_320x200.png samples/gradient_1024x768.png
A: samples/gradient_320x200.png  (PNG, 121750 bytes)
B: samples/gradient_1024x768.png  (PNG, 120543 bytes)
Common prefix: 18 bytes; differing bytes: 121220 in 1 run(s)

Structural differences:
  ~ PNG/IHDR/Data/Width: 320 → 1024
  ~ PNG/IHDR/Data/Height: 200 → 768
  ~ PNG/IHDR/CRC: 0x990438AB (valid) → 0xBABA150D (valid)
  ~ PNG/IDAT/Length: 121693 → 120486
```

✔ 字节差异 + 结构差异双层输出与 SKILL.md「输出解读」一致。

## 失败路径实测

```text
# 真未知格式（garbage 二进制）
$ python -m ffe info scratch\unknown.bin
Unrecognized format: E:\code\skills-arsenal\scratch\unknown.bin
退出码 = 1

# 伪装扩展名（.txt 实为 PNG —— 魔数检测不信任扩展名的实证）
$ python -m ffe info samples/abc.txt
{ "format": "PNG", "fileSize": 70, "image": { "width": 1, "height": 1, ... } }
```

✔ 未知格式行为与退出码与 SKILL.md「失败处理」一致：如实报不支持、
列 8 种格式、不猜。

## 联动案例（真实发生，已写进两个 skill）

screen-command 的测试夹具 `table.png`/`formula.png` 使 Windows OCR 报
隐晦的 `WinError -2003292336 无法找不到组件`；用本 skill 的
`python -m ffe info` 检查 → Unrecognized format；xxd 看文件头 →
`EF BF BD 50 4E 47...`：PNG 魔数前混入 UTF-8 替换符（文件被文本模式
转存损坏）。**ffe 一步定位根因，OCR 的报错信息反而毫无指向性。**

## 触发验收协议（待装好后执行）

对任意真实文件依次用以下问法（不含工具名），记录：问句原文 → agent
实际动作 → 结果。

1. "这个文件是什么格式？怎么打不开？"
2. "帮我看下这个 exe 的内部结构"
3. "这两个文件差在哪？"

通过标准：agent 对未知格式如实说"不支持"并列 8 种格式，绝不猜；
对损坏文件能定位到具体偏移；只读，不改动目标文件。

## 冷启动复测（独立子代理，2026-10-31）

**VERDICT：三问 = PASS-WITH-FRICTION / PASS / PASS。** 子代理仅凭 SKILL.md
完成全部三问：坏图（table.png）判损坏并给出魔数证据（od 取头 16 字节，
`EF BF BD 50 4E 47…`）；diff 直达结构差异；PE 全貌 + `--depth 4` 列出
全部导入函数名。全程零写文件、未猜格式。

复测抓到的问题（已全部修复进 SKILL.md）：

1. **major**：原失败话术对"**受支持格式的损坏文件**"（恰是 table.png 这
   种）会引导出"8 种之外"的事实错误结论 → 已拆成两支：魔数不属于 8 种 =
   不支持；魔数不符但上下文指向某格式 = 损坏文件，并新增只读窥视配方
   `head -c 16 <文件> | od -A x -t x1` + 标准魔数对照。
2. minor：diff 输出里 run 覆盖长度与 differing bytes 计数不同，未说明会
   被当成矛盾 → 已在「输出解读」注明。
3. minor：`info` 的 `image` 块仅 PNG 有值（PE 为空对象）→ 已注明。
4. minor：导入函数名在 `--depth 4` → 已注明。
