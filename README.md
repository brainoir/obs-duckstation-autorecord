# 🦆 DuckStation Auto-Recorder & Dynamic Namer for OBS Studio

A lightweight, zero-dependency Lua script for OBS Studio that automates recording and output file naming specifically for the **DuckStation** PS1 emulator. Designed with a **LosslessCut** workflow in mind for low-end PCs and rapid content creation without heavy video editors.

---

## 💡 Why This Script?

Traditional recording often requires manual clipping, complex scene switchers, or heavy video editing software (Premiere, DaVinci, Vegas) that can strain low-end or mid-range PCs. 

This script enables a **Play → Alt+F4 → Direct Merge** workflow:
1. Launch DuckStation and start playing.
2. Hit Record in OBS (or trigger it automatically) — the script instantly detects DuckStation's running game window title.
3. Your output video is dynamically named after the clean game title (e.g., `Ace Combat 2 - 2026-07-27_14-30-00.mp4`).
4. Stop playing instantly by pressing **Alt+F4** or exiting to the launcher. The recording terminates cleanly within milliseconds without trailing black frames or frozen video.
5. Simply open your output folder, sort by name or date, delete bad takes, and batch-join your clean MP4 files instantly in **[LosslessCut](https://github.com/mifi/lossless-cut)** without re-encoding!

---

## ✨ Key Features

- **🏷️ Dynamic Game Title Auto-Naming:** Hooks into OBS's `RECORDING_STARTING` event and inspects DuckStation's active window title via Win32 API. Sets `FilenameFormatting` automatically on the fly.
- **🧹 Smart Title Cleaning:** Strips emulator artifacts, disc IDs (`[SLUS-00404]`, `(SLES-12345)`), background Windows IME windows, and illegal OS filename characters (`/:*?"<>|\`).
- **⚡ Instant Start & Stop:** Auto-starts/stops cleanly without freezing or trailing black screen delays when exiting via `Alt+F4`.
- **🚀 Zero Dependencies:** Built using native Lua and Win32 FFI for ultra-low memory overhead and maximum stability.

---

## 📥 Installation & Setup

1. Download [`duckstation_auto_recorder.lua`](./duckstation_auto_recorder.lua) from this repository.
2. In OBS Studio, go to **Tools** → **Scripts**.
3. Click the **`+`** icon in the bottom-left corner and select `duckstation_auto_recorder.lua`.
4. Add a **Game Capture** source (`Захват игры`) to your active OBS scene and set it to capture DuckStation.
   > 📌 **Important Setup Note:** Make sure to use **Game Capture** (`Захват игры`) rather than Display or Window Capture. Game Capture hooks directly into DuckStation's 3D rendering canvas, ensuring OBS only hooks the actual game viewport and bypasses the main launcher UI completely.
5. You're all set!

---

## 🛠️ How It Works (LosslessCut Workflow)

```
[ DuckStation Launch ] --> OBS Record Triggered --> Script Extracts Clean Title ("Ace Combat 2")
                                                            |
                                                            v
                                            OBS Saves Video as "Ace Combat 2 - Date.mp4"
                                                            |
                                                    (Press Alt+F4)
                                                            |
                                                            v
                                            Ready for instant LosslessCut merge!
```

---

## 🖥️ System Requirements

- **OS:** Windows 10 / 11 (64-bit)
- **OBS Studio:** 28.0+ or newer
- **Emulator:** DuckStation (Qt version)

---

## 📄 License

Distributed under the MIT License. See `LICENSE` for more information.
