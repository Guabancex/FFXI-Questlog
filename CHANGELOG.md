# Changelog

All notable changes to FFXI Questlog. Newest first.
The version is also shown in FFXI Questlog's window title, its load message,
`/ql help`, and the download file name.

## 3.26.3
- **Lighter every frame, less garbage.** Measured in the test harness: the pinned step list costs about half as much
  per frame, and the window's list a third less.
  - The quest/mission list is worked out twice a second (at once when the filter, search or your log changes)
    instead of scanning all ~1,500 entries every frame.
  - The step list rebuilds 4 times a second, or at once when your pins, hides or pick change.
  - Each entry's key ('q:2:71') is made once, not ~1,500 new strings a frame.
  - A step's coloured, word-wrapped text and the time/moon/weather lines are kept until they change.
  - All of these caches let go of an entry when it's no longer used (weak tables), so memory stays flat.

## 3.26.2
- **Fixed: changing the size crashed FFXI Questlog** (you had to reload it by hand). Letting go of a Size slider (or
  `/ql scale`) made the addon reload itself from inside its own frame, which killed it. Now the new size applies at
  once with no reload: the layout follows straight away, and the text is scaled to it (slightly soft) until the next
  time the addon loads, which builds the fonts sharp at the new size.
- 67 tests.

## 3.26.1
- **Fixed: "Could not save the size."** FFXI Questlog keeps its size, window/crystal/arrow spots and weather in
  `config/addons/ffxiquestlog/`, but Ashita names the settings folder after the addon's display name, so that folder
  was never made and every write failed quietly (the size slider said so; the spots fell back to your character
  settings). The folder is now created the first time it's needed. The Size sliders, `/ql scale`, and remembered
  positions and weather all save again.
- 67 tests.

## 3.26.0
- **Steps and checklist are one list.** A quest or mission with a written walkthrough showed it as numbered STEPS,
  with the game-tracked CHECKLIST folded underneath. Now there's one **Steps** list: the game's tracked steps (they
  still tick themselves as you talk, trade, defeat and travel), each with the walkthrough's lines that belong to it
  as details underneath. A walkthrough line that mentions none of the tracked NPCs or items is its own step with a
  tick box, in order. Need / Start / Reward stay on top, tips and hub-mission paths stay at the bottom.
  CLEAR MY TICKS clears both kinds of tick.
- Quests the game doesn't track keep their tickable walkthrough (3.25.0).
- 66 tests.

## 3.25.3
- **Open Sesame shows how to get its items:** where the Tremorstone is (the ??? by the Cloister of Tremors
  protocrystal) and how to get there (Home Point #2, a Unity warp, or on foot from Eastern Altepa J-7 to the hidden
  entrance at E-10, or the Summoner mini-fork shortcut); where Soil Geodes drop (monsters giving exp at 75+ in dust or
  sand storms, or Earthsday) and that they and the Soil Gem are on the Auction House (Goldsmithing).

## 3.25.2
- **Fixed: the quest and mission list had almost no room.** 3.24.0 added two size sliders to the side column
  (above the list, under Lock, Opens and Step list); in a normal-size window that squeezed the list below to a
  sliver, so your quests and missions seemed gone. Those settings now sit under a **SETTINGS** row in the side
  column, folded by default (click it to open or close), and the list gets its room back.
- 64 tests.

## 3.25.1
- **Fixed: pinned missions not showing in the step list.** A pinned mission (or quest) was only listed while it was
  your current one, so pinning a mission you hadn't reached -- or any mission before the game sent your mission log
  (zone once after loading) -- showed nothing. Every pin now shows until it's done. The "next mission" line still
  only follows your current mission.
- 64 tests.

## 3.25.0
- **Outlands quest walkthroughs: 41 new** -- Kazham, Norg, Rabao, Selbina/Mhaura and Zi'Tah: The Firebloom Tree,
  Greetings to the Guardian, A Question of Taste, Missionary Man, the Gullible's Travels line, Personal Hygiene,
  The Opo-opo and I, Cloak and Dagger, A Discerning Eye, the Trials by Fire / Water / Wind (and Trial Size),
  Forge Your Destiny, Black Market, Mama Mia, Stop Your Whining, Secret of the Damp Scroll, The Sahagin's Stash,
  It's Not Your Vault, Like Shining Leggings, the Samurai and Ninja artifact and weapon skill quests, An Undying
  Pledge, Wandering Souls, Soul Searching, Divine Might, Open Sesame, The Missing Piece, The Kuftal Tour, The Immortal
  Lu Shang, Chasing Dreams, The Search for Goldmane and Indomitable Spirit. Written from the FFXIclopedia pages; four
  whose pages wouldn't load are from BG-Wiki and say so.
- **Checklist for quests the game doesn't track:** their walkthrough steps get tick boxes (saved with your
  character), and the pinned step list shows the first step you haven't ticked.
- Not yet: Everyone's Grudging, You Call That a Knife?, Gullible's Travels, The Sahagin's Key, Everyone's Grudge,
  Like a Shining Subligar, A Thief in Norg!?, I'll Take the Big Box, Wrath of the Opo-opos and Don't Forget the
  Antidote (their pages wouldn't load), and the Voidwatch ops.
- 63 tests.

## 3.24.0
- **Size sliders in the window's side menu** (under Lock, Opens and Step list):
  - **Size** -- the window and crystal: **Auto** (follows your resolution: 1080p 1x, 1440p 1.25x, 4K 2x; it shows
    the size Auto picked) or 0.75x-3x in quarter steps. Same as `/ql scale`.
  - **Step list size** -- the pinned step list on its own: Auto (= the window's size) or 0.75x-3x. Its text, titles,
    width, buttons and spacing all follow it. New: `/ql scale tracker auto|0.75-3`.
  - Let go to apply: FFXI Questlog saves it (`ui_scale.txt` / `tracker_scale.txt`, read before login) and reloads
    to rebuild the fonts. Letting go where it was does nothing.
- The step list's buttons (pin, < >, share, close) now grow with the size; before they stayed 18 px even at 4K.
- 62 tests.

## 3.23.7
- **Step list: Free (drag it) is back as a third choice.** The **Step list** row in the window's side menu now
  cycles **Right -> Left -> Free**, or `/ql tracker left|right|free`. Free: drag it by an empty spot while unlocked
  (a faint frame shows on hover); it reopens where you left it (`window_pos.txt`, kept on screen), `/ql lock` pins
  it, and its text hugs the nearer edge of the screen. Right and Left stay fixed as before.
- 61 tests.

## 3.23.6
- **The pinned step list moves by menu, not by dragging.** **Step list: Right / Left** in the window's side menu
  (under Lock and Opens), or `/ql tracker left|right`, puts it on that side of the screen, with its text and
  buttons hugging that edge. Dragging it, `/ql tracker home|pos|align` and the saved drag spot (3.23.4-3.23.5) are
  gone; an old spot in `window_pos.txt` is ignored.
- 61 tests.

## 3.23.5
- **Step list text follows its side.** The pinned step list's text and buttons hugged the right edge even after you
  dragged it to the left of the screen. New setting **Step list** in the window's side menu (under Lock and Opens),
  or `/ql tracker align`: **Auto** (default) hugs the left edge on the left half of the screen and the right edge on
  the right half; **Left** / **Right** always hug that edge. Everything follows: titles, names, steps, conditions,
  HOW TO GET THERE, the route, the NEXT tag and the buttons (pin, < >, share, close; < stays left of >).
- 62 tests.

## 3.23.4
- **The pinned step list (tracker) can be moved.** It was fixed to the right of the screen. Now, while unlocked, drag
  it by any empty spot (a faint frame shows when you hover it); it reopens where you left it, after a restart too
  (`window_pos.txt`), and is kept on screen if your resolution changes. `/ql lock` pins it along with the window
  and the crystal. `/ql tracker home` puts it back; `/ql tracker pos <x> <y>` places it exactly.
- 61 tests.

## 3.23.3
- **Weather is remembered** across a reload or an update (in `config/addons/ffxiquestlog/weather.txt`): steps
  that need weather no longer say UNKNOWN until you zone. Used only in the same zone and if under an hour old;
  the next weather change corrects it.
- Repeatable timers already carried over (saved with your character in `config/`, which an update doesn't
  touch); now a timer that clears is saved at once too.
- 60 tests.

## 3.23.2
- **Fixed:** opening a quest or mission from the tracker, after you'd looked at the progress page, showed the
  progress page again instead of the entry's full steps. It now opens straight to its steps.

## 3.23.2
- **Fixed:** the steps, NPCs and HOW TO GET THERE could disappear from the window and the step list. If the new
  time / moon / weather or repeatable-timer lines hit an error (for example when only `ffxiquestlog.lua` was
  updated and `lib/log.lua` was still the old one), everything below them was cut off. Now those lines are
  simply skipped and the steps and routes always show.
- If `lib/log.lua` is from an older version, Questlog says so on load: copy the whole folder from the zip.
- Every quest and mission is now checked by the tests in the window and the step list (59 tests).

## 3.23.1
- The quest list in the window now shows the new info on each row: **step n/m** for what's active, **NOW** /
  **WAIT** when a step needs a time, moon or weather (hover the row to see which), and for a finished
  repeatable its **AGAIN IN** timer, then **READY**. Long names are cut with ... to make room. 56 tests.

## 3.23.0
- **New: arrow to your step's NPC.** When you're in their zone (or to the zone line on the walking route
  otherwise), turned to the way you face, with the distance. Drag it anywhere; it reopens there.
  `/ql arrow on|off|flip|home`.
- **New: step and quest-done moments.** A short card with a ring, rewards and a chime when a step ticks and
  when a quest or mission finishes. `/ql sound` turns the chimes off.
- **New: progress page.** Completion ring, nearly-done list, each storyline as a mission chain, quests by
  area. PROGRESS in the side list, or `/ql progress`.
- **New: time, weather and moon conditions.** Steps that need night, an hour window, a weekday, weather or a
  moon phase show it in the steps and the tracker, with time until it's right.
- **New: repeatable timers.** A finished repeatable shows READY AGAIN / AGAIN IN, and you're told once when
  it's ready.
- **New: share to party.** SHARE button (window and tracker) or `/ql share` posts your current step to party
  chat -- the only thing Questlog ever sends, and only when you ask.
- 55 tests.

## 3.22.3
- **Fixed:** after `/ql check`, items you picked up didn't count toward a step for about 12 seconds (the bag
  refresh was pushed into the future). Now they show within the usual 2 seconds.
- **Lighter every frame:** step text is built once per step instead of every frame (the folded step list redrew
  it constantly), and search lowers each title once instead of on every frame.
- Code clean-up: removed unused drawing helpers (diamond, status mark, line wrapper), unused colours and
  values that were written but never read. New test for the `/ql check` fix (45 tests).

## 3.22.2
- The folded crystal comes back exactly where you last left (or locked) it, after a restart too, and the full
  window where you left that -- each kept separately in its own file (`config/addons/ffxiquestlog/window_pos.txt`), which
  is there at game start, before your character's settings arrive.

## 3.22.1
- First launch opens the window at 600, 400 for setup (until you move it -- after that it reopens where you left it).

## 3.22.0
- The UI size (`/ql scale`) is now kept in its own small file (`config/addons/ffxiquestlog/ui_scale.txt`) instead
  of your character's settings, so a size you pick is used from the moment the game starts (character settings
  only arrive after login -- too late to build the text at the right size). Auto (4K = 2x) is still the default.

## 3.21.1
- Fixed: the window and the folded crystal now reopen where you left them after restarting the game. At game start
  Questlog loads before you log in and your character's settings (where the spot is saved) arrive afterwards; it now
  re-places itself once they do.

## 3.21.0
- UI size for high resolutions: everything (text, sidebar, list rows, padding, the crystal, the tracker) now
  scales together. **Auto** by default from your game resolution -- 1080p 1x, 1440p 1.25x, 4K 2x -- so 4K isn't
  tiny anymore. `/ql scale 0.75-3` sets it yourself, `/ql scale auto` goes back. Fonts are built at the chosen
  size (sharp, not stretched), so a change reloads the addon. The window still resizes by dragging its
  bottom-right corner.

## 3.20.0
- The pinned tracker now has a "HOW TO GET THERE" button on every entry: click it to show the route to the current
  step's NPC (the quickest warp, the zones to cross with their exits, and the NPC), right in the tracker. Folded by
  default so the tracker stays compact.

## 3.19.3
- Fixed: the tracker's step counter skipped steps and jumped to the end on missions whose walkthrough has more
  lines than the game actually tracks (e.g. CoP 6-4: 1 tracked step, 11-line walkthrough). It was scaling tracked
  progress onto the longer walkthrough. The tracker now shows the exact tracked step; the full walkthrough still
  shows in the window.

## 3.19.2
- CoP mission 6-4 "One to be Feared": full walkthrough -- talk to Cid, the route to Sealion's Den, the Iron
  Gate/airship cutscenes, buffing inside, the three rounds (Mammets, Omega, Ultima) with the refill between them,
  and the Lufaise Meadows finish. Prep list, CCB Polymer Pump note and Cherukiki trivia added to the notes.

## 3.19.1
- Fixed: a talk step with more than one NPC read "Talk to X or Y" -- you talk to all of them, so it now reads
  "Talk to X and Y". (Either/or starts, like a nation's own gate guard, use their own hand-written wording and are
  unaffected.)

## 3.19.0
- Travel directions now show under EVERY step, always -- no toggle. The quickest way's hops (Go to <zone> / Zone
  out of <zone> at (grid) / Talk to <NPC> at (grid)) are laid out straight down the list so a new player just follows
  them, each a tick box. The other ways (another warp, walking) tuck under a small "OTHER WAYS" fold so the window
  stays short. Removes `/ql routes` (it's always on now).

## 3.18.0
- Pins follow the storyline: when a pinned mission is completed, the pin moves to the next mission in that same line
  automatically, so the tracker keeps showing what's next without you re-pinning. Catches up at load too, in case a
  pinned mission was finished while the addon was off. Quests are unaffected (they have no fixed next).

## 3.17.0
- Travel steps are now part of the checklist: each "Go to <zone>" / "Talk to <NPC>" hop has its own tick box, so a
  new player can tick each one off as they go (like the wiki directions, now interactive). Ticks are per-session and
  clear on reload; the path itself still drops a hop automatically once you actually zone into it.

## 3.16.0
- New-player travel help: `/ql routes` shows the "how to get there" steps -- Go to <zone> / Zone out of <zone> at
  (grid) / Talk to <NPC> at (grid) -- under EVERY step, not just the one you're on, so you can read the whole path
  ahead (written the way the old fan wiki laid out directions). The quickest warp (Home Point / Survival Guide /
  outpost) and walking fallbacks are included. Off by default so the window stays compact; the step you're on still
  shows its route automatically.
- Fixed: `/ql auto` (auto checklist on/off) had been shadowed by the tracker toggle and did nothing. The tracker
  toggle is now `/ql trackall`; `/ql auto` controls the auto checklist again.

## 3.15.0
- The right-side tracker now shows ONLY what you pin, clear from the start, so you choose your own missions and
  quests. /ql trackall brings back the old behaviour (also lists your current + next missions and active quests).

## 3.14.0
- Smoother, less clunky list: the quest/mission rows now use a custom row instead of the raw ImGui selectable --
  hover and selection ease in, a cyan rail slides out and the name brightens, matching the rest of the UI. First
  of several motion passes (collapse animation and the mini<->full tween are next).

## 3.13.4
- Fixed: the window could open off-screen (a position saved at another resolution, or the auto default),
  so it looked like the addon wasn't loading. It's now clamped onto the visible screen on open, and a bad
  saved position is corrected. (If it ever happens again: /ql pos 600 400.)

## 3.13.3
- The CoP "Three Paths" mission now shows all three paths' FULL walkthroughs inline in its Steps section
  (Louverance's/Tenzen's/Ulmia's), pulled from each path's own entry so there's no hunting across rows and no
  duplicated data. Any hub mission can do this via a `paths` list in its guide.

## 3.13.2
- Fixed: missions with no server step list but a hand-written walkthrough (e.g. the CoP Three Paths missions
  Spiral, Partners Without Fame, Where Messengers Gather, Flames for the Dead) wrongly showed "No step list for
  this one yet" ABOVE the walkthrough, so the steps looked missing. The walkthrough now shows on its own, and the
  "Three Paths" mission points you to each path row for its full steps.

## 3.13.1
- Corrected and fleshed out the CoP Chapter 5 "Three Paths" guides from the official walkthroughs:
  Tenzen's path (Spiral), Louverance's path (Partners Without Fame) and Ulmia's path (Where Messengers Gather).
  Fixes: Hinaree is at Southern San d'Oria A-6 (not B-6); Boneyard Gully is off Attohwa Chasm H-6; the Gold Key is
  farmed and traded AFTER the A Century of Hardship fight (first entry uses a Shaft 2716 operating lever), not to
  enter it. Added battle/aggro notes for all three.

## 3.13.0
- The right-side list now shows, for each storyline you're in, the mission you're on AND the next one, read from your
  mission log. The next mission gets a gold NEXT tag and shows its first step, so you can see what's coming. (The "next"
  is the following mission in that line you haven't started; branching storylines may guess the branch.)

## 3.12.0
- Rewards as item icons: a quest or mission's detail now shows the items it gives as their in-game icons (hover one for
  its name). No icon (the game's item art not loaded) falls back to the names.
- Click an NPC in a quest's step/NPC list to locate it: its zone, map grid, and distance and direction from you, in
  chat. (Making the game target it needs a memory write no Ashita API exposes, so this points you to it instead.)
- Japanese item and zone names: /ql jp. Quest titles, NPC names and the walkthroughs have no Japanese data, so they
  stay English; the item and zone names switch to the game's Japanese strings.

## 3.11.0
- Close a quest or mission out of the right-side list with its X. It goes off the list until its step changes, then
  it comes back on its own. Opening it from the window (or pinning it) brings it back right away. The X also unpins it.

## 3.10.0
- The step list on the right now matches Crystal HUD: its headers, quest and mission names and the "Step x / y" line
  are in Crystal HUD's Chakra Petch; the MISSIONS / QUESTS headers get its lit cyan / gold tick. The step body stays in
  Barlow (easier to read). Gold is now Crystal HUD's gold (#FDC800), used for quests and rewards.
- Pin a quest or mission straight from the window: a PIN button by its status (IN PROGRESS / COMPLETED) keeps it at the
  top of the step list on the right. Same pins as the list's own pin button.

## 3.9.0
- Folded to the crystal, the missions and quests you're on are now listed down the right of the screen, instead of the small card beside the crystal: -- MISSIONS -- then -- QUESTS --, each with its name (click it to open it in the window), "Step 2 / 5" and the step itself. NPCs show in green, monsters to defeat in red, items and key items in gold, places in white. A quest with a walkthrough shows the walkthrough's step.
- Under each one: < and > show the step before or after (it follows your progress again once you are back on your step), and the pin keeps it at the top of the list. Repeatable quests show an infinity sign.
- Up to 3 missions and 5 quests are listed; pinned ones always are. The quest you picked in the window shows too. /ql step hides or shows the list.

## 3.8.0
- The AI guides are gone: no Gemini or OpenRouter, no key, no network calls. FFXI Questlog is back to working entirely on your PC, as in 3.4.1, with everything else unchanged. Keys and guides an earlier build saved in config\addons\ffxiquestlog are no longer read; you can delete that folder.

## 3.7.1
- Fixed "No endpoints found": when the chosen model has no endpoint available, OpenRouter now falls back to google/gemini-3-flash-preview, then openai/gpt-4o-mini, instead of failing. Errors also say what to do (pick another model, check privacy settings, add credit, or fix the key). TRY AGAIN under the error asks again.

## 3.7.0
- The detailed guides now come through OpenRouter instead of Google directly. The default model is google/gemini-3.6-flash, with OpenRouter's web search so each guide is still checked against FFXIclopedia and BG-Wiki. /ql ai model picks any OpenRouter model.
- Save an OpenRouter key with /ql ai key <your key> (kept in config\addons\ffxiquestlog\openrouter-key.txt on your PC). Guides already written are kept.

## 3.6.1
- A personal build can carry its own Gemini key (lib/gemini_key.lua, scrambled): on first load it is put in place by itself, so the detailed guides work with no command. Builds you share have no such file and work as before (/ql ai key).

## 3.6.0
- No more question box. Instead, every quest and mission gets a DETAILED GUIDE written by Google's Gemini: a numbered, one-action-per-step walkthrough from start to finish (where to go with map grid and nearest Home Point or Survival Guide, who to talk to, what to trade or fight, what you get), with Requirements, Reward and a Tip.
- Double-checked: Gemini searches FFXIclopedia and BG-Wiki while writing, and marks any step where the wikis differ from the server's list with "(corrected)". It says so when it can't confirm something.
- Automatic: open a quest and its guide is written by itself (once your key is saved), then kept on your PC, so each quest is only asked for once. REWRITE asks again.

## 3.5.0
- Ask Gemini: at the bottom of every quest and mission there's an ASK GEMINI box. Ask anything about it, or leave the box empty to ask what to do next. The quest's name, its steps (done ones marked, plus the step you're on) and your question go to Google's Gemini, and the answer shows right there.
- Your key stays on your PC. Save it once with /ql ai key <your key> (/ql ai key clear removes it). It goes in a file in your own Ashita config folder (config\addons\ffxiquestlog\gemini-key.txt) and is never shown, put in chat, put on a command line or packed into the addon.
- The request runs in a hidden curl (part of Windows 10 and 11), so the game never freezes while Gemini thinks. /ql ai model <name> picks the model (default gemini-flash-latest).

## 3.4.1
- Missions you've already passed no longer show up as "not started". Every mission before the one you're on in your nation's line, Rise of the Zilart, Treasures of Aht Urhgan and Wings of the Goddess now counts as done, even when the game's done flags don't say so. So the list starts at the mission you're actually on, and that's the one the crystal and the step card follow.

## 3.4.0
- Choose where the window opens when you click the crystal: at its own place (as before), to the left of the crystal, or to the right. Set it with the OPENS button under Lock, or /ql side left, /ql side right, /ql side saved. Either way the window stays fully on screen.

## 3.3.0
- The crystal and the window now keep their own places. Put the crystal anywhere (say the top right corner); clicking it opens the window where you last had the window, always fully on screen.
- A small step card beside the crystal shows the quest you're on and its current step, without hovering. It sits to the left of the crystal (to the right when the crystal is at the screen's left edge). /ql step turns it off or on.
- The Trader in the Forest: step 2 is now "Trade Supplies Order to Phairet" in West Ronfaure (it was missing). Fixing how the list is built also filled in steps the game keeps open after a quest is finished, for 9 more quests (The Gift, Seeing Spots, Waking the Beast, Uninvited Guests and others).
- A talk step that only hands out again what the NPC just gave you (a lost item, or a second ask after saying no) is no longer listed as its own step (7 quests, such as Drachenfall and Water Way to Go).

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
