![FFXI Questlog](images/banner.png)

# FFXI Questlog

**Author:** Guabancex<br>
**Version:** 1.7.9<br>
**For:** Ashita v4 · Final Fantasy XI

FFXI Questlog is a quest and mission helper. It keeps track of which part of
each quest or mission you're on, crosses out the steps you've finished, and
shows where the NPCs are: their zone, their x, y, z coordinates and, when you're in the
same zone, how far away they are and in which direction.

It only reads what the game already sends your client. It never sends anything
to the server and never acts for you.

![The FFXI Questlog window: full and minimized](images/preview.png)

---

## Installing

1. Download `FFXI-Questlog-v1.7.9.zip` and unzip it.
2. Copy the `FFXIQuestlog` folder into `Ashita/addons/`.
3. In game, type `/addon load ffxiquestlog`.
4. **Zone or log out and back in once.** That's when the game sends your quest
   log, mission log and key items. FFXI Questlog remembers them after that.

To load it every time, add `/addon load ffxiquestlog` to your Ashita startup
script (for example `scripts/default.txt`).

### Updating from an older version

Versions before 1.3.1 were in a folder called `QuestLog`.

1. Delete the old `Ashita/addons/QuestLog` folder.
2. Copy in the new `FFXIQuestlog` folder.
3. If your startup script says `/addon load questlog`, change it to
   `/addon load ffxiquestlog`.

---

## The window

A rounded control panel in 80s Miami colors, laid out like YunaUI's settings
panel: a see-through midnight-violet panel with round corners and a glowing hot
pink neon edge, a **sidebar** on the left, and the steps on the right past a
slanted divider whose top is lit in pink. **Electric cyan** always means "you
are here", and **hot pink** marks tips and the panel's neon. Finished things
fade and are struck out. Tooltips are dark violet cards with a pink-to-cyan
line along the top.

**Opacity:** the panel lets the game show through. `/ql opacity 30-100` sets
how solid it is (100 = solid). It starts at 82.

**Sidebar** (left)
- The big **QUESTLOG** wordmark: its letters drift slowly from hot pink through
  sunset orange to electric cyan, over three sunset stripes.
- Big counters for quests and missions in progress (cyan) and done, and the
  version.
- **ACTIVE**, **ALL** and **DONE** rows, each with a count. The open one glows
  pink with a cyan line under it.
- A search box.
- Your missions and quests, grouped by area. A small dot shows the state of
  each: cyan with a halo for in progress, an open ring for done, a dash for not
  started.

**Steps** (right: the quest or mission you picked)
- **-** minimizes the window and **x** closes it (top right).
- Where it's from (for example QUEST / WINDURST), its name, and its status.
- How many steps are done (for example **04 / 15 STEPS**) and a bar with one
  rounded segment per step: pink-to-cyan for done, a glowing cyan one for the
  step you're on, faint for the rest. A pink-to-cyan neon rule under it.
- Each step with its number, a round tick box and its text. The step you're on
  has its number in a glowing cyan pill. Finished steps fade and are struck
  out.
- Notes under a step are marked with a hot pink `*`.
- Your own position at the top: **YOU (x, y, z)** and the zone you're in.
- Under each open step: the NPCs involved, their zone and coordinates as
  **(x, y, z)**, for example **(167, 0, 45)**. y is the height, the same order
  as the server's `!pos x y z`. When you're in that zone, a cyan tag shows the
  distance and direction (for example **17y E**).
- Click a step's tick box to mark it done or not done yourself. **Clear my
  ticks** removes your own ticks for that quest.
- **More on BG-Wiki** at the bottom. **Open page** opens the BG-Wiki page in
  your browser for the full walkthrough. **Copy link** copies the link instead.

**Moving and resizing**
- Drag the window by its background to move it.
- Drag the bottom-right corner to resize it (smallest 560 x 360).

### Minimized

Click **-** in the header, or type `/ql mini`, to shrink the window to a slim
bar. The bar shows the quest you picked (or your first one in progress) and the
step you're on, for example:

> QUESTLOG / Grave Concerns  02/04  Trade Skin of Well Water to Tombstone Upper

Click **+** at the left end of the bar, or type `/ql mini` again, to open the full window at the
size you left it.

---

## Commands

| Command | What it does |
|---|---|
| `/ql` or `/questlog` | Show or hide the window |
| `/ql mini` | Minimize to the pink eye, or open the full window again |
| `/ql opacity <30-100>` | How solid the window is (100 = solid) |
| `/ql find <text>` | Search all quests and missions |
| `/ql unscripted` | Hide or show the quests and missions that have no step list (shown by default) |
| `/ql auto` | Turn the auto checklist off or on |
| `/ql check` | Says whether your quest log, mission log and key items have arrived, and for the quest you picked, why each step is ticked or not |
| `/ql pos <x> <y>` | Move the window to this screen position |
| `/ql help` | Show the command list in chat |

---

## How progress is tracked

FFXI Questlog reads what the game already tells your client:

| From the game | What it marks done |
|---|---|
| Quest log (in progress and completed) | Starting a quest. Finishing one marks every step done. |
| Mission log (current and completed missions) | The same, for missions |
| Key items | Any step that gives you that key item |
| Items you carry (inventory, satchel, sack, case, wardrobes) | Any step that gives you that item |

When a step is marked done this way, every step before it counts as done too.

### Auto checklist

The game doesn't tell your client how far you are in a quest after talking to
someone or making a trade (the server keeps that to itself). So FFXI Questlog
watches what happens instead, and ticks the step for every quest or mission
you're on (and the one you picked):

| When | It ticks |
|---|---|
| You get a cutscene or menu from an NPC (talking or trading to it) | That NPC's talk or trade step |
| You use a ??? point | Its step, found by where you're standing (within 6 yalms) |
| A monster is defeated | Its "Defeat" step |
| You enter a zone | Its "Enter" step |

Only the next two open steps can be ticked this way, so chatting with an NPC
who shows up again later in the quest doesn't skip ahead. Ticking a step also
ticks every step before it, and a chat line says which step was done.
`/ql auto` turns the auto checklist off or on.

You can still tick or untick any step yourself: click its box **or its text**.
If something isn't ticking, `/ql check` lists each step and what it is waiting
for.

### Where the steps come from

The steps follow original FFXI. They're built from LandSandBoat, the open
project that recreates the retail game's quests and missions script by script:
who to talk to, what to trade, what to defeat, which zone to enter and what you
get, in the order the scripts handle them. Newer quests and missions have a
step script of their own; older quests are written into the NPCs' scripts, and
their steps are worked out from those (which events each NPC plays for the
quest and what each one does). That covers 883 quests and missions.

BG-Wiki is a supplement: every entry links to its page for the full
walkthrough, but the steps themselves are built in.

Quests and missions with no step list yet are listed like the rest; their page
says so and points to BG-Wiki. `/ql unscripted` hides them.

Some quests have hand-checked steps instead, written from the quest's script
with extra notes (for example Hitting the Marquisate, the Thief AF3 quest, and the Rhapsodies
mission Cauterize).
These live in `tools/overrides.py`, so a quest that reads wrong can be fixed
there and survives the next data rebuild.

Treat them as a guide. A script can't say everything, such as where a mob or
item comes from. For those, FFXI Questlog lists the NPCs involved and where they
stand, and every quest and mission links to its BG-Wiki page.

### Good to know

- Not yet tested in game: reading the quest log, the item checks and the
  direction tag. The direction assumes north is at the top of the map.
- Some storylines only report your current mission (Chains of Promathia, the
  add-on scenarios, Seekers of Adoulin and Rhapsodies of Vana'diel). For those,
  every earlier mission counts as done.

---

## Updating the quest data

Rebuild the data from a LandSandBoat checkout
(https://github.com/LandSandBoat/server):

```
python3 tools/build_quests.py <landsandboat> <landsandboat>/sql/zone_settings.sql data/quests.lua
```

It reads the quest and mission scripts, the quest, mission, key item, item and
zone lists, the NPC scripts, and the NPC list (`data/zones/*/npcs.yaml`, or
`sql/npc_list.sql` in older checkouts) for NPC names and positions. Any other
LandSandBoat-based server checkout works the same way.

---

## Files

```
FFXIQuestlog/
├── ffxiquestlog.lua       The addon: window, packets, step display
├── lib/log.lua            Quest and mission status, key items, progress, directions
├── data/quests.lua        Quests, missions, steps and NPC positions (generated)
├── tools/build_quests.py  Builds data/quests.lua from the server source
├── tools/overrides.py     Hand-checked steps for quests the builder gets wrong
├── README.md              This file
├── CHANGELOG.md           Every version and what changed
└── images/                The banner and window pictures used in this README
```

---

## Quest data

The quest data in `data/quests.lua` is generated from LandSandBoat's scripts
and data (quests, missions, key items, NPC positions and zone names). That data
belongs to its source project.

---

*FFXI Questlog v1.7.9 by Guabancex.*
