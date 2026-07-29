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

---

## ⚙️ Recommended DuckStation Settings (Required for Alt+F4 Workflow)

To ensure **Alt+F4** closes the emulator instantly without prompting or saving bad/failed attempts:

1. Open DuckStation **Settings** (`Настройки`) → **Interface** (`Интерфейс`).
2. Uncheck **Confirm Power Off / Exit** (`Запрашивать подтверждение при выключении / закрытии`).
3. Uncheck **Save State on Exit** (`Сохранять состояние при выходе / выключении`).

---

## 🛠️ How It Works (Fail-Safe Recording Workflow)

Using just one hotkey (**`F2`** to Save State), this linear workflow ensures 100% clean recordings per mission/level:

```
                  [ Play Mission / Level ]
                 (OBS is Auto-Recording)
                            |
              +-------------+-------------+
              |                           |
       (Mission Success)            (Mission Failed)
              |                           |
       1. Press F2 to Save          1. Press Alt+F4 Instantly
       2. Press Alt+F4 to Close     2. Delete the Bad MP4 File
              |                           |
       Keeps Clean MP4 File         (Ready to reload and retry)
              |
              v
   [ Batch-Merge Clean MP4s ]
        in LosslessCut
```

* **On Success:** Finish the mission $\rightarrow$ press **`F2`** to save your clean progress $\rightarrow$ hit **`Alt+F4`** to close DuckStation and finalize the MP4 file.
  > ⚠️ **DO NOT click "Stop Recording" in the OBS UI!** If your auto-record trigger is active, hitting stop manually will just instantly start a new recording loop because the game is still running. Always use `Alt+F4` to cleanly cut the recording.
* **On Failure (Death/Mistake):** Hit **`Alt+F4`** instantly. Delete the single bad MP4 take, relaunch DuckStation, and try again from your last clean state!

---

## 🖥️ System Requirements

- **OS:** Windows 10 / 11 (64-bit)
- **OBS Studio:** 28.0+ or newer
- **Emulator:** DuckStation (Qt version)

---

## 📄 License

Distributed under the MIT License. See `LICENSE` for more information.
