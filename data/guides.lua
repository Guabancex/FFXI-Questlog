-- Detailed walkthroughs, shown under a quest's steps in FFXI Questlog.
-- Keyed by quest log area, then quest id (the same ids as data/quests.lua).
-- Written from the FFXIclopedia, HorizonXI and BG-Wiki quest pages
-- (community wikis, CC BY-SA), checked against each other where they differed.
--
-- Fields: t = quest name (when the generated list has it wrong), req, start,
-- reward, rep (repeatable), steps = { ... }, notes = { ... }.
local G = {}

-- 1 = Bastok ---------------------------------------------------------------
G[1] = {
[0] = { req = "Bastok fame 1", start = "Wahid, Bastok Mines (I-8)", reward = "150 gil, title Tearjerker", rep = true,
  steps = {
    "Talk to Wahid in Bastok Mines (I-8); he wants a Siren's Tear.",
    "Go to North Gustaberg (Port Bastok Home Point #1 is closest) and head to J-9.",
    "Follow the river: a ??? spawns at a random spot along it.",
    "Unequip your main weapon, sub weapon and shield, then examine the ??? to get the Siren's Tear.",
    "Trade the Siren's Tear to Wahid.",
  },
  notes = { "Keep a free inventory slot before examining the ???.", "The ??? moves, so walk the whole river if you don't see it." } },

[1] = { req = "Bastok fame 1", start = "Talib, Port Bastok (F-6), downstairs in Warehouse 2", reward = "Bronze Knife",
  steps = {
    "Talk to Talib downstairs in Warehouse 2 (Port Bastok, F-6): Cornelia asks you to fetch Zinc Ore for Parraggoh. Accept.",
    "Get a Zinc Ore (monsters in Gustaberg drop it, or the Auction House).",
    "Trade the Zinc Ore to Talib to get the Palborough Mines Logs.",
    "Take the logs to Parraggoh in Bastok Mines (H-5), first house down the ramp to the lower level.",
  },
  notes = { "Declined Cornelia? Talk to Parraggoh to start it instead." } },

[2] = { req = "Bastok fame 1; to finish: level 7+ WAR, RDM, PLD, BST or SAM", start = "Powhatan, Steaming Sheep Restaurant, Port Bastok (E-6)", reward = "Spatha, title Bastok Welcoming Committee",
  steps = {
    "Talk to Powhatan in the Steaming Sheep Restaurant (Port Bastok, E-6).",
    "Get a Shell Shield and equip it.",
    "With the shield on, talk to Bartolomeo in the Arrivals section of the Air Travel Agency (Port Bastok).",
    "Watch the scene: greet Evrain, who walks to the tavern.",
    "Talk to Powhatan again to finish.",
  },
  notes = { "The shield must be equipped when you talk to Bartolomeo.", "You keep the Shell Shield. Next: Guest of Hauteur." } },

[3] = { t = "Guest of Hauteur", req = "Bastok fame 3, level 31+, a Maul or Replica Maul", start = "Powhatan, Port Bastok (E-6)", reward = "Targe (you keep the maul)",
  steps = {
    "Zone if you just finished Welcome to Bastok, then talk to Powhatan (Port Bastok, E-6).",
    "Equip a Maul or Replica Maul.",
    "With it equipped, talk to Bartolomeo in the Arrivals section of the Air Travel Agency.",
    "Talk to Powhatan again and pick the second option; he sends you to the guards.",
    "Talk to Steel Bones, the guard by the Port Bastok / Bastok Markets zone line: scene + Letter from Domien (key item).",
    "Bring the letter to Powhatan to finish.",
  } },

[4] = { req = "Bastok fame 1", start = "Corann, Port Bastok (K-6), inside the house", reward = "Bronze Subligar",
  steps = {
    "Talk to Corann inside the house at Port Bastok (K-6); he wants something big enough to hide behind.",
    "Get a Quadav Backplate (Quadav drop, or the Auction House).",
    "Trade the Quadav Backplate to Corann.",
  },
  notes = { "Next: Out of One's Shell." } },

[5] = { req = "Bastok fame 2; The Quadav's Curse done", start = "Ronan, Port Bastok (K-6)", reward = "title Shell Outer",
  steps = {
    "Talk to Ronan in Port Bastok (K-6).",
    "Get 3 Shell Bugs (Quadav drops, or the Auction House).",
    "Trade the 3 Shell Bugs to Ronan.",
    "Zone out and back in.",
    "Talk to Ronan again to finish.",
  },
  notes = { "The zone between the trade and the last talk is required." } },

[6] = { req = "Bastok fame 1", start = "Elki, Bat's Lair Inn, Bastok Mines (H-5)", reward = "Sitabaki, title Pursuer of the Past",
  steps = {
    "Talk to Elki in the Bat's Lair Inn (Bastok Mines, H-5) to get the Bouquet for the Pioneers.",
    "In North Gustaberg, take the south-side path at I-8 up Zegham Hill.",
    "Near the top, at the grassy, tree-covered spot (J-7), find the Palborough Pioneers Monument.",
    "Examine the monument to lay the bouquet.",
    "Go back to Elki to finish.",
  },
  notes = { "Zone before starting The Eleventh's Hour." } },

[7] = { req = "Bastok fame 3", start = "Elki, Bastok Mines (H-5)", reward = "Small Sword",
  steps = {
    "Zone after Hearts of Mythril, then talk to Elki (Bastok Mines, H-5).",
    "In Palborough Mines, take the elevator at I-8 up to the third floor.",
    "Head west through the split chamber, keeping left; the route has dead ends, so follow the map.",
    "On the H-7 / H-8 border, examine the Old Toolbox to get it (key item).",
    "Return to Elki (the one-way boat near the top of the elevator is quickest).",
    "Talk to Babenn in Bastok Mines (J-6) for the Small Sword.",
  } },

[8] = { req = "Tenshodo fame 1", start = "Talib, Port Bastok (F-6), downstairs in Warehouse 2", reward = "350 gil", rep = true,
  steps = {
    "Talk to Talib downstairs in Warehouse 2 (Port Bastok, F-6); he wants 4 Zinc Ore.",
    "Get 4 Zinc Ore (Gustaberg monsters, or the Auction House).",
    "Trade the 4 Zinc Ore to Talib.",
  },
  notes = { "Raises Tenshodo fame, not Bastok. Repeat with no zoning needed." } },

[9] = { req = "Bastok fame 1", start = "Gudav, Port Bastok (H-5)", reward = "Map of the Gusgen Mines",
  steps = {
    "Talk to Gudav in Port Bastok about his crew foreman.",
    "Optional: Dehlner (Port Bastok, H-5) gives a hint.",
    "Get a Dog Collar: Black Wolves in North Gustaberg drop it, or the Auction House.",
    "Trade the Dog Collar to Gudav.",
  } },

[10] = { req = "Bastok fame 1", start = "Horatius, Trader's Home, Bastok Markets (I-9)", reward = "400 gil", rep = true,
  steps = {
    "Talk to Horatius in the Trader's Home (Bastok Markets, I-9); talk again if needed to get the quest.",
    "Go to Dangruf Wadi while the weather is sunny or clear.",
    "At I/J-5, examine the ??? to get a Dangruf Stone.",
    "Trade the Dangruf Stone to Horatius.",
  },
  notes = { "The ??? only gives the stone in sunny or clear weather." } },

[11] = { req = "Bastok fame 1", start = "Malene, Bastok Markets (I-5)", reward = "500 gil, title Crab Crusher", rep = true,
  steps = {
    "Talk to Malene in her house in Bastok Markets (I-5): a monster took her parcel by the South Gustaberg lighthouse.",
    "Optional: Gwill, in Dalzakk's house on Kulatz Bridge, explains how to lure it with a Quus.",
    "Get a Quus (fish it, or buy it).",
    "In South Gustaberg (M-10), go behind the lighthouse and trade the Quus to the hidden spot; Bubbly Bernie appears.",
    "Defeat Bubbly Bernie for the Steam Clock.",
    "Trade the Steam Clock to Malene.",
  },
  notes = { "About level 10 solos Bernie.", "Bernie won't drop another clock while you still hold one." } },

[12] = { req = "Bastok fame 1", start = "Salimah, Bastok Markets (L-8)", reward = "100-350 gil", rep = true,
  steps = {
    "Talk to Salimah in Bastok Markets (L-8).",
    "Check the Vana'diel time and bring the item for that window:",
    "18:00-05:59: Sleepshroom (Funguar) - 200 gil.",
    "06:00-11:59: Treant Bulb (Saplings) - 200 gil.",
    "12:00-17:59: Wild Onion (Goblin Thugs or gardening) - 350 gil.",
    "Trade it to Salimah in the matching window, then zone before the next trade.",
  },
  notes = { "Wrong time window pays only 100 gil." } },

[13] = { req = "Bastok fame 1", start = "Michea, Bastok Markets (F-10)", reward = "180 gil", rep = true,
  steps = {
    "Talk to Michea in Bastok Markets (F-10).",
    "Trade her a Copper Ingot.",
  },
  notes = { "Repeat after zoning.", "At Bastok fame 2 she starts Father Figure instead." } },

[14] = { req = "Bastok fame 1", start = "Aquillina, Bastok Markets (K-9), in her house", reward = "100 gil", rep = true,
  steps = {
    "Get 4 Flint Stones.",
    "Talk to Aquillina in her house (Bastok Markets, K-9).",
    "Trade her the 4 Flint Stones.",
  },
  notes = { "Only once every 15 Earth minutes, shared by all players." } },

[15] = { req = "Bastok fame 1", start = "Hungry Wolf, Craftsmen's Eatery, Metalworks (G-9)", reward = "300 gil, title Hot Dog", rep = true,
  steps = {
    "Talk to Hungry Wolf in the Craftsmen's Eatery (Metalworks, G-9); he wants a Galkan Sausage.",
    "Buy a Galkan Sausage on the Auction House, or cook one:",
    "Get a Giant Sheep Meat.",
    "In South Gustaberg, follow the path from the northeast corner of K-10 to the Goblin camp on the small hill.",
    "Trade the Giant Sheep Meat to the ??? at the campfire.",
    "Wait 1 Earth minute without leaving the zone, then examine the fire for the Galkan Sausage.",
    "Trade the sausage to Hungry Wolf.",
  },
  notes = { "The Goblins at the camp aggro low levels." } },

[16] = { req = "Bastok fame 1", start = "Arawn, Bastok Markets (J-10)", reward = "Leather Gorget, title Stampeder",
  steps = {
    "Talk to Arawn (Bastok Markets, J-10) for a blank Stamp Sheet.",
    "Get a stamp from each of the 7 guards (examine the sheet for hints):",
    "Pavel - West Gate (D-11).",
    "Deadly Spider - 2nd level of the Depot (G-8).",
    "Tall Mountain - by the Alchemists' Guild (J-7).",
    "Romualdo - Southern Cannonry near the President's Office (K-9).",
    "Elayne - between the elevators (G-8), down the stairs to the temple.",
    "Ehrhard - northeast corner outside Warehouse #1 (G-5).",
    "Latifah - just north of the drawbridge (J-8).",
    "Return the full sheet to Arawn.",
  } },

[17] = { req = "Bastok fame 2", start = "Qiji, Port Bastok (I-7)", reward = "300 gil, title Qiji's Friend",
  steps = {
    "Talk to Qiji in Port Bastok (I-7); he wants a Brass Hairpin for his wife.",
    "Get a Brass Hairpin.",
    "Trade the hairpin to Romilda, standing next to Qiji.",
    "Talk to Qiji for the reward.",
  },
  notes = { "The hairpin goes to Romilda, not Qiji. Next: Till Death Do Us Part." } },

[18] = { req = "Bastok fame 3; Forever to Hold done", start = "Romilda, Port Bastok (I-7)", reward = "2,000 gil",
  steps = {
    "Zone after finishing Forever to Hold.",
    "Talk to Romilda in Port Bastok (I-7).",
    "Trade her Cotton Gloves.",
  } },

[19] = { req = "Bastok fame 2", start = "Pavvke, Bastok Mines (I-7)", reward = "550 gil", rep = true,
  steps = {
    "Talk to Pavvke in Bastok Mines (I-7).",
    "Get a Silver Name Tag: Onyx Quadav or Greater Quadav in Palborough Mines drop it, or the Auction House (Neck).",
    "Trade the Silver Name Tag to Pavvke.",
  } },

[20] = { req = "Bastok fame 3; a Mythril Sallet", start = "Detzo, Ore Street, Bastok Mines (I-6)", reward = "Wolf Gorget, title Contest Rigger",
  steps = {
    "Get a Mythril Sallet.",
    "Trade it to Detzo on Ore Street (Bastok Mines, I-6).",
  } },

[21] = { req = "Bastok fame 1 (do it before fame 2)", start = "Nbu Latteh, Bastok Markets (J-9)", reward = "200 gil (100 if you read the letter), title Ringbearer", rep = true,
  steps = {
    "Talk to Nbu Latteh (Bastok Markets, J-9); she gives you a Fire Crystal.",
    "Get a Copper Ring (not +1): synth it, buy it at Carmelide's Jewelry (Bastok Markets, I-8), or fish one up.",
    "Trade the Copper Ring to Roh Latteh, bottom-floor house in Bastok Mines (H-7): Letter from Roh Latteh (key item).",
    "Don't examine the letter.",
    "Return to Nbu Latteh to finish.",
  },
  notes = { "Repeatable until you reach Bastok fame 2." } },

[22] = { req = "Bastok fame 2", start = "Nbu Latteh, Bastok Markets (J-9)", reward = "Linen Robe",
  steps = {
    "Zone after Mom, the Adventurer?, then talk to Nbu Latteh (Bastok Markets, J-9).",
    "In Konschtat Highlands, examine the signpost at G-5 for the Painting of a Windmill (key item).",
    "Talk to Roh Latteh in Bastok Mines to finish.",
  } },

[23] = { req = "Bastok fame 2", start = "Evi, Port Bastok (H-6)", reward = "Scale Mail",
  steps = {
    "In Port Bastok (H-6) talk to Evi, then Rafaela next to him, then Evi again.",
    "In Konschtat Highlands, examine the ??? near the windmills at G-8 for the Tattered Mission Orders (key item).",
    "Return to Evi to finish.",
  } },

[24] = { req = "Bastok fame 2", start = "Baldric, lower level of the Darksteel Forge, Metalworks (G-9)", reward = "300 gil", rep = true,
  steps = {
    "Get a pinch of Valkurm Sunsand: during a sandstorm in Valkurm Dunes, examine the ??? on the overturned ship at H-9 (Siren Sands), or buy it on the Auction House.",
    "Talk to Baldric on the lower level of the Darksteel Forge (Metalworks, G-9).",
    "Trade him the Valkurm Sunsand.",
  },
  notes = { "Repeat after zoning." } },

[25] = { req = "Bastok fame 2", start = "Unlucky Rat, lower level of the Cermet Refinery, Metalworks (G-7)", reward = "Scroll of Warp",
  steps = {
    "Metalworks Home Point #2 takes you to the lower level of the Cermet Refinery.",
    "Talk to Unlucky Rat about his machine that's out of oil.",
    "Get a Slime Oil (Slime-family monsters, or the Auction House).",
    "Trade the Slime Oil to Unlucky Rat.",
  } },

[26] = { req = "Bastok fame 4", start = "Cid, Metalworks (H-8)", reward = "Ram Mantle",
  steps = {
    "Talk to Cid in Metalworks (H-8); he asks you to check on Hilda.",
    "Find Hilda in the Steaming Sheep Restaurant (Port Bastok, E-6); she moves between the stairs and upstairs.",
    "Get a Rolanberry (874) (Crawlers' Nest, or the Auction House under Food > Ingredients).",
    "Trade it to Hilda for the Unfinished Letter (key item).",
    "Bring the letter to Cid.",
  },
  notes = { "It must be Rolanberry (874), not another vintage. Next: The Usual." } },

[27] = { req = "Bastok fame 5; Cid's Secret done", start = "Hilda, Port Bastok (E-6)", reward = "Speed Bow",
  steps = {
    "Talk to Hilda in Port Bastok (E-6).",
    "Trade her a King Truffle for the Steaming Sheep Invitation (key item).",
    "Talk to Raibaht in Cid's Lab (Metalworks, G-8).",
    "Return to Hilda to finish.",
  },
  notes = { "Raibaht may need a second talk if Teak Me to the Stars or The Naming Game is active." } },

[28] = { req = "Level 30+", start = "Gumbah, Bastok Mines (J-7), upper floor of the house", reward = "Dark Knight job, Chaosbringer, title Dark Sider",
  steps = {
    "Talk to Gumbah upstairs in the house at Bastok Mines (J-7).",
    "In Palborough Mines, go to the boat at H-8, board it and pull the lever to ride to Zeruhn Mines: scene + Chaosbringer.",
    "Equip Chaosbringer and kill 100 monsters, landing the killing blow with a normal or critical melee hit.",
    "With Chaosbringer in your inventory, zone into Beadeaux for the scene that unlocks Dark Knight.",
  },
  notes = { "Weapon skills, Jump and self-destructs don't count.", "Only dropping the blade resets the count; ride the ferry again for a new one." } },

[29] = { req = "Bastok fame 2; Distant Loyalties not started", start = "Michea, Bastok Markets (F-10)", reward = "2,200 gil",
  steps = {
    "Talk to Michea in Bastok Markets (F-10).",
    "Trade her a Silver Ingot.",
  },
  notes = { "Next: The Return of the Adventurer." } },

[30] = { req = "Bastok fame 3", start = "Gwill, Bastok Markets (E-11), above Mjoll's General Goods", reward = "Cotton Headband",
  steps = {
    "Talk to Gwill above Mjoll's General Goods (Bastok Markets, E-11).",
    "Trade him a Cinnamon.",
  } },

[31] = { req = "Bastok fame 1", start = "Black Mud, Ore Street, Bastok Mines (J-7)", reward = "2,000 gil, title Drachenfall Ascetic",
  steps = {
    "Talk to Black Mud (Bastok Mines, J-7) for a Brass Canteen.",
    "In Dangruf Wadi, head north and ride the geyser at I-8 to the higher ledge.",
    "Ride the second geyser at J-3, in the far northeast.",
    "Follow the unmarked path northeast into the hidden part of North Gustaberg.",
    "Follow the river east, cross the bridge and keep east to the waterfall.",
    "Trade the Brass Canteen to the Waterfall Base (not the ???) for Drachenfall Water.",
    "Trade the Drachenfall Water to Black Mud.",
  },
  notes = { "Lost the canteen? Black Mud gives another.", "Drachenfall Water is also on the Auction House." } },

[32] = { req = "Bastok fame 3", start = "Goraow, Ore Street stairs, Bastok Mines (I-6)", reward = "900 gil, title Avenger", rep = true,
  steps = {
    "Talk to Goraow on the Ore Street stairs (Bastok Mines, I-6).",
    "Get a Quadav Helm (Quadav drop, or the Auction House).",
    "Talk to Goraow again so he asks for the helm, then trade it to him.",
  },
  notes = { "Repeats need no zoning." } },

[33] = { req = "Bastok fame 4", start = "High Bear, Metalworks (I-8)", reward = "Chakram, title Beadeaux Surveyor",
  steps = {
    "Talk to High Bear in Metalworks (I-8).",
    "In Beadeaux, go in, turn north at the wall at F-7, north to F-6, then east to H-6.",
    "From H-6 go south into the cave leading down; it comes out at H-7 on the lower map.",
    "Go west and south to the tunnel at F-8 back up to the surface (an Afflictor curses you on the way).",
    "Head south past the Mute at F-9, under the bridge, past the second Afflictor.",
    "Go east around the big smokestacks at G-9 / H-9.",
    "When it rains, a ??? appears at the base of the smokestacks: examine it for the Corrupted Dirt (key item).",
    "Bring the dirt to High Bear.",
  },
  notes = { "The ??? only appears in rain.", "Do The Curse Collector on the same trip." } },

[34] = { req = "Bastok fame 4", start = "Zon-Fobun, Bastok Markets (G-5)", reward = "Poison Cesti",
  steps = {
    "Talk to Zon-Fobun for the Cursepaper.",
    "In Beadeaux: north at the F-7 wall, north to F-6, east to H-6, then south into the cave down to H-7.",
    "Go west, south, then west to the glowing red Afflictor at G-8 and let it curse you.",
    "Go back east, take the first turn north, and touch the Mute at G-7 to be silenced.",
    "Bring the Cursepaper back to Zon-Fobun.",
  },
  notes = { "Get cursed before you touch the Mute.", "There's no message when the paper takes each curse." } },

[35] = { req = "Bastok fame 3", start = "Kurando, Port Bastok (H-6), end of the tunnel by the water", reward = "Black Neckerchief",
  steps = {
    "Talk to Kurando in Port Bastok (H-6).",
    "In Rolanberry Fields (K-7), wait for the airship to fly over: the Silk Caterpillar spawns behind a piece of crag sticking out of the ground (about every 11 minutes).",
    "Kill it for the Silkworm Egg.",
    "Trade the egg to Kurando.",
  } },

[36] = { req = "Bastok fame 1", start = "Benita, Port Bastok (J-6)", reward = "Traveler's Hat",
  steps = {
    "Talk to Benita in Port Bastok (J-6) about her clogged chimney.",
    "Talk to Tete, outside at Port Bastok (I-5), to hear about Bomb Ash.",
    "Get a Bomb Ash (Bombs, or the Auction House).",
    "Trade the Bomb Ash to Benita.",
  } },

[37] = { req = "Bastok fame 1", start = "Tami, Bastok Mines (J-8)", reward = "10 gil; eventually Rabbit Mantle", rep = true,
  steps = {
    "Talk to Tami in Bastok Mines (J-8) for Tami's Note.",
    "Don't read the note (reading it ends the repeats).",
    "Give the note to Zelman in Zeruhn Mines (I-8).",
    "Return to Tami for the reward.",
  },
  notes = { "Repeat it until she gives the Rabbit Mantle." } },

[38] = { req = "Bastok fame 1", start = "Degenhard, Bastok Markets (I-10), by Galkan Bridge", reward = "Map of the Dangruf Wadi",
  steps = {
    "Optional: talk to Degenhard (Bastok Markets, I-10), then Biggorf nearby for a hint.",
    "Get a Bone Chip.",
    "Trade the Bone Chip to Degenhard.",
  },
  notes = { "It never shows in your log until you finish it." } },

[39] = { req = "Bastok fame 1", start = "Gerbaum, Bastok Mines (F-8)", reward = "150 gil", rep = true,
  steps = {
    "Talk to Gerbaum in Bastok Mines (F-8).",
    "Collect 3 Zeruhn Soot from monsters in Zeruhn Mines.",
    "Trade the 3 Zeruhn Soot to Gerbaum.",
  } },

[40] = { req = "Bastok fame 3", start = "Mighty Fist, Darksteel Forge, Metalworks (G-9)", reward = "8,000 gil", rep = true,
  steps = {
    "Talk to Mighty Fist in Metalworks (G-9).",
    "Get 2 Darksteel Ore (Gusgen Mines; also reported in Zeruhn Mines).",
    "Trade the 2 Darksteel Ore to Mighty Fist.",
  } },

[41] = { req = "Bastok fame 1", start = "Foss, Firewater Circle, Bastok Markets (F-7)", reward = "300 gil, title Bucket Fisher", rep = true,
  steps = {
    "Talk to Foss (Bastok Markets, F-7) and tell him you fish.",
    "Get 5 Rusty Buckets (fish them up, or the Auction House).",
    "Trade the 5 Rusty Buckets to Foss.",
  } },

[42] = { req = "Bastok fame 3; Airship Pass", start = "Agapito, Port Bastok (G-6), outside the Air Travel Agency", reward = "2,100 gil, title Star of Ifrit",
  steps = {
    "Talk to Agapito outside the Air Travel Agency (Port Bastok, G-6).",
    "At night (about 19:40-06:00) with a full moon (90 percent or more), ride the San d'Oria-Jeuno airship; board anywhere except Port Bastok.",
    "Find the hidden ??? on the ship's rail and examine it for the Carrier Pigeon Letter (key item).",
    "Bring the letter to Agapito.",
  },
  notes = { "Boarding at Port Bastok won't give the letter. Next: Love and Ice." } },

[43] = { req = "Bastok fame 5; Carrier Pigeon Letter (from The Stars of Ifrit)", start = "Carmelo, Port Bastok (E-6)", reward = "Lamia Harp, title Sorrow Drowner",
  steps = {
    "Examine the Carrier Pigeon Letter, then talk to Carmelo (Port Bastok, E-6) for Carmelo's Song Sheet.",
    "Optional: check the forecast with Maleme in Southern San d'Oria (J-8).",
    "Go to the pond at G-10 in Beaucedine Glacier.",
    "In dark or clear weather, a Mirror Pond target appears: examine it for the scene.",
    "Return to Carmelo to finish.",
  },
  notes = { "The Mirror Pond disappears during ice weather." } },

[44] = { req = "Bastok fame 1", start = "Brygid, Gold Street, Bastok Markets (K-9)", reward = "Gloves, title Brygid-Approved",
  steps = {
    "Get a Robe and a Bronze Subligar.",
    "Equip both.",
    "Talk to Brygid on Gold Street (Bastok Markets, K-9) while wearing them.",
  } },

[45] = { req = "Bastok fame 1; The Kuftal Tour done; a party of 2+ (one at level 10-15 to sync, or all level 1-15)", start = "Izabele, Metalworks (G-8)", reward = "500 gil, title Gustaberg Tourist",
  steps = {
    "Talk to Izabele in Metalworks (G-8).",
    "Form a party (real players; Alter Egos don't count) that meets the level rule.",
    "Once everyone has the quest, go to the west part of North Gustaberg.",
    "Talk to Hunting Bear by the Drachenfall falls for the scene.",
  } },

[46] = { req = "Bastok fame 2", start = "Yazan, Harbor Way, Port Bastok (H-6)", reward = "350 gil, title Sand Blaster", rep = true,
  steps = {
    "Talk to Yazan on Harbor Way (Port Bastok, H-6).",
    "Hunt Sand Bats (Valkurm Dunes) for a Sand Bat Fang.",
    "Trade the fang to Yazan.",
  } },

[47] = { req = "Bastok fame 3; Blade of Darkness done", start = "Gumbah, Bastok Mines (J-7)", reward = "Deathbringer",
  steps = {
    "Talk to Gumbah (Bastok Mines, J-7) for the Letter from Zeid (key item).",
    "Reach 200 total kills with Chaosbringer (earlier kills count).",
    "In Gusgen Mines (first map): from the entrance, go right at the first junction, left at the next.",
    "Take the tunnel branching right, follow the bend, then the next right to the pond at J-7.",
    "Trade Chaosbringer to the ??? in the water: scene with Zeid, and it becomes Deathbringer.",
  },
  notes = { "Smothered Schmidt (ghost NM) sits at the pond and hears you: use Sneak.", "Only dropping the blade resets the count." } },

[48] = { req = "Tenshodo fame 2", start = "Paujean, Warehouse 2, Port Bastok (F-6)", reward = "Purple Belt",
  steps = {
    "Talk to Paujean in Warehouse 2 (Port Bastok, F-6).",
    "Get a Rampaging Horn and a Lumbering Horn from the ram NMs.",
    "Trade both horns to Paujean.",
  },
  notes = { "Next: Fistful of Fury." } },

[49] = { req = "Bastok fame 4, level 10+", start = "Virnage, back room of the Bat's Lair Inn, Bastok Mines (H-5)", reward = "Scroll of Teleport-Dem",
  steps = {
    "Talk to Virnage in the Bat's Lair Inn back room (Bastok Mines, H-5).",
    "In Garlaige Citadel, go to the room nearest the H-8 path; the ??? is in a corner (G-8 / H-8).",
    "Examine it for the Bucket of Divine Paint (key item).",
    "Return to Virnage for the Letter from Virnage (key item).",
    "Take the letter to Eperdur upstairs in the Cathedral, Northern San d'Oria (M-7).",
  },
  notes = { "Watch for the holes in the Citadel floor." } },

[50] = { req = "Bastok fame 1", start = "Valah Molkot, Port Bastok (J-12)", reward = "Back-alley exits from your Bastok Mog House",
  steps = {
    "Talk to Valah Molkot in Port Bastok (J-12) until she mentions a red flower.",
    "Trade her an Amaryllis.",
  } },

[51] = { req = "Monk level 40+; a Pickaxe", start = "Oggbi, Steaming Sheep Restaurant, Port Bastok (E-6)", reward = "Beat Cesti",
  steps = {
    "Buy a Pickaxe from Numa (Port Bastok, E-7).",
    "Talk to Oggbi in the Steaming Sheep Restaurant (Port Bastok, E-6).",
    "In Gusgen Mines: north across the first map, down the stairs, into map 2 by the west door.",
    "Go to the northwest room, follow the west corridor, take the passage at the southwest corner of F-5 down.",
    "In the second room, use the Pickaxe on the ??? at the left of the northwest corner: Wandering Ghost appears.",
    "Defeat it for the Miner's Pendant.",
    "Trade the pendant to Oggbi.",
  },
  notes = { "With hand-to-hand skill over 250, Oggbi offers The Walls of Your Mind first; talk again.", "Once flagged, any job can finish it." } },

[52] = { req = "Monk level 50+; Ghosts of the Past done (zone after)", start = "Oggbi, Port Bastok (E-6)", reward = "Temple Gaiters",
  steps = {
    "Talk to Oggbi (Port Bastok, E-6); he sends you to Fei'Yin.",
    "In Fei'Yin, zone into Qu'Bia Arena and back out for the Letter from Dalzakk (key item).",
    "In Davoi, clear the Orcs near the Hide Flap on the tent at F-7.",
    "Examine the Hide Flap: Bilopdop (MNK) and Deloknok (PLD) appear. Defeat both.",
    "Examine the Hide Flap again (it may move to another tent) for the San d'Orian Martial Arts Scroll (key item).",
    "Bring the scroll to Oggbi.",
  },
  notes = { "Each party member must pop their own set of NMs." } },

[53] = { req = "Monk level 50+; a Yagudo Drink and a Xalmo Feather", start = "Ayame, Metalworks (K-7)", reward = "Temple Hose, title Paragon of Monk Excellence",
  steps = {
    "Talk to Ayame in Metalworks (K-7).",
    "Get a Yagudo Drink and a Xalmo Feather.",
    "In Castle Oztroja, use the Yagudo Drink to lure out the Yagudo NM, and defeat it.",
    "Return to Ayame to finish.",
  } },

[54] = { req = "Warrior level 40+", start = "Phara, Bastok Mines (J-9)", reward = "Razor Axe",
  steps = {
    "Talk to Phara in Bastok Mines (J-9).",
    "In Davoi, find the Hide Flap on the tents around K-9/K-10; clear the nearby Orcs first.",
    "Touch it: Barakbok (DRK, kill first) and Gavotvut (WAR) appear. Defeat both.",
    "Examine the Hide Flap again (it moves nearby) for the Sword Grip Material.",
    "Bring it to Phara; come back the next Vana'diel day for Yasin's Sword (key item).",
    "Take Yasin's Sword to Naji at the President's Office door (Metalworks, J-8) for the Razor Axe.",
  },
  notes = { "Only the warrior who spawned the NMs gets the key item.", "Both NMs resist Sleep." } },

[55] = { req = "Warrior level 50+", start = "Phara, then Deidogg, Bastok Mines (H-6)", reward = "Fighter's Calligae",
  steps = {
    "Talk to Phara (Bastok Mines, J-9), then talk to Deidogg (H-6) twice as Warrior: he wants a Mottled Quadav Egg.",
    "In Palborough Mines, take the I-8 elevator to the third floor; at G-10 examine the ??? to spawn Ni'Ghu Nestfender (PLD).",
    "Defeat it for the Mottled Quadav Egg, and trade the egg to Deidogg.",
    "In Castle Oztroja, go past the first trapdoor, up to the 4-lever door at SW G-8 (the code is at the dead end at I-10).",
    "Up the stairs in the pool room, kill a Yagudo Parasite for a Parasite Skin.",
    "Trade the skin to Deidogg; come back the next Vana'diel day for the Fighter's Calligae.",
  },
  notes = { "Don't touch the ??? again after the fight or another NM spawns." } },

[56] = { req = "Warrior level 50+; a Ginger Cookie; wait a game day after The Talekeeper's Truth", start = "Deidogg, Ore Street, Bastok Mines (H-6)", reward = "Fighter's Lorica, title Paragon of Warrior Excellence",
  steps = {
    "Trade a Ginger Cookie to Deidogg (Bastok Mines, H-6). Any job works from here.",
    "In Behemoth's Dominion, examine the ??? to pop the Goblin thieves (a Ranger, a White Mage and Picklix Longindex) and defeat them.",
    "Fight the Ranger last, out of its melee range; kite the White Mage around the rocks.",
    "Zone into Qufim Island for the scene and the Fighter's Lorica.",
  },
  notes = { "Lose claim or call for help and you won't get the scene.", "The NMs pop once per game day." } },

[57] = { req = "Dark Knight level 40+ (main)", start = "Raibaht, Cid's Lab, Metalworks (G-8)", reward = "Raven Scythe",
  steps = {
    "As DRK 40+, talk to Raibaht in Cid's Lab. Any job can do the rest.",
    "Talk to Mighty Fist at the Darksteel Forge for the Letter from the Darksteel Forge.",
    "Talk to Cochal-Monchal in the west wing of the Optistery, Windurst Waters North (F-8).",
    "Get 1-2 Yagudo Cherries (one for the NM; a second only for optional Quu Bokye dialogue).",
    "In Giddeus map 1, drop down the hole at H-7 (Drop D), head south and then southeast to H-14.",
    "Trade a Yagudo Cherry to the ??? at H-14 to spawn Vaa Huja; defeat it.",
    "Examine the ??? again for the Darksteel Formula (key item).",
    "Return to Raibaht to finish.",
  },
  notes = { "Don't jump off any cliffs after leaving the cave near H-14." } },

[58] = { req = "Dark Knight level 50+; Dark Legacy done; one Darksteel Ingot per group", start = "Cid, Cid's Lab, Metalworks (G-8)", reward = "Chaos Sollerets",
  steps = {
    "Talk to Cid in Cid's Lab.",
    "Zone into Ordelle's Caves from La Theine Plateau for a scene with Zeid.",
    "Map 1, SW corner of I-8: trade the Darksteel Ingot to the ??? to spawn Gerwitz's Axe; defeat it for Gerwitz's Axe.",
    "Take the south passage at H-9 up, go south to the hole at H-11/H-12 and drop down.",
    "Head northeast to I-11, on to J-8 on the third map, then follow the path to H-8.",
    "Trade Gerwitz's Axe to the ??? to spawn Gerwitz's Sword; defeat it for Gerwitz's Sword.",
    "Continue south to the last ??? at H-10, trade Gerwitz's Sword: Gerwitz's Soul (ghost, about level 54). Defeat it.",
    "Exit to La Theine Plateau from G-10 for the scene and reward.",
  },
  notes = { "The map marks the first ??? at H-11; it's really at I-8.", "Die and leave the zone and you need a new ingot." } },

[59] = { req = "Dark Knight level 50+; a Quadav Mage Blood", start = "Zeid, Beadeaux (G-8)", reward = "Chaos Burgeonet, title Paragon of Dark Knight Excellence",
  steps = {
    "Farm a Quadav Mage Blood from Topaz Quadav or Spinel Quadav (each DRK needs their own).",
    "In Delkfutt's Tower, take teleporter I at J-6 on the 7th floor to a small room on the 6th floor.",
    "Trade the blood to the ??? to spawn Gerwitz's Scythe and two Scythe Victim skeletons.",
    "Hold the skeletons, kill them fast, then defeat Gerwitz's Scythe.",
    "Take the teleporter out for the scene and reward.",
  },
  notes = { "Lose and you need another Quadav Mage Blood." } },

[60] = { req = "Level 30+; Airship Pass for Kazham (to reach Norg)", start = "Kaede, Port Bastok (J-5), northernmost house", reward = "Ninja job",
  steps = {
    "Talk to Kaede (Port Bastok, J-5) for a scene.",
    "Talk to Kagetora in Warehouse 2 (Port Bastok, F-6).",
    "Talk to Ensetsu in the northernmost house (Port Bastok, I-5) and accept his favor.",
    "In Korroloka Tunnel map 5 (L-8), clear the Thread Leeches, then examine the ??? to spawn 3 Korroloka Leeches.",
    "Defeat them and examine the ??? again for the Strangely Shaped Coral.",
    "Talk to Ensetsu, then take the coral to Ryoma on the Norg docks (H-8) for the Sealed Dagger.",
    "Bring the Sealed Dagger to Ensetsu to finish.",
  },
  notes = { "Whoever spawned the leeches must also examine the ??? after the fight." } },

[61] = { req = "Bastok fame 6", start = "Juroro, Port Bastok (I-8), by the drawbridge", reward = "Pick one: Titan pact, 10,000 gil, Desert Light, Earth Belt, Earth Ring or Titan's Cudgel", rep = true,
  steps = {
    "Talk to Juroro (Port Bastok, I-8) for the Tuning Fork of Earth (talk a few times if needed).",
    "Enter Quicksand Caves from Eastern Altepa Desert (J-7) and head for the Cloister of Tremors.",
    "Room 1: hug the left wall, drop east, follow the passage south.",
    "Room 2: go due west along the north wall and through the small passage.",
    "Room 3 (E/F-9): drop off the west wall, then keep right to the Earth Protocrystal.",
    "Use the tuning fork on the protocrystal and defeat Titan Prime.",
    "Bring the Whisper of Tremors back to Juroro.",
  },
  notes = { "Everyone in the fight needs a fork; 30-minute limit.", "Don't use Earth spells or weapon skills: they heal Titan.", "Repeat after Japanese midnight." } },

[62] = { req = "Bastok fame 7; Love and Ice done (zone once)", start = "Carmelo, Port Bastok (E-6)", reward = "10,000 gil",
  steps = {
    "Talk to Carmelo (Port Bastok, E-6).",
    "Open Treasure Chests (not coffers) for three key items:",
    "Un Moment - Castle Zvahl Baileys or Castle Zvahl Keep.",
    "L'Ancienne - Labyrinth of Onzozo.",
    "L'Ephemere - Sea Serpent Grotto.",
    "Talk to Carmelo, zone out and back, then talk to him again to finish.",
  },
  notes = { "Each chest needs its key unless you're a Thief.", "The quest must be active when you open them." } },

[63] = { req = "Bastok fame 7; A Test of True Love done (zone once)", start = "Carmelo, Port Bastok (E-6)", reward = "Siren Flute",
  steps = {
    "Talk to Carmelo for the Chanson de Liberte (key item).",
    "In The Sanctuary of Zi'Tah, find the ??? in the middle of H-8 (by the spring and the ring of white-flowered trees).",
    "At dusk (17:00-18:00), examine the ??? for the scene and reward.",
  } },

[64] = { req = "Bastok fame 5; a Hatchet", start = "Zacc, Bastok Markets (G-9), by the fountain", reward = "4 Cactus Stems",
  steps = {
    "Talk to Zacc by the fountain (Bastok Markets, G-9).",
    "Talk to Malene (Bastok Markets, I-5).",
    "Talk to Enu (Bastok Markets, G-9); she asks for a Fallen Star.",
    "Use a Hatchet on Logging Points in Yuhtunga Jungle or Yhoator Jungle until you get the Fallen Star.",
    "Trade it to Enu on a clear night (20:00-04:00).",
  } },

[65] = { req = "Bastok fame 1; not done this conquest week; a big group (or 2+ SMNs)", start = "Raifa, Steaming Sheep Restaurant, Port Bastok (D-6)", reward = "5,000 gil, title Cerulean Soldier", rep = true,
  steps = {
    "Talk to Raifa (Port Bastok, D-6).",
    "In Gusgen Mines, buff up and talk to Degga (H-9, near the end of the entry corridor) for the level-25 ointment.",
    "At the first four-way junction take the west corridor, turn north at G-9 and keep north to G-6.",
    "Clear G-6 and the deck around the chest at H-6.",
    "Examine the ??? to spawn two Pudding NMs and defeat them (weak to magic and fire).",
    "Examine the ??? again for the Indigested Ore (key item).",
    "Remove the cap with Degga (or log out), then return to Raifa.",
  },
  notes = { "Once per conquest week.", "Being KO'd removes the cap: talk to Degga again after a Raise." } },

[66] = { req = "Great Axe skill 240+ (can use the Lv71 Axe of Trials); no other weapon skill quest", start = "Iron Eater, Metalworks (J-8)", reward = "Weapon skill Steel Cyclone",
  steps = {
    "Talk to Iron Eater for the Axe of Trials and Weapon Training Guide.",
    "With the axe, earn 300 points on Easy Prey or better: 1 per weapon skill, 2/3/5 for closing a level 1/2/3 skillchain.",
    "Unsynced, check the axe: when its elemental bonus is gone, the latent is broken.",
    "Trade the axe to Iron Eater for the Map to the Annals of Truth.",
    "In The Sanctuary of Zi'Tah, examine the ??? in the far northwest of F-6 to spawn Greenman, and defeat it.",
    "Examine the ??? again for the Annals of Truth and bring it to Iron Eater.",
  } },

[67] = { req = "Ranger level 72+, Marksmanship 250+; no other weapon skill quest", start = "Cid, Metalworks (H-8)", reward = "Weapon skill Detonator",
  steps = {
    "Talk to Cid for the Gun of Trials and Weapon Training Guide.",
    "Use ranged weapon skills with the Gun of Trials until you reach 300 points.",
    "Trade the gun to Cid for the Map to the Annals of Truth.",
    "In The Boyahda Tree map 3 (J-8), examine the ??? to spawn Beet Leafhopper, and defeat it.",
    "Examine the ??? again for the Annals of Truth and bring it to Cid.",
  } },

[68] = { req = "Level 71+, Great Sword skill 250+; no other weapon skill quest", start = "Gumbah, Bastok Mines (J-7)", reward = "Weapon skill Ground Strike",
  steps = {
    "Talk to Gumbah for the Sword of Trials and Weapon Training Guide.",
    "Earn 300 points with it on Easy Prey or better until the latent breaks.",
    "Trade the sword to Gumbah for the Map to the Annals of Truth.",
    "In Western Altepa Desert (E-9), examine the ??? to spawn Maharaja, and defeat it.",
    "Examine the ??? again for the Annals of Truth and bring it to Gumbah.",
  } },

[69] = { req = "Monk or Puppetmaster level 71+, Hand-to-Hand 250+; no other weapon skill quest", start = "Oggbi, Port Bastok (E-6)", reward = "Weapon skill Asuran Fists",
  steps = {
    "Talk to Oggbi for the Knuckles of Trials and Weapon Training Guide.",
    "Earn 300 points with them until the latent breaks (unsync before you check).",
    "Trade the knuckles to Oggbi for the Map to the Annals of Truth.",
    "In Bostaunieux Oubliette, go south, west down the long corridor, through the wooden door; the NPC there opens the trap door. Drop down.",
    "On the third map, small room at I-8: clear the leeches, then examine the ??? to spawn Bodach, and defeat it.",
    "Examine the ??? again for the Annals of Truth and bring it to Oggbi.",
  } },

[70] = { req = "Bastok fame 6", start = "Trilok, Port Bastok (D-6)", rep = true,
  steps = {
    "Talk to Trilok (Port Bastok, D-6).",
    "Zone into Crawlers' Nest from Rolanberry Fields; Olavia (Hume woman) appears. Zone again if she doesn't.",
    "Talk to her to stop her, then again to get her moving.",
    "Clear monsters from her path and stop her before she walks into any camp; she takes one of three routes from the entrance.",
    "At the end, every party member talks to her for the Completion Certificate.",
    "Return to Trilok.",
  },
  notes = { "Once per conquest week.", "Only one Escort for Hire at a time." } },

[71] = { req = "Fame 1 in any nation; Airship Pass", start = "Grin, Port Bastok (G-7)", reward = "500 gil each time; Discerning titles", rep = true,
  steps = {
    "Talk to Grin (Port Bastok, G-7), study the owner's look, and say you've got it: Dropped Item (key item).",
    "Board the next airship.",
    "In flight, find the passenger who matches the owner exactly (hair, hat, body, hands, legs, feet).",
    "Trade the Dropped Item to that passenger.",
    "After landing, collect 500 gil.",
  },
  notes = { "Wrong passenger: they keep it and you get nothing." } },

[72] = { req = "Summoner level 20+; Bastok fame 2", start = "Ferrol, Port Bastok (I-8), by the drawbridge", reward = "Titan pact, Scroll of Instant Warp",
  steps = {
    "Talk to Ferrol (Port Bastok, I-8) for the Mini Tuning Fork of Earth.",
    "When ready, trade the mini fork to Ferrol; he warps you to the Cloister of Tremors.",
    "Trade the mini fork to the protocrystal to start the fight, and defeat Titan.",
  },
  notes = { "Summoner only." } },

[73] = { req = "Ninja level 20+, Tenshodo fame 4", start = "Romualdo, Metalworks (K-9)", reward = "Fukuro, title Assassin Reject",
  steps = {
    "As Ninja 20+, talk to Romualdo in the Cannonry (Metalworks, K-9).",
    "Talk to Ayame in the other Cannonry room.",
    "Get a Palborough Chest Key and open the treasure chest in Palborough Mines for the Diary of Mukunda.",
    "Talk to Kagetora (Port Bastok, F-6).",
    "Talk to Ayame again.",
    "Talk to Alois in Metalworks (J-8) for the reward.",
  },
  notes = { "Only the start needs Ninja." } },

[74] = { req = "Level 52+; one Artifact Armor piece equipped", start = "Brygid, Bastok Markets (K-9)", reward = "A level 50 body armor of your choice", rep = true,
  steps = {
    "Wearing an AF piece, talk to Brygid; she asks for a body and leg piece your job can wear (level 60 or under).",
    "Come back wearing them; pick one of 13 level 50 body armors.",
    "Get the matching subligar (Rare/Ex) from Fomors in Phomiuna Aqueducts or the Sacrarium.",
    "Trade the subligar to Brygid for the body armor.",
  },
  notes = { "You're locked into your pick until you turn the subligar in." } },

[75] = { req = "Bastok fame 3; Chains of Promathia; 11 Hoary Bomb Ash (bring 12)", start = "Ayame, Cannonry, Metalworks (K-7)", reward = "2,200 gil",
  steps = {
    "Talk to Ayame (Metalworks, K-7) and accept.",
    "Talk to Ravorara in front of the Steaming Sheep (Port Bastok, E-7).",
    "In Oldton Movalpolos, talk to Brakobrik (K-11) and pick the option that starts the job.",
    "Kill Ancient Bombs for Hoary Bomb Ash (up to 4 each).",
    "Trade Brakobrik 1 ash, then 2, then 3, then 4 (one at a time) for four key items.",
    "Bring each key item to Ravorara separately (100, 200, 300 and 400 gil).",
    "Trade Brakobrik one more ash and decline his offer for the Old Nametag (if you get a Dusty Tome, trade one more).",
    "Take it to Ravorara, then talk to Pavvke in Bastok Mines (I-7) to finish.",
  },
  notes = { "Hoary Bomb Ash can't be sold on the Auction House." } },

[76] = { req = "Bastok fame 2; healer job (level capped at 10)", start = "Marin, Kulatz Bridge, Bastok Markets (E-10)", reward = "1,500 gil", rep = true,
  steps = {
    "Talk to Marin (Bastok Markets, E-10).",
    "As a curing job (WHM best), zone into Dangruf Wadi; Ken tells you to leave.",
    "Talk to Ken and pick \"I wasn't talking to you, squirt!\"",
    "Follow Ken out of his sight and keep him alive with cures along his route.",
    "When he zones out at the entrance, talk to Marin there for Ken's Escort Reward, then to Marin in Bastok Markets for 1,500 gil.",
  },
  notes = { "30-minute limit. Ken spots you if you're in his view.", "Once per conquest week." } },

[77] = { req = "Bastok fame 5", start = "Ayame, Metalworks (K-7), upper level", reward = "3,000 gil",
  steps = {
    "Talk to Ayame (Metalworks, K-7).",
    "Talk to Virnage in the Bat's Lair Inn (Bastok Mines, I-5) for the Dawn Talisman (key item).",
    "In Oldton Movalpolos (K-10), talk to Rakorok: Bugallug (level 45-50) spawns at once. Defeat it.",
    "Talk to Rakorok again for the scene.",
    "Return to Virnage for the reward.",
  } },

[78] = { req = "Bastok fame 5; Misareaux Garlic; Ahriman Tears; 10,000 gil (returned)", start = "Ayame, Metalworks (K-7)", reward = "12,000 gil, Bowyer Ring",
  steps = {
    "Talk to Ayame (Metalworks, K-7).",
    "Get Misareaux Garlic.",
    "Trade 10,000 gil to Magriffon to continue (you get it back).",
    "Each party member with the quest trades an Ahriman Tear to Tarnotik to be teleported in.",
    "At the Shaft Entrance pick the Return to the Depths battlefield; answer the top option to every question.",
    "Defeat Twilotak (DRK); the clergymen and wisewomen at the back can be ignored.",
    "Leave Mine Shaft #2716 (Escape, or Sleakachiq's teleport for 800 gil).",
    "Return to Ayame (talk twice if needed) for the Bowyer Ring.",
  },
  notes = { "Buffs wear off on entry; no Trusts inside." } },

[79] = { req = "Bastok fame 3", start = "Raibaht, Cid's Lab, Metalworks (G-8)", reward = "2,100 gil",
  steps = {
    "Talk to Raibaht in Cid's Lab.",
    "Go to Carpenters' Landing (through Jugner Forest).",
    "Get a Garhada Teak Lumber from the monsters you fish up on the Phanauet Channel barge or the Carpenters' Landing pier.",
    "Trade the lumber to Raibaht.",
  } },

[80] = { req = "Bastok fame 4; Teak Me to the Stars done (zone after)", start = "Raibaht, Metalworks (G-8)", reward = "3,000 gil",
  steps = {
    "Talk to Raibaht for the Molybdenum Box (key item).",
    "In Delkfutt's Tower, use the Delkfutt Key on the basement door at E-8 (first floor).",
    "In the basement, go to I-6 and try the cermet door: Orna and two Fomorian Spears appear. Defeat them.",
    "Try the door again for the scene.",
    "In Lower Jeuno, search the streetlamps for the Hyper Altimeter.",
    "Return to Raibaht.",
  } },

[81] = { req = "Bastok fame 5", start = "Raibaht, Metalworks (G-8)", reward = "3,600 gil (first time), name the airship, title Hyper Ultra Sonic Adventurer", rep = true,
  steps = {
    "Talk to Raibaht in Cid's Lab.",
    "Enter Pso'Xja from Beaucedine Glacier (G-9 entrance is best).",
    "Defeat Cryptonberry Plaguers or Stalkers for an Ordrynite (or dig in Beaucedine Glacier).",
    "Trade the Ordrynite to Raibaht.",
    "Pick three words for the airship's name.",
  } },

[82] = { req = "Chains of Promathia 6-3 done (with Cid's 6-4 scene)", start = "Ghebi Damomohe, Neptune's Spire, Lower Jeuno (I-7)", reward = "CCB Polymer Pump", rep = true,
  steps = {
    "Talk to Ghebi Damomohe in Neptune's Spire (Lower Jeuno, I-7) and pick the first option.",
    "Pso'Xja F-7 entrance: Carmine Chip, and the Gray Chip from the Diremites in the first room.",
    "Pso'Xja G-9 entrance: the Cyan Chip (Stone Door puzzle needs a bracelet from the Doll pairs).",
    "Trade one Carmine, Gray and Cyan Chip to Cid in Cid's Lab (Metalworks).",
  } },

[83] = { req = "Bastok fame 3", start = "Salim, Metalworks (G-7), on the balcony over the north elevator", reward = "Depends on the help item you pick", rep = true,
  steps = {
    "Talk to Salim on the balcony (Metalworks, G-7). Don't zone after this.",
    "Examine the ??? at the Temple of the Goddess altar (Metalworks, G-8) and pick a help item.",
    "Ask a hint NPC (Folzen, Darha, Helmut, Hungry Wolf or Striking Snake) for the switch order.",
    "Switches: small in the Cermet Refinery (G-7), medium at the replica (G-8), large at the kiln outside the Blacksmiths' Guild (F-8).",
    "Press them in the hinted order; answer the guards (Gentle Tiger / Militant Gale) with the matching option.",
    "When you hear noise from the temple, go back to the ??? for the scene and reward.",
  },
  notes = { "A wrong switch resets your progress.", "Once per conquest week." } },

[84] = { req = "Bastok fame 1", start = "Alib-Mufalib, Beligen Square, Port Bastok (K-7)", reward = "Blue Invitation Card; 300-gil warp to Whitegate",
  steps = {
    "Talk to Alib-Mufalib for the Blue Sentinel Badge; examine it for your contacts.",
    "Port Bastok: Kaede (J-5), Patient Wheel (F-5), Paujean (F-6), Hilda (E-6), Tilian (F-8).",
    "Metalworks: Raibaht (G-8), Invincible Shield (G-8), Manilam (G-7), Kaela (I-8), Ayame (K-7).",
    "Bastok Markets: Harmodios (K-10), Arawn (J-10), Horatius (I-9), Ken (E-10), Pavel (E-11).",
    "Bastok Mines: Griselda (H-5), Goraow (I-6), Echo Hawk (I-7), Deidogg (H-6), Vaghron (H-9).",
    "Return to Alib-Mufalib for the Blue Invitation Card.",
  },
  notes = { "Your badge flashes for each right contact." } },

[85] = { req = "Puppetmaster level 66+; Puppetmaster's Testimony", start = "Shamarhaan, Firewater Circle, Bastok Markets (F-9)", reward = "Level cap 75, title Master of Manipulation",
  steps = {
    "Get a Puppetmaster's Testimony.",
    "Trade it to Shamarhaan (Bastok Markets, F-9).",
  } },

[86] = { req = "Bastok fame 5; Wings of the Goddess", start = "Ferghus, Craftsmen's Eatery, Metalworks (G-9)", 
  steps = {
    "Talk to Ferghus in the Craftsmen's Eatery (Metalworks).",
    "Talk to Leonhardt.",
    "In Bastok Markets [S], talk to Raginmund by Harmodio's Music Shop (L-10).",
    "Hunt Copper Quadav and Onyx Quadav in Grauberg [S] for a Red Oven Mitt.",
    "Trade the mitt to Leonhardt.",
    "Talk to Umberto by the music shop in Bastok Markets (L-10) to finish.",
  } },

[87] = { req = "Bastok fame 1; Wings of the Goddess; Fish Bones", start = "Offa, Bastok Markets (F-10), 2nd-floor house", reward = "Rolanberry, Withered Rolanberry",
  steps = {
    "Talk to Offa in the 2nd-floor house (Bastok Markets, F-10).",
    "In Bastok Markets [S], talk to young Offa at F-10, by the 2nd-floor door.",
    "Pick a burial option (the rock option needs fewer trips) and follow it through.",
  } },

[88] = { req = "Bastok fame 1; Wings of the Goddess", start = "Titus, Alchemists' Guild 2nd floor, Bastok Mines (L-7)", reward = "Trainee Sword",
  steps = {
    "Talk to Titus upstairs in the Alchemists' Guild (Bastok Mines, L-7).",
    "In Grauberg [S] (F-13), examine the Riverbed and scoop for gold dust.",
    "Keep scooping until you have 20 grains: Ampoule of Gold Dust (key item).",
    "Return to Titus.",
  },
  notes = { "Leaving the area before 20 grains resets your count." } },

[89] = { t = "Synergistic Pursuits", req = "Earth Crystal, Flint Stone, Mythril Sand, Brass Tank", start = "Hildolf, Synergy Institute, Metalworks (F-8)", reward = "Synergy Crucible (key item)",
  steps = {
    "Talk to Hildolf (Metalworks, F-8).",
    "Bring the Earth Crystal, Flint Stone, Mythril Sand and Brass Tank.",
  },
  notes = { "Retired in retail (2012); on servers without Synergy it may not apply." } },

[90] = { req = "Synergy skill 5", start = "Selliste, Alchemists' Guild entrance, Bastok Mines (K-7)", reward = "Portafurnace",
  steps = {
    "Raise Synergy to 5.",
    "Talk to Selliste (Bastok Mines, K-7).",
    "Gather the elemental stones (from the Cloisters) and synergize Astral Matter.",
    "Trade the Astral Matter to Selliste.",
  } },

[91] = { req = "Synergy Crucible (key item)", start = "Hildolf, Metalworks (F-8)", reward = "Three Fewell of your choice",
  steps = {
    "Talk to Hildolf (Metalworks, F-8). If he asks for Slime Oil, trade him one.",
    "Pick three Fewell.",
  } },

[92] = { req = "Blue Institute Card (key item); level 5", start = "Clarion Star, Beligen Square, Port Bastok (K-7)", reward = "Bastok Trust Permit, title The Trustworthy",
  steps = {
    "Talk to Clarion Star (Port Bastok, K-7).",
    "Talk to Naji in Metalworks (J-8) and win the Trust: Naji battle.",
    "Optional: Trusts from Ayame (rank 3+), Volker (rank 6+) and Iron Eater.",
  } },
}

-- 8 = Abyssea: the main story ------------------------------------------------
-- (from the FFXIclopedia quest pages and its Abyssea Main Quests list)
local JOACHIM = "Joachim, Port Jeuno (H-8)"
local function maw_nm(zone, at, nm, title)
    local steps = {
        "With Dawn of Death active and a Traverser Stone (or banked Visitant time), check the Cavernous Maw in " .. zone .. " (" .. at .. "): the quest flags itself in the cutscene.",
        nm and ("Inside, defeat " .. nm .. ". You have to be in range for the credit, but you needn't be alive when it dies.")
            or "Inside, defeat the zone's quest boss. You have to be in range for the credit, but you needn't be alive when it dies.",
        "Leave by the Cavernous Maw (or let your time run out).",
        "Click the maw again from outside, or zone in from elsewhere, for the reward cutscene.",
    }
    return { req = "Dawn of Death, a Traverser Stone", start = "Cavernous Maw, " .. zone .. " (" .. at .. ")",
             reward = "An abyssite that depends on how many main Abyssea quests you've done" .. (title and (", title " .. title) or ""),
             steps = steps,
             notes = { "Killed the boss before flagging the quest? Flag it later and it completes after you zone.",
                       "Any three of the nine boss quests finish Dawn of Death." } }
end
G[8] = G[8] or {}
local A = G[8]
A[161] = { req = "Level 30", start = JOACHIM, reward = "Traverser Stone (key item)",
  steps = {
    "Go to a Cavernous Maw for an Abyssea expansion you own: North Gustaberg (G-6), South Gustaberg (J-10) or Xarcabard (H-8).",
    "Click the maw to enter Abyssea; you don't need Visitant status.",
    "Return to Joachim for a cutscene (you need the Traverser Stone for it).",
  },
  notes = { "Don't take Visitant status from a Conflux Surveyor: it uses up your Traverser Stone, and a new one takes 20 hours.",
            "Wait an hour before entering another maw." } }
A[162] = { req = "Level 30, a Traverser Stone", start = JOACHIM, reward = "Free Traverser Stones from Joachim every 20 hours, fast travel to the maws; opens First Contact",
  steps = {
    "Talk to Joachim for a cutscene; from now on he hands out a free Traverser Stone every 20 hours.",
    "Flag a boss quest at a Cavernous Maw for an expansion you own:",
    "Vision: A Goldstruck Gigas (La Theine D-4), To Paste a Peiste (Konschtat I-12), Megadrile Menace (Tahrongi H-12).",
    "Scars: A Fluttery Fiend (Buburimu F-7), The Beast of Bastore (Jugner J-8), A Delectable Demon (Valkurm I-9).",
    "Heroes: An Ulcerous Uragnite (North Gustaberg G-6), A Beaked Blusterer (South Gustaberg J-10), A Man-eating Mite (Xarcabard H-8).",
    "Finish any three of them to complete Dawn of Death.",
  } }
A[163] = maw_nm('La Theine Plateau', 'D-4', 'Briareus (pop it from the ??? at G-6)')
A[163].notes[#A[163].notes + 1] = "A full alliance is recommended for Briareus, but everyone in it gets the credit."
A[164] = maw_nm('Konschtat Highlands', 'I-12', 'Kukulkan', 'Kukulkan Defanger')
A[165] = maw_nm('Tahrongi Canyon', 'H-12')
A[165].notes[#A[165].notes + 1] = "Flagging this one also gives 50 cruor."
A[172] = maw_nm('Jugner Forest', 'J-8')
A[173] = maw_nm('Valkurm Dunes', 'I-9')
A[174] = maw_nm('Buburimu Peninsula', 'F-7')
A[176] = maw_nm('South Gustaberg', 'J-10')
A[177] = maw_nm('Xarcabard', 'H-8')
A[178] = maw_nm('North Gustaberg', 'G-6', 'the Uragnite Amphitrite')
A[178].req = "Level 30, Heroes of Abyssea, Dawn of Death, a Traverser Stone"
A[170] = { req = "Heart of Madness (this one flags itself)", start = JOACHIM,
  steps = {
    "Go to the stone circle in La Theine Plateau at night (18:00-5:00).",
    "Click the ??? at G-6 for a cutscene with Gilgamesh.",
    "Return to Joachim.",
  },
  notes = { "Champions of Abyssea flags itself when you finish." } }
A[171] = { start = JOACHIM,
  steps = { "Gilgamesh has told Joachim of a strange, grid-like breakdown of the land seen across the realm: look into it." } }
A[175] = { req = "Scars of Abyssea", start = JOACHIM,
  steps = { "Abyssean monsters threaten the military outposts in Vunkerl, Attohwa and Misareaux: help defend their pulse martellos." } }
A[181] = { start = "Gilgamesh, Hall of the Gods",
  steps = { "Divine will is behind the cataclysm: find out what led to the Champions of Abyssea disappearing." } }
A[182] = { start = "Esha'ntarl, Hall of the Gods", reward = "Abyssite of Discernment (key item)",
  steps = {
    "Defeat all six caturae, staying within experience range of each kill to earn its title.",
    "Killed some before you started? Talk to the bard Zuah Lepahnyu in Port Jeuno (J-8), by the Kazham airship gate, to confirm your titles.",
    "Return to Esha'ntarl.",
  },
  notes = { "You still get a title if you're KO'd when it dies." } }
A[183] = { req = "A Traverser Stone, 10000 cruor", start = "Esha'ntarl, Hall of the Gods (H-12)", reward = "Crimson Traverser Stone (key item), entry to Abyssea - Empyreal Paradox",
  steps = { "Bring Esha'ntarl a Traverser Stone and 10000 cruor for the Crimson Traverser Stone." } }
A[184] = { req = "All 9 boss quests' bosses and all 6 caturae defeated, Crimson Traverser Stone", start = "Prishe, Hall of the Gods", rep = true,
  reward = "Chance at Twilight gear (helm, mail, cloak, knife, scythe, cape, belt, torque), title Wyrm God Defier",
  steps = {
    "Talk to Prishe and enter the battlefield.",
    "Claim Shinryu and hit his weaknesses (they're set when you claim, not when you enter).",
    "Defeat him; the drops go to the treasure pool and you're returned to the lobby.",
  },
  notes = { "Visitant time doesn't run out inside.", "A red (stagger) weakness can give Atma of the Apocalypse.", "A wipe resets the weakness triggers." } }
A[185] = { start = "Prishe, Abyssea - Empyreal Paradox", reward = "Abyssite of the Cosmos (key item)",
  steps = { "With the Twilight God fallen, help Prishe restore Abyssea." } }
A[186] = { start = "Prishe, Abyssea - Empyreal Paradox",
  steps = { "You promised to visit Prishe, who watches over the world from a faraway dimension." },
  notes = { "Having this one flagged means you've finished the Abyssea story; it can't be completed." } }

return G
