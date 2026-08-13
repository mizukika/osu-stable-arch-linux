# osu! Stable — Arch Linux Installer

<p align="center">
  <img src="https://img.shields.io/badge/OS-Arch%20Linux-blue?logo=arch-linux&style=for-the-badge" alt="Arch Linux" />
  <img src="https://img.shields.io/badge/Wine-osu!%20Stable-maroon?logo=wine&style=for-the-badge" alt="Wine osu" />
  <img src="https://img.shields.io/badge/Audio-PipeWire%20Low--Latency-brightgreen?logo=pipewire&style=for-the-badge" alt="PipeWire" />
  <img src="https://img.shields.io/badge/Shell-Bash-4EAA25?logo=gnu-bash&style=for-the-badge" alt="Bash" />
</p>

An automated, feature-rich Wine installation manager and performance optimizer for **osu! Stable** on **Arch Linux**.

**English** | [Русский](README.ru.md)

<details>
<summary><b>Читать на русском / Read in Russian</b></summary>

Полная документация на русском языке доступна в файле [README.ru.md](README.ru.md).

</details>

---

## Why This Exists

I couldn't find a hassle-free, convenient osu! installer for Arch Linux that just works out of the box and automatically resolves all the dependency, audio, and Wine issues that usually pop up along the way — so I decided to build my own.

---

## Features

- **Automated Setup**: Downloads custom Wine, configures a 32-bit Wine prefix with required `.NET Framework 4.5` and graphics libraries automatically.
- **Low-Latency PipeWire Audio**: Built-in audio presets (Safe, Balanced, Low, Ultra) and custom `STAGING_AUDIO_*` tuning to achieve sub-millisecond audio response without crackle.
- **Desktop & MIME Integration**: Full support for opening `.osz` (beatmaps), `.osk` (skins), `.osr` (replays), `.osu`, `.osb` files and `osu://` web links directly from your browser.
- **System Preflight & Auto-Fix**: Automatically scans your system for missing multilib libraries, PipeWire user services, and offers one-click package installation.
- **GPU Detection**: Auto-detects NVIDIA, AMD, or Intel graphics drivers and configures optimal environment flags (`__GL_THREADED_OPTIMIZATIONS`, `vblank_mode=0`).
- **Multilingual Interface**: Built-in support for English and Russian terminal UI.

---

## Requirements

Before running the installer, ensure you have:
1. An **Arch Linux** installation (or Arch-based distribution such as EndeavourOS, CachyOS, or Manjaro).
2. The `[multilib]` repository enabled in `/etc/pacman.conf` (required for 32-bit Wine libraries).
3. `sudo` privileges for package installation.

---

## Quick Start

### Option 1: Install via AUR (Arch User Repository)

```bash
yay -S osu-stable-arch-git
osu-install
```

### Option 2: Clone or Download the Script

```bash
git clone https://github.com/mizukika/osu-stable-arch.git
cd osu-stable-arch
chmod +x osu-install.sh
./osu-install.sh
```

Choose **`01. Install / update osu!`** from the main menu and follow the on-screen instructions.

---

## Usage Guide

Once installed, you can launch osu! directly from your application menu or via terminal:

| Command | Description |
| :--- | :--- |
| `osu` | Launch osu! Stable with low-latency audio environment |
| `osukill` | Force close all stuck Wine & osu! processes |
| `./osu-install.sh` | Open the interactive management menu |

---

## Command-Line Flags

The script supports automated non-interactive commands for scripting and quick actions:

```bash
./osu-install.sh --install       # Run full automated installation
./osu-install.sh --preflight     # Run system check & install missing packages
./osu-install.sh --audio         # Open low-latency PipeWire audio menu
./osu-install.sh --repair        # Re-register file handlers and desktop entries
./osu-install.sh --status        # Show current installation status
./osu-install.sh --kill          # Kill all running Wine processes
```

---

## Low-Latency Audio Tuning (PipeWire)

To reduce audio delay and eliminate latency, select **Option 7** (`Low-latency audio`) in the main menu:

| Preset | PipeWire Quantum | STAGING Period | Best For |
| :--- | :--- | :--- | :--- |
| **Safe** | 256 (~5.3ms) | 20000 µs | Standard hardware / avoid audio crackle |
| **Balanced** | 128 (~2.7ms) | 13333 µs | **Recommended** for most gaming setups |
| **Low** | 64 (~1.3ms) | 6666 µs | Competitive play / high-end CPU |
| **Ultra** | 32 (~0.67ms) | 3333 µs | Extreme low-latency experiments |

> **Tip:** You can check active buffer sizes at any time during gameplay by running `pw-top` in a terminal.

---

## Troubleshooting & FAQ

<details>
<summary><b>1. Error: <code>target not found: lib32-pipewire</code> or missing multilib packages</b></summary>

Make sure the 32-bit `[multilib]` repository is enabled in `/etc/pacman.conf`:

```bash
sudo sed -i '/^#\[multilib\]/,/^$/{s/^#//}' /etc/pacman.conf
sudo pacman -Sy
```
</details>

<details>
<summary><b>2. Game fails with <code>Wine Mono is not installed</code></b></summary>

osu! requires Microsoft `.NET Framework 4.5`. Run Option 1 in the menu or manually install it via `winetricks`:

```bash
sudo pacman -S --needed cabextract
WINEPREFIX=$HOME/.wineosu WINEARCH=win32 winetricks -q dotnet45 gdiplus cjkfonts
```
</details>

<details>
<summary><b>3. Audio crackling or stuttering</b></summary>

If you experience audio crackle on lower quantum settings, switch to a higher preset (such as **Balanced** or **Safe**) in the Audio Menu, or increase `STAGING_AUDIO_PERIOD` manually.
</details>

---

## Uninstallation

To cleanly remove osu!, its Wine prefix, custom scripts, and desktop entries:

1. Run `./osu-install.sh`.
2. Select **`06. Uninstall osu!`**.
3. Type `DELETE` when prompted.

---

## Credits & Author

- **Maintainer:** [exteraDere](https://osu.ppy.sh/users/39692242) *(noob who plays terribly)*
- **Original Guide:** Based on the [osu-on-linux](https://github.com/Vudek/osu-on-linux/blob/main/README.md) guide created by [Vudek](https://osu.ppy.sh/users/8816345/osu).

---

## License

Distributed under the MIT License. Feel free to modify and distribute.
