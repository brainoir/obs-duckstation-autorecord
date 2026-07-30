# 🦆 DuckStation Auto-Recorder & No-Edit Video Producer for OBS Studio

A lightweight, zero-dependency Lua script for OBS Studio combined with an AntiMicroX gamepad profile. Designed specifically for **DuckStation** (PS1 Emulator) to enable a **pure, hands-free "Clean Gameplay / Longplay" production workflow** without the need for manual video editing.

---

## 💡 What Is This Setup For?

This setup is built for true old-school gamers, speedrunners, and content creators who want to record **flawless, deathless PS1 playthroughs** (Longplays, No-Damage runs) without touching a keyboard or spending hours cutting video files in heavy editors (Premiere, DaVinci, Vegas).

Forget stopping the game to manage OBS. Forget bad takes ruining a 2-hour recording. With this setup:

* You focus **100% on the game** using only your PS4 controller.
* Successful segments are instantly saved to alternating DuckStation slots **and** split into clean MP4 clips in OBS simultaneously.
* Failed takes are instantly thrown out via `Alt+F4`.
* Final videos are simply joined in **[LosslessCut](https://github.com/mifi/lossless-cut)** with zero re-encoding!

---

## ✨ Key Features

* **🏷️ Dynamic Game Title Auto-Naming:** Automatically reads DuckStation's active window title via Win32 API and names output video files cleanly (e.g., `Tekken 3 - 2026-07-30_15-00-00.mp4`).
* **🎮 100% Gamepad Control (AntiMicroX Integration):** Uses the PS4 **Touchpad** as a dedicated modifier button (`Held` / `Пока нажата`) to map hardware OBS split triggers without sacrificing a single PS1 button.
* **🛡️ Fail-Safe Alternating Saves (`F9` / `F10` Double-Bind):** Never lose progress to a "Death-Save" trap! Alternates between Save Slot 1 and Save Slot 2 safely.
* **🧹 Smart Title Cleaning:** Automatically strips disc IDs (`[SLUS-00404]`), emulator artifacts, and illegal OS characters.
* **⚡ Zero-Latency FFI Architecture:** Written in native Lua using Win32 FFI for minimal system load—ideal for low-end or mid-range PCs.

---

## 🎮 The Ultimate Controller Setup: Touchpad Modifier Logic

Why the PS4 **Touchpad**?
Original PlayStation 1 controllers (Digital & DualAnalog/DualShock 1) only had 14 inputs. The PS4 Touchpad click **did not exist on the original PS1 hardware**.

By using AntiMicroX, we assign the **Touchpad Click** as a high-priority **Set Selector Modifier (`Held` / `Пока нажата`)**. It acts like an invisible `Fn` key that changes the function of the L1 and L2 bumpers *only while physically pressed down*.

```text
========================================================================
                      PS4 TOUCHPAD MODIFIER LOGIC
========================================================================

 [ NORMAL GAMEPLAY ]                             [ MODIFIER HELD ]
 (Touchpad NOT pressed)                        (Touchpad Pressed DOWN)

     L1 = Normal PS1 L1                             L1 = Key F9
     L2 = Normal PS1 L2                             L2 = Key F10
 
 (Game receives native                          (Triggers DuckStation
   PS1 button inputs)                            Save + OBS Video Split)

```

### Double-Bind Hotkey Mapping:

| Combination | Action in DuckStation | Action in OBS Studio | Result |
| --- | --- | --- | --- |
| **Touchpad + L1** | Save State to **Slot 1** (`F9`) | **Stop Recording** (`F9`) | Finalizes current clean MP4 clip & starts a new segment for Slot 1 |
| **Touchpad + L2** | Save State to **Slot 2** (`F10`) | **Stop Recording** (`F10`) | Finalizes current clean MP4 clip & starts a new segment for Slot 2 |

---

## 📥 Installation & Setup

### Step 1: OBS Studio Script Setup

1. Download `duckstation_auto_recorder.lua` from this repository.
2. In OBS Studio, navigate to **Tools** → **Scripts**.
3. Click the **`+`** icon and select `duckstation_auto_recorder.lua`.
4. Add a **Game Capture** (`Захват игры`) source to your active scene and set it to capture DuckStation.
> 📌 **Important:** Always use **Game Capture** instead of Window Capture. It hooks directly into DuckStation's 3D canvas, completely bypassing the launcher/UI windows.


5. In your Game Capture properties:
* Set **Hook Rate** (`Частота захвата`) to **Fastest** (`Самая быстрая`).
* Uncheck **Use anti-cheat compatibility hook** (`Использовать перехватчик, совместимый с античитами`).


6. Go to OBS **Settings** → **Hotkeys** → Find **Stop Recording** (`Остановить запись`).
7. Assign **BOTH** `F9` and `F10` to **Stop Recording** (click the `+` icon next to the keybind to add a second key).

### Step 2: DuckStation Emulator Configuration

1. Open DuckStation **Settings** (`Настройки`) → **Hotkeys** (`Горячие клавиши`).
2. Map **Save State (Slot 1)** (`Сохранить состояние в ячейку 1`) to **`F9`**.
3. Map **Save State (Slot 2)** (`Сохранить состояние в ячейку 2`) to **`F10`**.
4. Go to **Settings** → **Interface** (`Интерфейс`):
* Uncheck **Confirm Power Off / Exit** (`Запрашивать подтверждение при выключении / закрытии`).
* Uncheck **Save State on Exit** (`Сохранять состояние при выходе / выключении`).



### Step 3: AntiMicroX Controller Mapping

1. Install **[AntiMicroX](https://github.com/AntiMicroX/antimicrox)**.
2. Copy the included configuration file `ps4_TP+(L1=F9, L2=F10).gamecontroller.amgp` to your AntiMicroX profiles folder (or open it directly via **Load** / `Загрузить`).
3. Verify that:
* **Touchpad** is configured to `Set Set 2 Held` (`Установить набор 2 Пока нажато`).
* In **Set 2**, **L1 / Left Bumper** is mapped to **`F9`**.
* In **Set 2**, **L2 / Left Trigger** is mapped to **`F10`**.


4. Minimize AntiMicroX to system tray.

---

## 🛠️ The Game Loop: How to Play and Record

Once configured, put your keyboard away. You are ready for a hands-free recording session:

```text
                   [ START GAMEPLAY / MISSION ]
                     (OBS is Auto-Recording)
                                |
             +------------------+------------------+
             |                                     |
      (Mission Success)                     (Mission Failed)
             |                                     |
  1. Hold Touchpad + Press L1            1. Hit Alt+F4 on keyboard
     (Saves Slot 1 + Splits Video)          (Close DuckStation instantly)
             OR                                    |
  2. Hold Touchpad + Press L2            2. Delete bad take MP4 file
     (Saves Slot 2 + Splits Video)                 |
             |                           3. Relaunch DuckStation,
    OBS Script Instantly                    load safe slot & retry
    Starts NEW Recording
             |
             v
   Clean MP4 clip saved! 
  Continue to next section.

```

### Workflow Rules:

1. **Alternating Slot Strategy:**
* Complete Section 1 → Press **Touchpad + L1** (Saves Slot 1, splits MP4).
* Complete Section 2 → Press **Touchpad + L2** (Saves Slot 2, splits MP4).
* Alternate back and forth. If you ever panic-save right as you take damage or die, your previous segment's save is completely untouched in the alternate slot!


2. **Failing a Take:**
* If you make a mistake, die, or ruin a segment, close DuckStation via `Alt+F4`. Delete the single bad MP4 take from your recording folder, relaunch DuckStation, load your last valid save slot, and continue.


3. **Mastering the "Invisible Cut":**
* Video encoders (like NVENC or x264) split at Keyframes (I-Frames). To make your video cuts 100% invisible when joined together, always trigger your save/split combo during **loading screens, black transitions, static camera cuts, or menu screens**.


4. **Ending Your Session (Trailing File Cleanup):**
* Because the OBS script automatically starts a new recording immediately whenever a split occurs, closing the game will leave one tiny trailing "junk" video file at the end of your session. Simply delete this final file, open **LosslessCut**, drop all your valid MP4 clips in, and click **Merge**!



---

## 🖥️ System Requirements

* **OS:** Windows 10 / 11 (64-bit)
* **OBS Studio:** 28.0+ or newer
* **Emulator:** DuckStation (Qt Version)
* **Gamepad Mapper:** AntiMicroX 3.1+

---

## 📄 License

Distributed under the MIT License. See `LICENSE` for more information.
