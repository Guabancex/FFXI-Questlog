# Changelog

All notable changes to FFXI Questlog. Newest first.
The version is also shown in FFXI Questlog's window title, its load message,
`/ql help`, and the download file name.

## [1.7.9] - 2026-10-23

### Changed
- Each blink of the minimized eye swaps it between its calm pink look and an
  "awake" look: a molten gold iris with light rippling out from a wide diamond
  pupil.

## [1.7.8] - 2026-10-23

### Changed
- Folded, it's just the eye now: no tile, no border and no glow round it.

## [1.7.7] - 2026-10-23

### Changed
- The minimized eye is hot pink now, and it blinks: every few seconds the lids
  sweep shut and open again (every third time, a quick double blink).

## [1.7.6] - 2026-10-23

### Changed
- Minimized, FFXI Questlog is now just the CatsEyeXI green cat's eye in a small
  tile with the pink neon glow. Click it to open the window, drag it to move it.
  Hover it for the quest you're on and its current step.

## [1.7.5] - 2026-10-23

### Changed
- Flat look, open and folded: square corners everywhere, solid colors instead
  of gradients, no drop shadows or inner glow.
- The border glow is solid hot pink now (no color cycling); it still pulses and
  the two comets still race round the edge.

## [1.7.4] - 2026-10-23

### Changed
- The border glow is animated now: the neon round the window's edge shifts
  slowly through hot pink, sunset orange and electric cyan and pulses, and two
  bright comets race round the border trailing light. Works on the folded bar too.

## [1.7.3] - 2026-10-23

### Changed
- The glow now goes round the window's borders: a soft hot pink neon glow
  spreads outward from the whole edge of the window (and the folded bar) and
  breathes slowly. The wordmark is back to plain drifting colors.

## [1.7.2] - 2026-10-23

### Changed
- A glow instead of sparkles: a soft neon halo breathes slowly behind the QUESTLOG
  wordmark (drifting from pink to cyan), the letters bloom a little with it,
  and the window's neon edge breathes in time.

## [1.7.1] - 2026-10-23

### Added
- Sparkles: small four-point stars twinkle in turn around the QUESTLOG wordmark,
  and one glides slowly round the window's neon edge.

## [1.7.0] - 2026-10-22

### Changed
- **Original FFXI instead of CatsEyeXI:** the quest and mission data is now
  built from LandSandBoat, the project that recreates retail FFXI, so steps,
  NPC names and positions follow the original game rather than one server's
  changes. 883 quests and missions have steps.
- Quests and missions without a step list are listed again (their page points
  to BG-Wiki); `/ql unscripted` hides them.
- Cauterize's note describes the retail requirement (Cait Sith available).
- The banner reads "Final Fantasy XI · Quest & Mission Helper".

## [1.6.1] - 2026-10-22

### Fixed
- The **-** (minimize) and **x** buttons no longer disappear: they sat inside
  the scrolling steps, so they scrolled out of view on long quests (and a long
  zone name could push them off the edge). They're now pinned at the top right
  of the steps column, with your position, and never scroll away.

## [1.6.0] - 2026-10-22

### Added
- Steps for 105 more quests: older quests written into the NPCs' own scripts
  (no step script of their own) now get steps worked out from those scripts --
  who starts it, what to trade, who you talk to, what you get and who finishes
  it. 835 quests and missions have steps now.
- Quests and missions the server has no script for at all are marked
  **Not on CatsEyeXI yet** and left out of the lists (unless you've started or
  finished one). `/ql unscripted` lists them anyway.

### Changed
- BG-Wiki is a supplement: entries without spelled-out steps say why and list
  the NPCs involved, with BG-Wiki for the full walkthrough.

## [1.5.3] - 2026-10-22

### Fixed
- Every NPC now shows the name the game shows. Only points the game itself
  calls ??? are still ???; doors with an apostrophe in their name (Door:Prince
  Royal's Rm, Door:"Neptune's Spire", Door:San d'Orian Emb. and others) now
  show it too, and invisible trigger spots show as "Unmarked spot".
- Five more NPCs got their positions (names with an apostrophe were missed).

## [1.5.2] - 2026-10-22

### Fixed
- NPC and ??? spots now use the server scripts' own standing spots when a
  script gives one near the NPC (the spot GMs `!pos` to), instead of the
  object's position, which for doors and points can sit inside a wall. For
  example The Lost City's Sewer Entrance is now (28, -12, 44). 99 spots updated.
- Doors and other objects show the name the game shows (Sewer Entrance, Walnut
  Door, Heavy Stone Door...) instead of ???.

## [1.5.0] - 2026-10-22

### Changed
- New window, laid out like YunaUI's settings panel and kept in the 80s Miami
  colors:
  - A rounded, see-through midnight-violet panel with a glowing hot pink neon
    edge.
  - A sidebar on the left: the big QUESTLOG wordmark (its letters drift from
    hot pink through sunset orange to electric cyan) over sunset stripes, the
    counters, the ACTIVE / ALL / DONE rows (the open one glows pink with a cyan
    line under it), the search box and the list. A slanted divider, lit pink at
    the top, separates it from the steps.
  - Round status dots in the list, round tick boxes, rounded step segments
    (pink-to-cyan when done) and a glowing cyan pill on the current step.
  - Section names in spaced capitals with a faint line to the edge; round -
    and x buttons; rounded buttons with a pink neon edge.
  - Tooltips are dark violet cards with a pink-to-cyan line along the top.
- The window starts at about 680 x 460 and can be resized down to 560 x 360.

## [1.4.2] - 2026-10-21

### Fixed
- **Cauterize** (Rhapsodies of Vana'diel 2-14) now has its step: click the
  sparkling ??? at a Cavernous Maw in Batallia Downs, Rolanberry Fields or
  Sauromugue Champaign (past or present) for the cutscene and the Lightsworm
  key item. All six ??? are listed with their spots, and the auto checklist
  ticks it when you use one. A note gives CatsEyeXI's requirement (Cait Sith
  available through your Wings of the Goddess progress), the WotG 3 Cait Sith
  shortcut, and that the next mission is Ganged Up On.
- ??? points named like `qm_maw` show as **???**.
- Key items from hand-checked steps get their names.

## [1.4.1] - 2026-10-20

### Added
- **Auto checklist:** steps tick themselves as you play.
  - A cutscene or menu with an NPC (talking or trading to it) ticks that NPC's
    step.
  - Using a ??? point ticks its step, found by where you're standing.
  - Defeating a monster ticks its "Defeat" step; entering a zone ticks its
    "Enter" step.
  - Works for every quest or mission in progress and the one you picked. Only
    the next two open steps can be ticked, so an NPC who appears again later
    can't skip you ahead. A chat line says which step was done.
  - `/ql auto` turns it off or on.

### Removed
- The LICENSE file and the license section of the README.

### Changed
- README: the banner at the top and a picture of the window (full and
  minimized) right under the introduction. The `images` folder now comes in
  the download so the pictures show.

### Fixed
- Steps easier to check off:
  - Ticking a step also ticks every step before it.
  - Clicking a step's text ticks or unticks it, not only the small box.
  - The tick boxes are easier to see against the dark panel.
- The steps say which ones tick themselves (starting, finishing, key items and
  items you get) and which you tick (talking and trading, which the game
  doesn't report to your client).
- If your quest log hasn't arrived yet, the steps say so: zone once.

### Added
- `/ql check`: whether your quest log, mission log and key items have arrived,
  and for the quest you picked, each step and what it's waiting for.

## [1.4.0] - 2026-10-20

### Changed
- New look: an editorial, avant-garde design. Ink-black panel, bone-white type,
  square corners and hairline rules, with one acid-green accent for "you are
  here" and a vermilion mark for headings and tips.
  - Masthead with a large QUESTLOG wordmark, big in-progress and done counters,
    and a heavy rule underneath.
  - Text tabs (ACTIVE / ALL / DONE) with an acid underline instead of buttons.
  - Numbered, letter-spaced section headings; square status marks in the list.
  - Each quest shows where it's from (for example QUEST / WINDURST) above a
    larger title.
  - Progress is a bar with one block per step.
  - The current step's number sits in an acid block; finished steps fade and
    are struck out; notes are marked with a vermilion `*`.
  - The minimized bar matches the new look.
- Same window size as before.

## [1.3.4] - 2026-10-20

### Fixed
- **Hitting the Marquisate** (Thief AF3) now has the right steps in the right
  order: Nanaa Mihgo, Yatniel and his 4 Quake Grenades, Hagain's Bomb Incense,
  all seven Garlaige Citadel ??? in order with their spots, the Chandelier
  fight, the coal back to Hagain, Nanaa Mihgo again, and the Pickaxe in the La
  Theine valley. Before, six of the seven ??? were missing and the steps were
  out of order.
- Unnamed ??? points show as **???** instead of names like `qm6`.
- Positions added for a few more NPCs and ??? points that were missing.

### Added
- Steps can carry a short note under them (tips such as how to claim the
  Chandelier).
- `tools/overrides.py`: hand-checked steps for quests the data builder gets
  wrong. They're kept when the data is rebuilt.

## [1.3.3] - 2026-10-18

### Fixed
- With a quest selected, the minimized bar couldn't be opened again: a long
  quest name and step pushed the **+** and **x** buttons past the bar's
  maximum width, so they were cut off. The buttons now sit at the left end of
  the bar, and long names and steps are shortened.
- Clicking a button no longer also starts dragging the window.

## [1.3.2] - 2026-10-18

### Changed
- New README for the FFXIQuestlog folder and `/addon load ffxiquestlog`, with
  steps for updating from the old `QuestLog` folder.
- LICENSE is now the plain MIT license text, so GitHub and other sites detect
  it. The note about the quest data moved to the README.

## [1.3.1] - 2026-10-18

### Changed
- The folder and file are now named after FFXI Questlog too: `FFXIQuestlog/`
  with `ffxiquestlog.lua`. Load it with `/addon load ffxiquestlog`. Delete the
  old `QuestLog` folder when you update. `/ql` and `/questlog` still work.

## [1.3.0] - 2026-10-18

### Added
- Minimize: **-** in the header (or `/ql mini`) folds the window to a slim bar
  showing the quest you picked, or your first one in progress, with its current
  step. **+** opens the full window again at the size you left it.

### Changed
- Renamed to **FFXI Questlog** (window, chat messages, help). The folder and
  commands stay `QuestLog`, `/addon load questlog` and `/ql` (renamed in 1.3.1).

## [1.2.0] - 2026-10-18

### Changed
- Modern look: dark slate panel with an indigo accent, rounded corners, and a
  custom header with your in-progress and done counts.
- Filters are pills with counts; the search box has a hint; list entries have a
  colored status dot (amber in progress, green done, gray not started) under
  MISSIONS / QUESTS headings.
- The selected quest shows a status tag, "x of y steps" and a progress bar.
- Steps are cards with number badges; the current step is amber with a bar
  down its left side; long steps wrap. Distances show as a green tag.

## [1.1.0] - 2026-10-18

### Added
- **More on BG-Wiki** at the bottom of every quest and mission: **Open page**
  opens its BG-Wiki page in your browser, **Copy link** copies the link (also
  used automatically if the browser can't be opened).

## [1.0.0] - 2026-10-18

### Added
- First release, for CatsEyeXI.
- All 1,084 quests and 476 missions (nation, Zilart, Promathia, Aht Urhgan,
  Goddess, add-ons, Adoulin, Rhapsodies), listed by area and filtered by
  Active / All / Done, with search.
- Step-by-step guides for 729 of them, generated from the server's own quest
  and mission scripts: who to talk to, what to trade, what to defeat, where
  to go, and what you get.
- Progress read from the game: your quest log, mission log and key items, and
  the items you carry. Finished steps are scratched out and the current step
  is highlighted. Tick or untick any step yourself.
- NPC locations: zone and coordinates for each step's NPCs, plus distance and
  direction from you when you're in the same zone.
- For quests without a step guide, the NPCs involved and where they stand.
- Plain window: drag to move, resize from the corner; `/ql pos` to place it.
