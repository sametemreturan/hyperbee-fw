<#
.SYNOPSIS
  hyperbee-fw projesini STM32CubeIDE arayuzu acmadan (headless) derler.

.DESCRIPTION
  STM32CubeIDE'nin komut satiri surumu (stm32cubeidec.exe) ve Eclipse CDT'nin
  headless build uygulamasiyla projeyi gecici bir calisma alanina ice aktarir,
  temizleyip derler, ardindan .elf boyutunu arm-none-eabi-size ile yazdirir.
  Gecici calisma alani is bitince silinir; kullanicinin kendi workspace'i etkilenmez.

  Basari olcutu: arac cikis kodu 0, gunlukte "0 errors", .elf dosyasi var.
  Gunluk: <repo>\build\build-<Proje>-<Config>.log  (build/ git'e girmez)

.PARAMETER Project
  firmware\ altindaki proje klasorunun (ve Eclipse projesinin) adi.

.PARAMETER Config
  Derleme yapilandirmasi: Debug ya da Release.

.PARAMETER CubeIdeDir
  stm32cubeidec.exe'nin bulundugu klasor. Verilmezse once CUBEIDE_DIR ortam
  degiskenine, sonra C:\ST\STM32CubeIDE_<surum>\STM32CubeIDE altindaki en yeni
  surume bakilir.

.EXAMPLE
  powershell -ExecutionPolicy Bypass -File tools\build.ps1
.EXAMPLE
  powershell -ExecutionPolicy Bypass -File tools\build.ps1 -Config Release
#>
param(
    [string]$Project = "hb_f446re_bos",
    [ValidateSet("Debug", "Release")]
    [string]$Config = "Debug",
    [string]$CubeIdeDir
)

$ErrorActionPreference = "Stop"
$repo = Split-Path -Parent $PSScriptRoot
$projDir = Join-Path $repo "firmware\$Project"

if (-not (Test-Path -LiteralPath (Join-Path $projDir ".cproject"))) {
    throw "Proje bulunamadi: '$projDir' icinde .cproject yok."
}

# --- STM32CubeIDE'yi bul ---------------------------------------------------
if (-not $CubeIdeDir) { $CubeIdeDir = $env:CUBEIDE_DIR }
if (-not $CubeIdeDir) {
    $adaylar = Get-ChildItem -Path "C:\ST" -Directory -Filter "STM32CubeIDE_*" -ErrorAction SilentlyContinue |
        Where-Object { $_.Name -match '^STM32CubeIDE_(\d+(\.\d+)+)$' } |
        Sort-Object { [version]($_.Name -replace '^STM32CubeIDE_', '') } -Descending
    if (-not $adaylar) { throw "C:\ST altinda STM32CubeIDE bulunamadi. -CubeIdeDir verin ya da CUBEIDE_DIR ayarlayin." }
    $CubeIdeDir = Join-Path $adaylar[0].FullName "STM32CubeIDE"
}
$cli = Join-Path $CubeIdeDir "stm32cubeidec.exe"
if (-not (Test-Path -LiteralPath $cli)) { throw "stm32cubeidec.exe yok: '$cli'" }

$sizeExe = Get-ChildItem -Path (Join-Path $CubeIdeDir "plugins") -Recurse -Depth 4 -Filter "arm-none-eabi-size.exe" -ErrorAction SilentlyContinue |
    Select-Object -First 1

# --- Hazirlik ----------------------------------------------------------------
$logDir = Join-Path $repo "build"
New-Item -ItemType Directory -Force -Path $logDir | Out-Null
$log = Join-Path $logDir "build-$Project-$Config.log"
$ws = Join-Path $env:TEMP ("hbfw_ws_" + [guid]::NewGuid().ToString("N").Substring(0, 8))

Write-Host "STM32CubeIDE : $CubeIdeDir"
Write-Host "Proje        : $projDir ($Config)"
Write-Host "Gecici alan  : $ws"
Write-Host "Gunluk       : $log"

# --- Derle -------------------------------------------------------------------
$cliArgs = @(
    "--launcher.suppressErrors", "-nosplash",
    "-application", "org.eclipse.cdt.managedbuilder.core.headlessbuild",
    "-data", $ws,
    "-import", $projDir,
    "-cleanBuild", "$Project/$Config",
    "-printErrorMarkers",
    "-no-indexer"
)
$sw = [Diagnostics.Stopwatch]::StartNew()
$ErrorActionPreference = "Continue"   # aracin stderr ciktisi hata sayilmasin; sonucu asagida biz degerlendiririz
& $cli @cliArgs 2>&1 | ForEach-Object { "$_" } | Tee-Object -FilePath $log
$exit = $LASTEXITCODE
$ErrorActionPreference = "Stop"
$sw.Stop()
Remove-Item -LiteralPath $ws -Recurse -Force -ErrorAction SilentlyContinue

# --- Degerlendir -------------------------------------------------------------
$elf = Join-Path $projDir "$Config\$Project.elf"
$text = Get-Content -LiteralPath $log -Raw
$ozet = [regex]::Matches($text, "(\d+) errors?, (\d+) warnings?") | Select-Object -Last 1
$hataSayisi = if ($ozet) { [int]$ozet.Groups[1].Value } else { -1 }

Write-Host ""
Write-Host ("Sure: {0:N0} sn | Arac cikis kodu: {1} | Derleme ozeti: {2}" -f $sw.Elapsed.TotalSeconds, $exit, $(if ($ozet) { $ozet.Value } else { "bulunamadi" }))

if ($exit -ne 0 -or $hataSayisi -ne 0 -or -not (Test-Path -LiteralPath $elf)) {
    Write-Host "SONUC: DERLEME BASARISIZ (ayrinti: $log)" -ForegroundColor Red
    exit 1
}

Write-Host "ELF: $elf"
if ($sizeExe) {
    $sizeOut = & $sizeExe.FullName $elf
    $sizeOut | ForEach-Object { Write-Host $_ }
    Add-Content -LiteralPath $log -Value "`r`n--- arm-none-eabi-size ---`r`n$($sizeOut -join "`r`n")"
}
Write-Host "SONUC: DERLEME BASARILI" -ForegroundColor Green
exit 0
