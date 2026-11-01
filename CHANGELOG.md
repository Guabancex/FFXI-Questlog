# Changelog

All notable changes to FFXI Questlog. Newest first.
The version is also shown in FFXI Questlog's window title, its load message,
`/ql help`, and the download file name.

## 3.2.1
- Trades now list every item you hand over with "and": "Trade Parchment and Black Ink to ...", not "Parchment or Black Ink". "Or" now appears only where the game really takes one thing or another (6 trades, such as a Torn Epistle or a Meteorite).
- Trades that ask for more than three items now list all of them (3 trades were cut short).

## 3.2.0
- One set of steps, not two. When a quest or mission has a hand-written walkthrough (267 of them), that walkthrough is now the step list, shown first under STEPS. The game's own checklist (what ticks itself as you play) folds away under it as CHECKLIST, closed until you open it. Entries without a walkthrough are unchanged.
- A step that talks to the same NPC as the step before it now reads "Talk to X again" instead of looking like the same step twice (89 quests and missions had these).

## 3.1.0
- The minimized crystal is now a real 3D model: a six-sided shard with a long point up and a short one down, turning on its axis, tipped toward you and lit from the upper left, so each facet brightens and darkens as it comes around. The far side shows faintly through the glass.

## [3.0.2] - 2026-11-01

### Changed
- The folded crystal turns a full 360 degrees every 6 seconds, and you can see it turn: the shard is uneven now (its
  six sides different widths) and its points lean a little off the axis, turning with it. Same flames, glow, rune
  circle and glint.

## [3.0.1] - 2026-11-01

### Changed
- The accent is cyan, always (it followed the Vana'diel day's element): the lit corner, the current step, "you are
  here", the selected row, step numbers and progress.

## [3.0.0] - 2026-11-01

### Changed
- A new look to match Aether, Guabancex's HUD: an ink panel with its top-left corner cut and lit, a faint edge all
  round, neutral text in three steps, and one accent colour that follows the Vana'diel day's element (red on
  Firesday, blue on Watersday and so on) - the current step, "you are here", the selected row, the step numbers and
  the progress all take it, and turn with the day. Rewards in Aether's gold.
- Aether's typeface, Barlow Semi Condensed (in `fonts/`, SIL Open Font License); the game's own font if it's missing.

## [2.6.3] - 2026-10-31

### Fixed
- Two NPCs in the same zone could be given each other's way there: the route was remembered by zone only, so the
  first NPC's Home Point was shown for the second too (for example in Uleguerand Range, which has two). Each NPC now
  gets the way to its own spot.

## [2.6.2] - 2026-10-30

### Changed
- The directions fold away: under the NPC, **+ HOW TO GET THERE** with the quickest way on one line; click it for the
  numbered steps and the other ways, click again (**-**) to fold them. Each NPC remembers its own while you play.

## [2.6.1] - 2026-10-30

### Changed
- The other ways show right under the quickest one, no button to press: "DON'T HAVE THAT SURVIVAL GUIDE? BY HOME
  POINT" with its own steps, then "OR WALK FROM HERE" with the zones to cross from where you stand.

## [2.6.0] - 2026-10-30

### Added
- **Step-by-step directions** under an NPC in another zone, numbered, each with a "->" line: the warp to take,
  every zone to cross and the map grid of its exit ("Go to Ghelsba Outpost -> Zone out of West Ronfaure at (F-6)"),
  then the NPC and its grid ("Talk to Hut Door -> Hut Door - Ghelsba Outpost (G-5)").
- **Walk from here instead**: the walking way is always offered, for a new character with no warps touched yet;
  **Another way** cycles through the warps.
- NPC lines show the map grid (as the game's <pos> gives it) instead of raw coordinates.

## [2.5.0] - 2026-10-30

### Changed
- The ROUTE line names the exact Home Point to use, as the Home Point menu lists it:
  **Home Point: Windurst Woods #3**. It's the one closest to the NPC (or to the zone line
  you need). Survival Guides name their zone too: **Survival Guide: Tahrongi Canyon**.
- Hovering the ROUTE line also shows where that Home Point or Survival Guide stands.

## [2.4.0] - 2026-10-30

### Changed
- Completed quests and missions are left off the list, in every view and in search.
  The Done view is gone; the DONE counter at the top still counts them. ALL now means
  everything you haven't finished.

## [2.3.0] - 2026-10-30

### Added
- How to get there: under the current step's NPC, when it's in another zone, a ROUTE
  line with the quickest way, a teleport (Home Point, Survival Guide or outpost warp)
  and then the zones to cross, for example "Outpost (Kolshushu) > Buburimu Peninsula >
  Tahrongi Canyon". Walking from where you are is shown when it's as short. Hover it for
  a second way. Built from the server's zone lines (459), Home Points (122), Survival
  Guides (98) and outposts (17) by tools/build_routes.py into data/routes.lua.

## [2.2.1] - 2026-10-30

### Fixed
- Distances and directions to NPCs: 2.1.0 swapped the wrong thing. It read your height
  as a map coordinate (Ashita keeps a position as X, Z, Y with Z the height), so "23y NE"
  was off. Positions are read right again.
- Coordinates show in the order Ashita uses, for you and for NPCs alike: x and y on the
  map, z the height.

## [2.2.0] - 2026-10-29

### Changed
- Every area in the list (missions and quests) starts folded when FFXI
  Questlog loads, including the Active view, which used to open them all.
  Click an area to open it.

## [2.1.0] - 2026-10-29

### Changed
- Minimized, the window is now FFXI's home point crystal instead of the green
  crystal: a tall, pale blue shard turning slowly over a glowing rune circle,
  with blue-violet flames flickering round its foot.

### Fixed
- Your position had its y and z swapped: Ashita keeps the height in Y, and
  FFXI Questlog was reading Z as the height. YOU (x, y, z) now matches the
  server's !pos order, and the distance and direction to NPCs (and the ???
  point checks) use the right map axes.

## [2.0.0] - 2026-10-29

### Changed
- New look, designed after Final Fantasy XV's menus (matching Tidy 2.0.0):
  blue-black glass with white hairlines that fade at their ends; the
  QUESTLOG wordmark in spaced white capitals after a pale blue diamond; the
  open filter on a bright light band in dark ink with a chevron; pale blue
  for "you are here", periwinkle for step numbers and tips, soft gold for
  rewards; quiet grey for anything finished. The pink neon border glow is
  gone.
- Minimized, the window is now a green FFXI crystal instead of the pink gem:
  a long double point that turns slowly and floats in a soft green glow, its
  facets lit as they come round, with a glint now and then.

### Added
- Walkthroughs for 22 Windurst missions (all but Full Moon Fountain and Moon
  Reading), 43 Treasures of Aht Urhgan missions and the Abyssea main story
  (The Truth Beckons, Dawn of Death, the nine Cavernous Maw boss quests,
  Tenuous Existence through The Wyrm God and the epilogue), all written from
  the FFXIclopedia pages.

### Fixed
- A mission or quest name too long for the sidebar can now be read in full
  by hovering it, and a long name in the steps column wraps instead of
  running off the panel.

## [1.17.0] - 2026-10-24

### Added
- Walkthroughs for all 18 Rise of the Zilart missions, from The New Frontier
  to The Last Verse: start points, routes with map grids, key items, every
  battlefield with boss tips (Grav'iton's Tonberries, the Anticans,
  Kam'lanaut, the five Ark Angels and their shards, Eald'narche), and how
  Awakening leads through the Jeuno epilogue quests. The Last Verse now shows
  its number (Zilart M18).

## [1.16.0] - 2026-10-24

### Changed
- New look, matching Wayfinder's cinematic menu style while keeping
  Questlog's 1980s colours: square corners; a dark midnight-violet glass
  shading to near black (still set by the opacity setting) with pink
  hairlines top and bottom; the QUESTLOG title letter-spaced after a hollow
  diamond, with a fading pink rule under it; the Active / All / Done filters
  in spaced capitals, the open one lit by a pink light band with a chevron;
  headings and rules that fade out; key-cap buttons; a square check for Lock;
  square step bar segments and tick boxes; the current step lit by a cyan
  band; square tooltips. The pink border glow and the pink round brilliant
  gem stay.

## [1.15.0] - 2026-10-23

### Added
- Walkthroughs for all 24 San d'Oria missions (1-1 to 9-2, with every part
  of Journey Abroad): start NPC, route with map grids, trades, battlefields
  and boss tips (Save the Children, the Rank 2 dragons, Archlich
  Taber'quoan, Shadow Lord, Sabotender Enamorado, Corrupted Yorgos, Marauder
  Dvogzog, Honor and Valor, Nio-Hum and Nio-A, Suparna, Warlord Rojgnoj), and
  the rank, gil and rank-point rewards from CatsEyeXI's mission scripts.

## [1.14.0] - 2026-10-23

### Added
- Walkthroughs for all 24 Bastok missions (1-1 to 9-2, with every part of
  The Emissary): start NPC, route with map grids, trades, battlefields and
  boss tips (Archlich Taber'quoan, Shadow Lord, Magma, the On My Way Quadavs,
  the Gigaplasm, Zeid), and the rank, gil and rank-point rewards from
  CatsEyeXI's mission scripts. Routes from the HorizonXI and FFXIclopedia
  mission pages.

## [1.13.0] - 2026-10-23

### Changed
- Minimized, FFXI Questlog is now a twinkling pink round brilliant-cut gem
  instead of the blinking eye: an octagonal table, star, kite and upper
  girdle facets lit from the top left, a glint sweeping round the stone, a
  breathing pink glow, a shine, and star twinkles flashing in turn. Click,
  drag and Lock work as before.

## [1.12.0] - 2026-10-23

### Added
- Walkthroughs for all 94 Rhapsodies of Vana'diel missions. 1-1 to 2-25 follow
  CatsEyeXI's own mission scripts (where to go, what to trade, rank and
  story requirements, which characters must be free), with fight tips for
  Ophiotaurus, Siren and Cetus. 2-26 to 3-35 come from BG-Wiki and say they
  aren't scripted on the server yet.

### Fixed
- Rhapsodies missions with the wrong name or number in the list now show the
  right one: Set Free (1-4), At the Heavens' Door, Prime Number (2-12), From
  the Ruins (2-13), Escha - Ru'Aun, Eddies of Despair (II), The Orb's
  Radiance, and the numbers for 2-8 to 2-13 and 2-26 onward.

## [1.11.0] - 2026-10-23

### Added
- Lock switch under the filters: pins the window and the minimized pink eye in
  place so they can't be dragged. Turn it off, or type `/ql lock`, to move them
  again. Saved with your settings.

## [1.10.0] - 2026-10-23

### Added
- Detailed walkthroughs for all 43 Chains of Promathia missions, shown under a
  mission's steps: what you need (level caps included), where it starts, the
  reward, numbered steps with zones and map grids, and boss tips (Promyvion
  bosses, Diabolos, Ouryu, Omega and Ultima, Tenzen, Promathia). Covers both
  3-3 routes and all three 5-3 paths. Written from the FFXIclopedia and
  HorizonXI mission pages.

## [1.9.0] - 2026-10-23

### Changed
- FFXI Questlog's window is designed like YunaUI (Ashita build 4), matching
  Tidy 1.5.0, in the same 1980s palette: a rounded midnight-violet panel with
  a thin pink edge, diamond marks on the filters (lit cyan on the open one) in
  a rounded highlight, rounded buttons with a cyan edge, rounded tags and tick
  boxes, a step bar running pink to violet, and the QUESTLOG letters flowing
  pink to violet like YunaUI's title.
- Replaces the flat look from 1.7.5. The pink border glow and the blinking
  pink eye when minimized stay.

## [1.8.0] - 2026-10-23

### Added
- Detailed walkthroughs for all 93 Bastok quests, shown under each quest's
  steps: what you need, where it starts, the reward, whether it repeats, then
  numbered steps (zones, map grids, where items drop or are sold, timing and
  weather) and the gotchas. Written from FFXIclopedia, with the HorizonXI and
  BG-Wiki pages filling gaps.

### Fixed
- Two Bastok quests showed the wrong name: Guest of Hauteur (listed as a second
  Welcome to Bastok) and Synergistic Pursuits.

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
