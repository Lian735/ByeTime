# ByeTime

ByeTime is a lightweight macOS menu-bar sleep timer. Set a duration or pick a target time, and ByeTime will put your Mac to sleep when the countdown finishes. It is designed for quick setup, a clean menu-bar workflow, and predictable sleep scheduling so you can step away without leaving your Mac running all night.

> ⚠️ Note: ByeTime triggers an immediate sleep (`pmset sleepnow`) when the timer finishes. Save your work beforehand.

## Highlights

- **Menu-bar timer** with a compact popover UI.
- **Two timer modes**: countdown duration or a target time.
- **Quick presets** for your most common durations.
- **Sleep-time hint** shows the exact time your Mac will sleep.
- **Menu-bar animation styles** (rotating, pulsating, or off).

## Requirements

- macOS 26.2+ (Tahoe)

## Installation

The author’s installation walkthrough is available here:

- 🎥 **Installation tutorial**: https://www.youtube.com/watch?v=veaml3lK3_8

## How to Install

1. Go to the [Releases](../../releases)
2. Download the latest `.dmg` file
3. Drag **ByeTime.app** into the **Applications** folder
4. Open **ByeTime** from the Applications folder
5. A warning will show up
6. Go to **System Settings → Privacy & Security** → scroll down until you see “ByeTime was blocked to protect your Mac.” → click **Open Anyway**

➡️ It should work now!

If it doesn't work or you have questions, join my [Discord Server](https://discord.gg/u63YhXD3pC).

## First-Run Setup

1. Click the **ByeTime** icon in the menu bar to open the popover.
2. Choose a timer mode:
   - **Duration**: set hours and minutes.
   - **Target time**: pick the time you want the Mac to sleep.
3. Optional: adjust your preset buttons in **Settings**.
4. Click **Start Timer**.

While the timer is running, the menu-bar icon animates (based on your selected style) and the remaining time updates every second.

## Timer Modes

### Duration

Use the steppers to set hours and minutes. Use the preset buttons to jump to your saved durations.

### Target Time

Pick a time (up to ~13 hours ahead). ByeTime will calculate the countdown automatically.

## Settings

Open **Settings** from the main popover to customize:

- **Preset durations** (three quick buttons)
- **Show sleep time hint** (display the exact time your Mac will sleep)
- **Menu bar animation** style while a timer runs

Settings are saved automatically.

## Tips & Troubleshooting

- If the timer ends and your Mac doesn’t sleep, make sure ByeTime is still running in the menu bar and that the timer hasn’t been stopped.
- Use **Target time** for a bedtime cutoff and **Duration** for quick naps.
- Save open work before starting a timer—ByeTime will put the Mac to sleep immediately when the countdown reaches zero.
