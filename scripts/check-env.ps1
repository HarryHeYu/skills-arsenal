# skills-arsenal check-env —— 一条命令报告四个底层 CLI 工具是否可用（含版本）。
# 可选环境变量指向工具检出目录：FFE_HOME / DIRWHALE_HOME / SCREEN_COMMAND_HOME
# 退出码：四个全可用为 0，否则为 1。
$ErrorActionPreference = 'SilentlyContinue'
$missing = 0
function Ok($name, $msg)   { Write-Host ("  OK    {0,-18} {1}" -f $name, $msg) }
function Miss($name, $msg) { Write-Host ("  MISS  {0,-18} {1}" -f $name, $msg); $script:missing = 1 }

Write-Host "== skills-arsenal check-env =="

# --- repo-archaeology (arch) ---
# 注意：PATH 上若有 GNU coreutils 的 arch（打印机器架构），输出会含 "GNU coreutils"。
$archOk = $null
$archCmd = Get-Command arch -ErrorAction SilentlyContinue
if ($archCmd) {
    $first = (arch --version 2>$null | Select-Object -First 1)
    if ($first -match '^arch \d') { $archOk = $first }
}
if (-not $archOk) {
    $archOk = (python -m archaeologist.cli --version 2>$null | Select-Object -First 1)
}
if ($archOk) {
    Ok 'repo-archaeology' $archOk
} else {
    Miss 'repo-archaeology' 'pipx install repo-archaeologist  (或 pip install repo-archaeologist)'
}

# --- binary-anatomy (ffe，源码目录运行) ---
$ffeOut = $null
if ($env:FFE_HOME -and (Test-Path $env:FFE_HOME)) {
    $ffeOut = $(
        Push-Location $env:FFE_HOME
        python -m ffe --help 2>$null | Select-Object -First 1
        Pop-Location
    )
} else {
    $ffeOut = (python -m ffe --help 2>$null | Select-Object -First 1)
}
if ($ffeOut -match '^usage: ffe') {
    Ok 'binary-anatomy' 'ffe CLI 可用（8 种格式）'
} else {
    Miss 'binary-anatomy' 'git clone https://github.com/HarryHeYu/file-format-explorer 后从其目录运行（或设 FFE_HOME）'
}

# --- disk-whale (dirwhale.exe) ---
$dwCmd = Get-Command dirwhale -ErrorAction SilentlyContinue
$dw = if ($dwCmd) { $dwCmd.Source } elseif ($env:DIRWHALE_HOME -and (Test-Path (Join-Path $env:DIRWHALE_HOME 'dirwhale.exe'))) { Join-Path $env:DIRWHALE_HOME 'dirwhale.exe' } else { $null }
if ($dw) {
    $v = (& $dw -V 2>$null)
    Ok 'disk-whale' "$v  ($dw)"
} else {
    Miss 'disk-whale' 'git clone https://github.com/HarryHeYu/dirwhale 用其中 dirwhale.exe（或自编译），加 PATH 或设 DIRWHALE_HOME'
}

# --- screen-ocr (screen_command，仅 Windows) ---
if ($IsWindows -or $env:OS -eq 'Windows_NT') {
    $scPy = if ($env:SCREEN_COMMAND_HOME -and (Test-Path (Join-Path $env:SCREEN_COMMAND_HOME '.venv\Scripts\python.exe'))) {
        Join-Path $env:SCREEN_COMMAND_HOME '.venv\Scripts\python.exe'
    } else { 'python' }
    $scOut = (& $scPy -m screen_command providers 2>$null | Select-Object -First 1)
    if ($scOut -match '^windows') {
        Ok 'screen-ocr' 'windows OCR provider 可用'
    } else {
        Miss 'screen-ocr' '克隆 https://github.com/HarryHeYu/screen-command，按 README 建 venv 后 pip install -e .（或设 SCREEN_COMMAND_HOME）'
    }
} else {
    Miss 'screen-ocr' '本工具仅支持 Windows（内置 Windows.Media.Ocr）'
}

if ($missing -eq 0) {
    Write-Host "== 4/4 可用 =="
    exit 0
} else {
    Write-Host "== 有工具未就绪，按上方提示安装后重跑 =="
    exit 1
}
