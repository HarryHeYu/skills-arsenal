---
name: repo-archaeology
description: 快速理解一个陌生代码库。当用户问"这个仓库是干嘛的"、"核心代码在哪"、"最近在改什么"、"这个项目谁在维护"、"帮我看看这个 repo"、"where is the core code in this repo"、"what does this project do"、"who maintains this"时使用。只读分析，不改动任何仓库文件。
---

# 仓库考古：理解陌生代码库

## 何时用

用户想快速了解一个代码库：它是干嘛的、核心在哪、最近在动哪里、谁在维护。
适合"接手新项目""code review 前摸底""给 newcomer 写导读"类请求。

## 前置检查

```bash
arch --version
```

- 输出形如 `arch 0.4.0` → 可用（适配版本 **0.4.0**）。
- ⚠️ Git Bash / MSYS 里 `arch` 是 GNU coreutils 同名命令。若输出含
  "GNU coreutils"，改用 `python -m archaeologist.cli --version` 验证；
  一旦走这条替代路径，**下文配方里的 `arch` 全部替换为
  `python -m archaeologist.cli` 执行**。
- 都失败 → 未安装，给用户安装指引后**停止**。注意：PyPI 上的发布停留在
  0.1.x，落后于本 skill 适配的 0.4.0（缺 file/why/deps 等），请装源码版：
  `pip install git+https://github.com/HarryHeYu/archaeologist.git`

## 命令配方

**先跑 scan，把摘要讲给用户，再按追问深挖：**

```bash
arch scan <repo>          # 全景：语言/结构/入口/热点/近期/贡献者（起步必用）
arch hot <repo> -n 10     # 改动最频繁的文件（"核心代码在哪"）
arch recent <repo> --days 30   # 最近在改什么
arch contributors <repo>  # 谁在维护、各自负责哪些区域
arch timeline <repo>      # 逐年演进史（输出长，只在用户明确要时用）
arch search <关键词> <repo>    # 搜路径 / commit 信息 / 贡献者
arch symbol <函数名> <repo>    # 按名字找函数/类定义（需安装 [symbols] 扩展）
arch tree <repo> -d 3     # 带注释的目录树
arch history <文件或关键词> <repo>  # 单个文件/模块的演进
arch file <路径> <repo>   # 单文件档案：历史+导入+共同变更
arch why <路径> <repo>    # 这个文件为什么重要，给证据
arch deps <路径> <repo>   # 文件的内部依赖
```

默认作用于当前目录；`<repo>` 可省略。`scan -o report.md` 额外落盘一份
Markdown 报告（写到用户工作区内，写到哪先说一声）。

## 输出解读

scan 报告六段：**Languages**（语言占比）→ **Repository Structure**（每个顶层
目录的用途猜测）→ **Likely Entrypoints**（入口文件）→ **Hot Files**（按变更
频率+近期活跃打分，score 越高越是核心）→ **Recent Changes**（近期改动分布；
实际窗口看输出标题，默认 365 天）→ **Contributors**（每人改动量与主战场）。
摘要时按这个顺序各给一两句即可。

## 失败处理

- **非 git 目录**：git 统计段为空/报错 → 降级用 `arch tree -d 3` + 语言统计
  作答，并向用户说明"该目录没有 git 历史，以下仅基于文件结构"。
- **命令不存在**：按前置检查给安装指引，不要尝试 pip install 之外的猜测。
- **timeline 输出很长**：绝不整段倾倒进上下文——先自己读，压缩成 3-5 条
  关键节点再给用户；用户要细节时按年份截取。
- **recent 的窗口回退**：请求窗口内没有提交时，工具会**静默**把窗口放宽到
  365 天（仅输出标题变化，无提示）。核对标题里的实际窗口；窗口为空就如实
  说"该窗口内无提交"，别把放宽后的结果当"最近"汇报。

## 红线

- **只读**。不运行仓库里的任何代码，不执行 build/test 脚本，不写任何文件
  进目标仓库。
- 先摘要后深挖，未经追问不主动连跑多个重命令（尤其 timeline）。用户一条
  消息里同时问了几个方面（是干嘛的/核心在哪/最近改什么）时，视为已有
  追问，scan 后允许补跑 hot/recent 等对应命令。
