# In Ex Xen Client

> **This repo is archived.** The In Ex Xen client now lives at
> [JilliansSoftware/InExXenclient](https://github.com/JilliansSoftware/InExXenclient)
> (installer in `installer/`, releases there). The v1.0 download below still works.

All-in-one Windows installer for the **In Ex Xen** Ultima Online shard (`play.inexxen.com:2593`):
ClassicUO + Razor Community Edition + the shard's UO data. Players need nothing else: no EA
installer, patch, DirectX or vcredist. ClassicUO's host uses .NET Framework 4.7.2, which ships
with Windows 10/11.

## Players
Download `InExXen-Setup.exe` from the [latest release](../../releases/latest), run it, play.
It installs per user to `%LOCALAPPDATA%\InExXen` (no admin prompt). Reinstalling a newer
version keeps your settings.

## What's inside
- **ClassicUO** (official main-release build, win-x64)
- **Razor CE** x64 1.9.77.0, loaded as a ClassicUO plugin
- **UO data** (client 5.0.6.5): the AOS 2003 install with the 2006 patch and digital MP3 music.
  Map/statics/tiledata/multi/hues/cliloc match the shard server's files exactly.
- `settings.json`, written on first install: server, client version, data path, Razor plugin.

## Building
Requirements: a reference UO install (default `C:\Program Files\Ultima Online 2D`, only read)
and Inno Setup 6 (`winget install JRSoftware.InnoSetup`).

```powershell
powershell -ExecutionPolicy Bypass -File build.ps1
```

This downloads ClassicUO and Razor, stages them with the UO data in `stage\`, and compiles
`InExXen.iss` into `output\InExXen-Setup.exe`. Game data is not stored in this repo; the
installer is attached to each GitHub release.

Left out of the data copy: EA executables/DLLs, UO3D-only files (`*.bin`, Granny.dll,
Blueprints.tbp), personal config (Login.cfg, uo.cfg, macros, Desktop\) and the MIDI music.

## Releasing
1. Bump `AppVersion` in `InExXen.iss`.
2. Run `build.ps1`.
3. Tag `vX.Y`, push, and attach `output\InExXen-Setup.exe` to the GitHub release.
