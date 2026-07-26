# 🦆 DuckStation Auto-Recorder & Dynamic Namer for OBS Studio

A lightweight, zero-dependency Lua script for OBS Studio that automates recording and file naming specifically for the **DuckStation** PS1 emulator. Designed with a **LosslessCut** workflow in mind for low-end PCs and rapid content creation without heavy video editors.

---

## 💡 Why This Script?

Traditional recording often requires manual clipping, complex scene switchers, or heavy video editing software (Premiere, DaVinci, Vegas) that can strain low-end or mid-range PCs. 

This script enables a **Play → Alt+F4 → Direct Merge** workflow:
1. Launch DuckStation and start playing. Recording starts **automatically** only when 3D rendering begins.
2. Stop playing instantly by pressing **Alt+F4** or exiting to the launcher. The recording terminates cleanly within milliseconds without trailing black frames or frozen video.
3. Your output videos are automatically named after the actual game title (e.g., `Ace Combat 2 - 2026-07-26_17-00-00.mp4`).
4. Simply open your output folder, sort by name or date, delete bad takes, and batch-join your clean MP4 files instantly in **[LosslessCut](https://github.com/mifi/lossless-cut)** without re-encoding!

---

## ✨ Key Features

- **⚡ Instant Start & Stop:** Auto-starts recording when a game boots up, and stops cleanly within ~100-300ms upon closing or pressing `Alt+F4`.
- **🏷️ Dynamic Game Title Detection:** Automatically sets the output filename formatting prefix to the current game's title (strips disc IDs like `[SLUS-00404]` and invalid OS characters).
- **🛡️ Smart Dialog & UI Filtering:** Strictly ignores DuckStation's main launcher window, background Qt windows (`_q_titlebar`, `Temp Window`), and modal dialogs like *"Resume Save State"* or *"Settings"* to prevent false starts or corrupted takes.
- **🌐 UTF-8 Crash Protection:** Built-in Win32 API Unicode (`GetWindowTextW` → `WideCharToMultiByte`) conversion prevents `obs-websocket` and OBS crashes when game titles or system prompts contain non-ASCII (Cyrillic, CJK, etc.) characters.
- **🚀 Ultra Lightweight:** Zero external plugins required. Native Lua execution with built-in memory buffer protection.

---

## 📥 Installation

1. Download [`duckstation_auto_recorder.lua`](./duckstation_auto_recorder.lua) from this repository.
2. In OBS Studio, go to **Tools** → **Scripts**.
3. Click the **`+`** icon in the bottom-left corner and select `duckstation_auto_recorder.lua`.
4. Make sure your DuckStation capture source (Window Capture or Game Capture) is active in your OBS scene.
5. You're all set!

---

## 🛠️ How It Works (LosslessCut Workflow)

```
[ DuckStation ] --(Play Game)--> OBS Auto-Starts + Sets Filename ("Ace Combat 2 - Date")
        |
   (Press Alt+F4)
        |
        v
OBS Auto-Stops cleanly (~100ms) --> MP4 file saved ready for LosslessCut!
```

---

## 🖥️ System Requirements

- **OS:** Windows 10 / 11 (64-bit)
- **OBS Studio:** 28.0+ or newer
- **Emulator:** DuckStation (Qt version)

---

## 📄 License

Distributed under the MIT License. See `LICENSE` for more information.
