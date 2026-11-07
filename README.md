![FFXI Questlog](images/banner.png)

# FFXI Questlog

**Author:** Guabancex &nbsp;·&nbsp; **Version:** 3.20.0 &nbsp;·&nbsp; **For:** Ashita v4 — Final Fantasy XI

A quest and mission helper that reads your own quest log, mission log and key
items and shows, at a glance, **which step you're on**, **what you've already
done**, and **where the NPCs are** — zone, coordinates, and (when you're in the
zone) how far and which way.

It only reads what the game already sends your client. **It never sends anything
to the server and never acts for you.**

![The FFXI Questlog window and the folded crystal](images/preview.png)

---

## Install

1. Download `FFXI-Questlog-v3.20.0.zip` and unzip it.
2. Copy the **`FFXIQuestlog`** folder into `Ashita/addons/`.
3. In game: `/addon load ffxiquestlog`
4. **Zone once, or log out and back in.** That's when the game sends your quest
   log, mission log and key items. Questlog remembers them from then on.

To load it every session, add `/addon load ffxiquestlog` to your Ashita startup
script (e.g. `scripts/default.txt`).

> Running **VanaCore** instead of Ashita? Use the VanaCore build
> (`FFXI-Questlog-VanaCore-v3.20.0.zip`) in `VanaCore\addons\vanacore\ffxiquestlog`,
> then `/addon load ffxiquestlog vanacore`.

---

## What it does

- **Live progress.** Reads your quest and mission logs and marks the exact step
  you're on; finished steps are struck out.
- **NPC locations.** Every step's NPCs with zone, x/y/z, and a live distance and
  compass direction when you're in the same zone. Click an NPC to locate it.
- **Get-there directions, on every step.** For a new player, each step's travel is
  written out the way the old fan wiki did — *Go to West Ronfaure → Zone out of
  Northern San d'Oria at (C-8)*, *Talk to the Hut Door → Ghelsba Outpost (G-5)* —
  picking the quickest warp (Home Point / Survival Guide / outpost). Every hop is a
  tick box you check off as you go. Other ways there (another warp, or walking) tuck
  under a small **OTHER WAYS** toggle so the list stays short.
- **The folded crystal.** Minimize the window to a home-point **crystal** you can
  park anywhere; a compact step card can ride beside it.
- **Your own tracker.** Pin the missions and quests you care about to the
  right-side tracker — it starts **clear** and shows only what you pin. Pin a
  mission and the pin **follows the storyline**: finish it and the next mission in
  that line is pinned for you automatically. Each tracker entry has a **HOW TO GET
  THERE** button for the route to its current step.
- **Rewards & JP.** Reward items show as icons; optional Japanese item and zone
  names for the JP client.
- **Reads everything locally.** No server traffic, no automation.

---

## Using it

| Area | What it does |
|------|--------------|
| **Window** | The full list of your active quests and missions. Click one to open its steps, NPCs and rewards. Hover and selection glide — no hard snap. |
| **Tracker** (right of screen) | Shows **only what you pin**. Pin from the window or a tracker row; close one out with the **×**. `/ql auto` also lists your current + next missions and active quests. |
| **Crystal** | The folded state. Click to open, drag to move, lock to pin it in place. |
| **Filters & search** | Narrow to what's active, or `/ql find <text>`. |

---

## Commands

| Command | Does |
|---------|------|
| `/ql` | Show / hide the window |
| `/ql mini` | Fold to the crystal / open the full window |
| `/ql step` | Step card beside the crystal on / off |
| `/ql trackall` | Tracker: **pins only** (default) ↔ also current + next missions and active quests |
| `/ql auto` | Auto checklist on / off (steps tick as you talk, trade, defeat and travel) |
| `/ql find <text>` | Search quests and missions |
| `/ql side left\|right\|saved` | Where the window opens from the crystal |
| `/ql pos <x> <y>` | Put the window at a screen position |
| `/ql lock` | Lock / unlock the window and crystal in place |
| `/ql opacity 30-100` | Window opacity (100 = solid) |
| `/ql unscripted` | Show / hide entries that have no step list |
| `/ql jp` | Japanese item and zone names (JP client) |
| `/ql help` | List the commands in game |

---

## Data & privacy

Questlog is **read-only**. Your progress comes from packets the server already
sends your client (your quest log, mission log and key items) plus the items you
carry. Steps the game can't see, you tick off yourself. Nothing is sent to the
server and no action is ever taken for you.

Step lists are generated from retail-accurate quest and mission scripts and
community wikis (FFXIclopedia, CC BY-SA).

---

*FFXI Questlog is a fan-made addon for Final Fantasy XI. Final Fantasy XI is a
trademark of Square Enix. Not affiliated with or endorsed by Square Enix.*
