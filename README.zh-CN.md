# skills-arsenal 🧰

四个 [Agent Skills](https://code.claude.com/docs/en/skills)（SKILL.md 格式，**ZCode** 与 **Claude Code** 通用），教会你的编码 Agent 驱动四个久经验证的本地 CLI 工具。

> Skill 不实现逻辑，只教 Agent 用好现有 CLI——工具是引擎，SKILL.md 是说明书。
> 下面每个 skill 背后的工具都已发布、已验证、被作者天天使用。

[English](README.md)

## 军火库

| Skill | 你的 Agent 学会什么 | 底层工具 | 平台 |
|---|---|---|---|
| [`repo-archaeology`](skills/repo-archaeology/SKILL.md) | 上手陌生仓库：是干嘛的、热点文件、演进史、谁在维护 | [repo-archaeologist](https://github.com/HarryHeYu/archaeologist) v0.4.0（`arch`；PyPI 只有 0.1.x，需从 git 安装） | 全平台 |
| [`binary-anatomy`](skills/binary-anatomy/SKILL.md) | 看穿任意二进制：按魔数认格式、结构树、损坏检测、两文件对比 | [file-format-explorer](https://github.com/HarryHeYu/file-format-explorer)（`python -m ffe`） | 全平台 |
| [`disk-whale`](skills/disk-whale/SKILL.md) | 磁盘解剖：谁吃的空间、类型分布、JSON 全树 | [dirwhale](https://github.com/HarryHeYu/dirwhale) v0.2.2（`dirwhale.exe`） | 全平台（附 Windows exe） |
| [`screen-ocr`](skills/screen-ocr/SKILL.md) | Agent 的眼睛：截图 OCR、表格转 Markdown、抠代码/公式、解读报错 | [screen-command](https://github.com/HarryHeYu/screen-command) v0.4.0（`python -m screen_command`） | Windows 10 1809+ |

skill 名用功能语义、不用工具名——Agent 靠用户的**原话场景**触发
（"盘怎么又满了"），用户根本不需要知道 dirwhale 是什么。

## 安装工具

```bash
# 1. repo-archaeology —— PyPI 只有 0.1.x；本仓库 skill 适配 v0.4.0（12 个子命令）
pip install git+https://github.com/HarryHeYu/archaeologist.git

# 2. binary-anatomy（ffe 从源码目录运行，无需打包安装；适配 main @ 2026-10-31）
git clone https://github.com/HarryHeYu/file-format-explorer

# 3. disk-whale（零依赖单文件 exe 就在仓库根目录）
git clone https://github.com/HarryHeYu/dirwhale   # 把 dirwhale.exe 加入 PATH，或：
#   gcc -O2 -o dirwhale src/main.c

# 4. screen-ocr（Windows 10 1809+，Python 3.11–3.13）
git clone https://github.com/HarryHeYu/screen-command
cd screen-command
python -m venv .venv
.venv\Scripts\python -m pip install -e .
```

一条命令自检四个工具：

```bash
bash scripts/check-env.sh          # 或: powershell -File scripts/check-env.ps1
```

可选：把 `FFE_HOME`、`DIRWHALE_HOME`、`SCREEN_COMMAND_HOME` 指到各工具
检出目录，`check-env` 即可找到它们。

## 安装 skill

把 skill 目录拷进 harness 的 skills 目录：

```bash
cp -r skills/<skill-name> ~/.claude/skills/      # Claude Code
cp -r skills/<skill-name> ~/.agents/skills/      # ZCode
```

若 harness 支持工作区级 skill，直接引用本仓库即可。

## 以插件安装（插件市场）

本仓库本身就是一个插件市场——一个插件打包全部四个 skill。

**Claude Code：**

```text
/plugin marketplace add HarryHeYu/skills-arsenal
/plugin install skills-arsenal@skills-arsenal
```

**ZCode：**打开 **插件市场 → 添加 → 添加插件市场**，粘贴
`https://github.com/HarryHeYu/skills-arsenal`，然后安装 **技能军火库**。

安装后四个 skill 照常靠自然语言触发，可在 **设置 → 插件** 里管理。

## 三行动画式示例

**repo-archaeology** — *"这个仓库是干嘛的？"*

```text
你:    这个仓库是干嘛的？核心代码在哪？
agent: arch scan E:\code\dirwhale
       → C 64.8%（777 行），入口 src/main.c，热点 src/main.c（4 commits, score 92）
       一句话总结：一个 800 行的单文件 C 磁盘分析器，测试在 tests/run.py。
```

**binary-anatomy** — *"这文件怎么打不开？"*

```text
你:    这张图怎么 OCR 一直报错？
agent: python -m ffe info table.png
       → Unrecognized format —— 文件头是 EF BF BD 50 4E 47…（xxd 实测），PNG 魔数
       前混入了 UTF-8 替换符：图片被文本模式转存损坏了，不是 OCR 的问题。
```

**disk-whale** — *"盘怎么又满了"*

```text
你:    D 盘怎么又满了？
agent: dirwhale -d 2 -n 10 -t D:\
       → games/  (214 GiB, 3,102 files)，类型里 iso 占 180 GiB (89 files)
       建议：三个旧镜像可以删，命令给你，执行由你决定。
```

**screen-ocr** — *"读这张截图"*

```text
你:    把这个表格截图转成 Markdown
agent: python -m screen_command process table.png --action table --md
       → [table · windows-media-ocr · zh-Hans-CN · 210 ms]
       | 模型 | 准确率 |，已按词框对齐列，可直接粘贴。
```

## 配方为什么可信

每个 skill 都附一份真实触发验证记录（[`docs/verification/`](docs/verification/)）：
问句原文 → agent 实际执行的命令 → 真实输出，2026-10-31 实测采集。
SKILL.md 里没有一个字是凭记忆写的。

- [repo-archaeology](docs/verification/repo-archaeology.md) · [binary-anatomy](docs/verification/binary-anatomy.md) · [disk-whale](docs/verification/disk-whale.md) · [screen-ocr](docs/verification/screen-ocr.md)

记录过程还抓到两个真实陷阱，现已写进 skill：Git Bash 里 GNU coreutils 的
`arch` 会遮蔽真工具；Windows OCR 报 `WinError -2003292336` 的真实根因是
PNG 文件本身损坏——`ffe` 一眼就能看穿。

发布前另有两组独立子代理把关：两个评审代理逐条核对规格符合性与全部
工具事实，四个冷启动代理**只拿 SKILL.md** 实际执行每个 skill——其发现
（共九处修正，包括 `arch recent` 的静默窗口回退、OCR 输出的
stdout/stderr 分流、损坏但受支持格式的失败处理分支错误）已全部记录在
同一批文件里。

## License

[MIT](LICENSE)
