# 🦆 DuckStation Auto-Recorder & Dynamic Namer for OBS Studio

A lightweight, zero-dependency Lua script for OBS Studio that automates recording and output file naming specifically for the **DuckStation** PS1 emulator. Designed with a **LosslessCut** workflow in mind for low-end PCs and rapid content creation without heavy video editors.

---

## 💡 Why This Script?

Traditional recording often requires manual clipping, complex scene switchers, or heavy video editing software (Premiere, DaVinci, Vegas) that can strain low-end or mid-range PCs.

This script enables a **Play → F2 (Split) → Alt+F4 → Direct Merge** workflow:

1. Launch DuckStation and start playing.
2. Hit Record in OBS (or trigger it automatically) — the script instantly detects DuckStation's running game window title.
3. Your output video is dynamically named after the clean game title (e.g., `Ace Combat 2 - 2026-07-27_14-30-00.mp4`).
4. Our clever "Double-Bind" workflow automatically splits successful missions into perfect individual clips.
5. Simply open your output folder, sort by name or date, delete bad takes, and batch-join your clean MP4 files instantly in **[LosslessCut](https://github.com/mifi/lossless-cut)** without re-encoding!

---

## ✨ Key Features

* **🏷️ Dynamic Game Title Auto-Naming:** Hooks into OBS's `RECORDING_STARTING` event and inspects DuckStation's active window title via Win32 API. Sets `FilenameFormatting` automatically on the fly.
* **🧹 Smart Title Cleaning:** Strips emulator artifacts, disc IDs (`[SLUS-00404]`, `(SLES-12345)`), background Windows IME windows, and illegal OS filename characters (`/:*?"<>|\`).
* **⚡ Instant Start & Stop:** Auto-starts/stops cleanly without freezing or trailing black screen delays when exiting via `Alt+F4`.
* **🚀 Zero Dependencies:** Built using native Lua and Win32 FFI for ultra-low memory overhead and maximum stability.

---

## 📥 Installation & Setup

1. Download [`duckstation_auto_recorder.lua`](https://www.google.com/search?q=./duckstation_auto_recorder.lua) from this repository.
2. In OBS Studio, go to **Tools** → **Scripts**.
3. Click the **`+`** icon in the bottom-left corner and select `duckstation_auto_recorder.lua`.
4. Add a **Game Capture** source (`Захват игры`) to your active OBS scene and set it to capture DuckStation.
> 📌 **Important Setup Note:** Make sure to use **Game Capture** (`Захват игры`) rather than Display or Window Capture. Game Capture hooks directly into DuckStation's 3D rendering canvas, ensuring OBS only hooks the actual game viewport and bypasses the main launcher UI completely.


5. **⚙️ Critical Game Capture Settings (Fixes Black Screen Delay):** Double-click your Game Capture source and change these settings to ensure the video hooks instantly without audio desync:
* Set **Hook Rate** (`Частота захвата`) to **Fastest** (`Самая быстрая`).
* Uncheck **Use anti-cheat compatibility hook** (`Использовать перехватчик, совместимый с античитами`).


6. **🔥 The Secret Workflow Trick:** Go to OBS **Settings** → **Hotkeys** and assign the **`F2`** key to **"Stop Recording"** (`Остановить запись`). (See *How It Works* below to understand why).

---

## ⚙️ Recommended DuckStation Settings (Required for Alt+F4 Workflow)

To ensure **Alt+F4** closes the emulator instantly without prompting or saving bad/failed attempts:

1. Open DuckStation **Settings** (`Настройки`) → **Interface** (`Интерфейс`).
2. Uncheck **Confirm Power Off / Exit** (`Запрашивать подтверждение при выключении / закрытии`).
3. Uncheck **Save State on Exit** (`Сохранять состояние при выходе / выключении`).

---

## 🛠️ How It Works (The "F2 Double-Bind" Trick)

By assigning **`F2`** to **Stop Recording** in OBS, we match DuckStation’s default **Save State (Slot 1)** hotkey. This creates a powerful, linear workflow that perfectly isolates your successful runs:

```text
                  [ Play Mission / Level ]
                 (OBS is Auto-Recording)
                            |
              +-------------+-------------+
              |                           |
       (Mission Success)            (Mission Failed)
              |                           |
      1. Press F2 instantly!        1. Press Alt+F4 Instantly
   (Saves State + Stops Record)     2. Delete the Bad MP4 File
              |                           |
      OBS Script Instantly          (Ready to reload and retry)
     Starts a NEW Recording
              |
              v
     Clean MP4 saved! Move 
    on to the next mission.


```

### The Logic:

* **On Success:** Finish the level/mission and press **`F2`**. DuckStation will safely save your state, and OBS will instantly stop the recording, finalizing your perfect run into a clean MP4 file.
> *Note:* Because the script is designed to always record when the game is running, stopping the recording via `F2` will immediately trigger the script to **start a new recording**. This is not a bug; it's a feature that prepares OBS for your next mission automatically!


* **On Failure (Death/Mistake):** Hit **`Alt+F4`** instantly. Delete the single bad MP4 take, relaunch DuckStation, load your last save, and try again!

> ⚠️ **The "Junk File" Caveat:** Because pressing `F2` stops the current recording and instantly starts a new one, when you decide to finally end your gaming session by pressing `Alt+F4`, that *very last* video file generated in the background will be an unplanned/invalid clip. You will just need to **manually delete this single trailing junk file** at the end of your session. It's a very small trade-off for a fully automated, hands-free splitting workflow!

---

## 🖥️ System Requirements

* **OS:** Windows 10 / 11 (64-bit)
* **OBS Studio:** 28.0+ or newer
* **Emulator:** DuckStation (Qt version)

---

## 📄 License

Distributed under the MIT License. See `LICENSE` for more information.
