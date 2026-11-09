# Builds output\InExXen-Setup.exe from scratch.
#   powershell -ExecutionPolicy Bypass -File build.ps1 [-UODir "C:\Program Files\Ultima Online 2D"]
# Steps: download ClassicUO + Razor CE, copy UO data from a reference install
# (read only, never modified), compile InExXen.iss with Inno Setup 6.
param(
    [string]$UODir = "C:\Program Files\Ultima Online 2D",
    [string]$Iscc = "$env:LOCALAPPDATA\Programs\Inno Setup 6\ISCC.exe"
)
$ErrorActionPreference = 'Stop'
$root = $PSScriptRoot
$dl = Join-Path $root 'downloads'
$stage = Join-Path $root 'stage\InExXen'

$ClassicUOUrl = 'https://github.com/ClassicUO/ClassicUO/releases/download/ClassicUO-main-release/ClassicUO-win-x64-release.zip'
$RazorUrl = 'https://github.com/markdwags/Razor/releases/download/v1.9.77.0/Razor-x64-1.9.77.0.zip'

if (-not (Test-Path (Join-Path $UODir 'tiledata.mul'))) { throw "No UO data in $UODir" }
if (-not (Test-Path $Iscc)) { throw "Inno Setup not found: $Iscc (winget install JRSoftware.InnoSetup)" }

New-Item -ItemType Directory -Force $dl | Out-Null
if (Test-Path $stage) { Remove-Item -Recurse -Force $stage }
New-Item -ItemType Directory -Force "$stage\UO\Music\Digital", "$stage\Data\Plugins\Razor" | Out-Null

[Net.ServicePointManager]::SecurityProtocol = [Net.SecurityProtocolType]::Tls12
foreach ($u in $ClassicUOUrl, $RazorUrl) {
    $f = Join-Path $dl ([IO.Path]::GetFileName($u))
    if (-not (Test-Path $f)) { Write-Host "Downloading $u"; Invoke-WebRequest $u -OutFile $f -UseBasicParsing }
}
Expand-Archive (Join-Path $dl 'ClassicUO-win-x64-release.zip') $stage -Force
Expand-Archive (Join-Path $dl 'Razor-x64-1.9.77.0.zip') "$stage\Data\Plugins\Razor" -Force
Get-ChildItem $stage -Recurse -Include *.pdb, *.nsi, *.nsh | Remove-Item -Force

# UO data: everything ClassicUO reads; skip EA executables, UO3D files, personal config.
$skip = @('*.exe', '*.dll', '*.zip', '*.bin', 'Blueprints.tbp', 'Login.cfg', 'uo.cfg', 'Uoreg.cfg',
    'Uoupg.cfg', 'Uomax.cfg', 'chardata.mul', 'Ignore.lst', 'macros.txt', 'macros2d.txt', 'Umacros.txt',
    'metrics.txt', 'desktop.nwb', 'Default.mac', 'Vercfg', 'Verinfo', 'Version.dat', 'Version.txt',
    'entitled.def', 'Readme.txt')
Get-ChildItem $UODir -File | Where-Object { $n = $_.Name; -not ($skip | Where-Object { $n -like $_ }) } |
    Copy-Item -Destination "$stage\UO"
Copy-Item "$UODir\music\digital\*" "$stage\UO\Music\Digital"

& $Iscc /Q (Join-Path $root 'InExXen.iss')
if ($LASTEXITCODE -ne 0) { throw "ISCC failed ($LASTEXITCODE)" }
Get-Item (Join-Path $root 'output\InExXen-Setup.exe') | Select-Object Name, Length
