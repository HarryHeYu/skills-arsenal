#!/usr/bin/env bash
# skills-arsenal check-env —— 一条命令报告四个底层 CLI 工具是否可用（含版本）。
# 可选环境变量指向工具检出目录：FFE_HOME / DIRWHALE_HOME / SCREEN_COMMAND_HOME
# 退出码：四个全可用为 0，否则为 1。
set -u
PY="${PYTHON:-python}"
missing=0

ok()   { printf '  OK    %-18s %s\n' "$1" "$2"; }
miss() { printf '  MISS  %-18s %s\n' "$1" "$2"; missing=1; }

echo "== skills-arsenal check-env =="

# --- repo-archaeology (arch) ---
# 注意：Git Bash/MSYS 自带 GNU coreutils 的 arch（打印机器架构），必须甄别。
arch_ok=""
if command -v arch >/dev/null 2>&1; then
  first="$(arch --version 2>/dev/null | head -1)"
  case "$first" in
    "arch ("*) ;;        # GNU coreutils 同名命令，不算
    "arch "*) arch_ok="$first" ;;
  esac
fi
if [ -z "$arch_ok" ]; then
  arch_ok="$("$PY" -m archaeologist.cli --version 2>/dev/null)"
fi
if [ -n "$arch_ok" ]; then
  ok "repo-archaeology" "$arch_ok"
else
  miss "repo-archaeology" "pipx install repo-archaeologist  (或 pip install repo-archaeologist)"
fi

# --- binary-anatomy (ffe，源码目录运行) ---
ffe_out=""
if [ -n "${FFE_HOME:-}" ] && [ -d "$FFE_HOME" ]; then
  ffe_out="$(cd "$FFE_HOME" && "$PY" -m ffe --help 2>/dev/null | head -1)"
else
  ffe_out="$("$PY" -m ffe --help 2>/dev/null | head -1)"
fi
case "$ffe_out" in
  "usage: ffe"*) ok "binary-anatomy" "ffe CLI 可用（8 种格式）" ;;
  *) miss "binary-anatomy" "git clone https://github.com/HarryHeYu/file-format-explorer 后从其目录运行（或设 FFE_HOME）" ;;
esac

# --- disk-whale (dirwhale.exe) ---
dw=""
if command -v dirwhale >/dev/null 2>&1; then
  dw="$(command -v dirwhale)"
elif [ -n "${DIRWHALE_HOME:-}" ] && [ -f "$DIRWHALE_HOME/dirwhale.exe" ]; then
  dw="$DIRWHALE_HOME/dirwhale.exe"
fi
if [ -n "$dw" ]; then
  ok "disk-whale" "$("$dw" -V 2>/dev/null)"
else
  miss "disk-whale" "git clone https://github.com/HarryHeYu/dirwhale 用其中 dirwhale.exe（或自编译），加 PATH 或设 DIRWHALE_HOME"
fi

# --- screen-ocr (screen_command，仅 Windows) ---
case "$(uname -s)" in
  MINGW*|MSYS*|CYGWIN*|*_NT-*)
    sc_out=""
    if [ -n "${SCREEN_COMMAND_HOME:-}" ] && [ -f "$SCREEN_COMMAND_HOME/.venv/Scripts/python.exe" ]; then
      sc_out="$("$SCREEN_COMMAND_HOME/.venv/Scripts/python.exe" -m screen_command providers 2>/dev/null | head -1)"
    else
      sc_out="$("$PY" -m screen_command providers 2>/dev/null | head -1)"
    fi
    case "$sc_out" in
      windows*) ok "screen-ocr" "windows OCR provider 可用" ;;
      *) miss "screen-ocr" "克隆 https://github.com/HarryHeYu/screen-command，按 README 建 venv 后 pip install -e .（或设 SCREEN_COMMAND_HOME）" ;;
    esac
    ;;
  *)
    miss "screen-ocr" "本工具仅支持 Windows（内置 Windows.Media.Ocr）"
    ;;
esac

if [ "$missing" = 0 ]; then
  echo "== 4/4 可用 =="
  exit 0
else
  echo "== 有工具未就绪，按上方提示安装后重跑 =="
  exit 1
fi
