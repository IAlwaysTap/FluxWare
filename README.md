<div align="center">

# ⚡ FluxWare

**A high-quality Roblox script collection for advanced players.**

![Version](https://img.shields.io/badge/version-1.0.0-blue?style=for-the-badge)
![Scripts](https://img.shields.io/badge/scripts-3-brightgreen?style=for-the-badge)
![Platform](https://img.shields.io/badge/platform-Roblox-red?style=for-the-badge)

</div>

---

## 📖 Table of Contents

- [Overview](#-overview)
- [Scripts](#-scripts)
  - [Prison Life](#-prison-life)
  - [Blade Ball](#-blade-ball)
  - [Escape a Brainrot](#-escape-a-brainrot)
- [Features at a Glance](#-features-at-a-glance)
- [Keybind Reference](#-keybind-reference)
- [How to Use](#-how-to-use)
- [Configuration](#-configuration)
- [Disclaimer](#-disclaimer)

---

## 🌐 Overview

FluxWare is a curated Lua script hub targeting popular Roblox games. Each script is independently structured with a clean **Config table** at the top — making customization straightforward without needing to touch the core logic. All scripts are designed to be loaded via any standard Roblox script executor.

---

## 📁 Scripts

All scripts live inside the `fluxware/` folder.

```
fluxware/
├── prisonlife.lua
├── bladeball.lua
└── escapeabrainrot.lua
```

---

### 🔒 Prison Life

**File:** `fluxware/prisonlife.lua`
**Game:** [Prison Life v2.0.2](https://www.roblox.com/games/155615604/Prison-Life-v2-0-2)

A full-featured script for Prison Life packed with movement hacks, ESP, aimbot, and quality-of-life improvements.

| Feature | Description |
|---|---|
| **Player ESP** | Renders name tags and distances above all players through walls |
| **Speed Hack** | Increases walk speed to a configurable value (default 50) |
| **No Clip** | Disables collision, letting you walk through any part |
| **Fly** | Full 6-DoF flight using WASD + Space/Ctrl with camera-relative movement |
| **Aimbot** | Smooth camera lock-on to the nearest visible player's head |
| **Infinite Stamina** | Keeps the stamina stat maxed out at all times |

**Keybinds**

| Key | Feature |
|---|---|
| `F1` | Toggle Player ESP |
| `F2` | Toggle Speed Hack |
| `F3` | Toggle No Clip |
| `F4` | Toggle Fly |
| `F5` | Toggle Aimbot |
| `F6` | Toggle Infinite Stamina |

---

### ⚔️ Blade Ball

**File:** `fluxware/bladeball.lua`
**Game:** [Blade Ball](https://www.roblox.com/games/13772394625/Blade-Ball)

Precision tooling for Blade Ball. The standout feature is the **Auto Parry** — it detects ball velocity and direction, then fires the parry remote only when the ball is incoming.

| Feature | Description |
|---|---|
| **Auto Parry** | Automatically parries the ball when it enters range and is heading toward you |
| **Ball ESP** | Highlights the ball with a visible selection box (always-on-top) |
| **Player ESP** | Name + distance tags over all players |
| **Speed Hack** | Configurable walk speed boost |
| **Fly** | Camera-relative 6-DoF flight |
| **No Clip** | Pass through all parts |

**Keybinds**

| Key | Feature |
|---|---|
| `F1` | Toggle Auto Parry |
| `F2` | Toggle Ball ESP |
| `F3` | Toggle Player ESP |
| `F4` | Toggle Speed Hack |
| `F5` | Toggle Fly |
| `F6` | Toggle No Clip |

---

### 🧠 Escape a Brainrot

**File:** `fluxware/escapeabrainrot.lua`
**Game:** Escape a Brainrot

The most feature-rich script in the collection, designed for the Escape a Brainrot genre. Includes automatic enemy avoidance, item collection, and survival utilities.

| Feature | Description |
|---|---|
| **Auto Escape** | Teleports the player away when a brainrot entity gets within a configurable range |
| **Auto Collect** | Automatically teleports to and collects nearby coins/items |
| **Enemy ESP** | Red highlights on all enemy models, visible through walls |
| **Item ESP** | Gold highlights on all collectible items |
| **Player ESP** | Cyan name + distance labels over other players |
| **Speed Hack** | Configurable walk speed |
| **Fly** | Camera-relative flight |
| **No Clip** | Walk through walls and obstacles |
| **Infinite Jump** | Re-triggers jump state on every jump request |
| **God Mode** | Continuously restores health to max every frame |

**Keybinds**

| Key | Feature |
|---|---|
| `F1` | Toggle ESP (players + enemies + items) |
| `F2` | Toggle Auto Escape |
| `F3` | Toggle Auto Collect |
| `F4` | Toggle Speed Hack |
| `F5` | Toggle Fly |
| `F6` | Toggle No Clip |
| `F7` | Toggle Infinite Jump |
| `F8` | Toggle God Mode |

---

## ⚡ Features at a Glance

| Feature | Prison Life | Blade Ball | Escape a Brainrot |
|---|:---:|:---:|:---:|
| Player ESP | ✅ | ✅ | ✅ |
| Speed Hack | ✅ | ✅ | ✅ |
| Fly | ✅ | ✅ | ✅ |
| No Clip | ✅ | ✅ | ✅ |
| Aimbot | ✅ | ❌ | ❌ |
| Auto Parry | ❌ | ✅ | ❌ |
| Ball ESP | ❌ | ✅ | ❌ |
| Auto Escape | ❌ | ❌ | ✅ |
| Auto Collect | ❌ | ❌ | ✅ |
| Enemy ESP | ❌ | ❌ | ✅ |
| Item ESP | ❌ | ❌ | ✅ |
| Infinite Jump | ❌ | ❌ | ✅ |
| God Mode | ❌ | ❌ | ✅ |
| Infinite Stamina | ✅ | ❌ | ❌ |

---

## ⌨️ Keybind Reference

All keybinds work the same way: press the key to **toggle** the feature on or off. An in-game notification will confirm the new state.

- Fly controls: **W/A/S/D** (direction) + **Space** (up) + **Left Ctrl** (down)
- All binds are **client-side only** — they will not fire if a GUI element has focus

---

## 🚀 How to Use

1. **Get an executor** — FluxWare requires a script executor (e.g., Synapse X, Fluxus, KRNL, Delta, Codex).
2. **Copy the script content** from the relevant `.lua` file inside the `fluxware/` folder.
3. **Paste it** into your executor and attach to Roblox.
4. **Execute** — you will see a notification confirming the script loaded successfully.
5. **Use keybinds** to toggle features on/off at any time.

> **Tip:** You can also load scripts directly with `loadstring(game:HttpGet("RAW_URL"))()` using the raw GitHub URL of each script.

---

## ⚙️ Configuration

Each script has a `Config` table at the very top of the file. You can edit these values before executing to pre-configure any feature:

```lua
-- Example: change fly speed and enable it on load in bladeball.lua
local Config = {
    Fly = {
        Enabled = true,   -- auto-enable on load
        Speed = 80,       -- faster flight
    },
    ...
}
```

Key configurable values per script:

| Script | Config Key | Default | Description |
|---|---|---|---|
| All | `Speed.Value` | 40–50 | Walk speed when Speed Hack is on |
| All | `Fly.Speed` | 55–60 | Flight speed |
| Prison Life | `Aimbot.FOV` | 150 | Aimbot field-of-view radius (px) |
| Prison Life | `Aimbot.Smoothness` | 0.1 | Lerp factor (lower = smoother) |
| Blade Ball | `AutoParry.Delay` | 0 | Seconds to wait before auto-parrying |
| Blade Ball | `AutoParry.Range` | 30 | Ball detection range in studs |
| Escape a Brainrot | `AutoEscape.SafeDistance` | 40 | Enemy proximity threshold in studs |
| Escape a Brainrot | `AutoCollect.Range` | 50 | Item collection range in studs |

---

## ⚠️ Disclaimer

> FluxWare is provided **for educational purposes only**.  
> Using scripts in Roblox games may violate the [Roblox Terms of Service](https://en.help.roblox.com/hc/en-us/articles/115004647846) and can result in account moderation.  
> The authors of FluxWare take **no responsibility** for any actions taken against your account.  
> Use at your own risk.