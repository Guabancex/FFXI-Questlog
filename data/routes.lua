-- FFXI Questlog: how the zones connect and where you can teleport to (tools/build_routes.py).
-- names[zone] = its name; links[zone] = { [next zone] = { x, z of the zone line in this zone } };
-- tp = { { kind, zone, x, z, label } }: kind 'hp' Home Point, 'sg' Survival Guide, 'op' outpost warp (label: its region).
local R = { names = {}, links = {}, tp = {} }
R.names[1] = 'Phanauet Channel'
R.names[2] = 'Carpenters Landing'
R.names[3] = 'Manaclipper'
R.names[4] = 'Bibiki Bay'
R.names[5] = 'Uleguerand Range'
R.names[6] = 'Bearclaw Pinnacle'
R.names[7] = 'Attohwa Chasm'
R.names[8] = 'Boneyard Gully'
R.names[9] = 'PsoXja'
R.names[10] = 'The Shrouded Maw'
R.names[11] = 'Oldton Movalpolos'
R.names[12] = 'Newton Movalpolos'
R.names[13] = 'Mine Shaft 2716'
R.names[14] = 'Hall of Transference'
R.names[15] = 'Abyssea-Konschtat'
R.names[16] = 'Promyvion-Holla'
R.names[17] = 'Spire of Holla'
R.names[18] = 'Promyvion-Dem'
R.names[19] = 'Spire of Dem'
R.names[20] = 'Promyvion-Mea'
R.names[21] = 'Spire of Mea'
R.names[22] = 'Promyvion-Vahzl'
R.names[23] = 'Spire of Vahzl'
R.names[24] = 'Lufaise Meadows'
R.names[25] = 'Misareaux Coast'
R.names[26] = 'Tavnazian Safehold'
R.names[27] = 'Phomiuna Aqueducts'
R.names[28] = 'Sacrarium'
R.names[29] = 'Riverne-Site B01'
R.names[30] = 'Riverne-Site A01'
R.names[31] = 'Monarch Linn'
R.names[32] = 'Sealions Den'
R.names[33] = 'AlTaieu'
R.names[34] = 'Grand Palace of HuXzoi'
R.names[35] = 'The Garden of RuHmet'
R.names[36] = 'Empyreal Paradox'
R.names[37] = 'Temenos'
R.names[38] = 'Apollyon'
R.names[39] = 'Dynamis-Valkurm'
R.names[40] = 'Dynamis-Buburimu'
R.names[41] = 'Dynamis-Qufim'
R.names[42] = 'Dynamis-Tavnazia'
R.names[43] = 'Diorama Abdhaljs-Ghelsba'
R.names[44] = 'Abdhaljs Isle-Purgonorgo'
R.names[45] = 'Abyssea-Tahrongi'
R.names[46] = 'Open sea route to Al Zahbi'
R.names[47] = 'Open sea route to Mhaura'
R.names[48] = 'Al Zahbi'
R.names[49] = 'none'
R.names[50] = 'Aht Urhgan Whitegate'
R.names[51] = 'Wajaom Woodlands'
R.names[52] = 'Bhaflau Thickets'
R.names[53] = 'Nashmau'
R.names[54] = 'Arrapago Reef'
R.names[55] = 'Ilrusi Atoll'
R.names[56] = 'Periqia'
R.names[57] = 'Talacca Cove'
R.names[58] = 'Silver Sea route to Nashmau'
R.names[59] = 'Silver Sea route to Al Zahbi'
R.names[60] = 'The Ashu Talif'
R.names[61] = 'Mount Zhayolm'
R.names[62] = 'Halvung'
R.names[63] = 'Lebros Cavern'
R.names[64] = 'Navukgo Execution Chamber'
R.names[65] = 'Mamook'
R.names[66] = 'Mamool Ja Training Grounds'
R.names[67] = 'Jade Sepulcher'
R.names[68] = 'Aydeewa Subterrane'
R.names[69] = 'Leujaoam Sanctum'
R.names[70] = 'Chocobo Circuit'
R.names[71] = 'The Colosseum'
R.names[72] = 'Alzadaal Undersea Ruins'
R.names[73] = 'Zhayolm Remnants'
R.names[74] = 'Arrapago Remnants'
R.names[75] = 'Bhaflau Remnants'
R.names[76] = 'Silver Sea Remnants'
R.names[77] = 'Nyzul Isle'
R.names[78] = 'Hazhalm Testing Grounds'
R.names[79] = 'Caedarva Mire'
R.names[80] = 'Southern San dOria [S]'
R.names[81] = 'East Ronfaure [S]'
R.names[82] = 'Jugner Forest [S]'
R.names[83] = 'Vunkerl Inlet [S]'
R.names[84] = 'Batallia Downs [S]'
R.names[85] = 'La Vaule [S]'
R.names[86] = 'Everbloom Hollow'
R.names[87] = 'Bastok Markets [S]'
R.names[88] = 'North Gustaberg [S]'
R.names[89] = 'Grauberg [S]'
R.names[90] = 'Pashhow Marshlands [S]'
R.names[91] = 'Rolanberry Fields [S]'
R.names[92] = 'Beadeaux [S]'
R.names[93] = 'Ruhotz Silvermines'
R.names[94] = 'Windurst Waters [S]'
R.names[95] = 'West Sarutabaruta [S]'
R.names[96] = 'Fort Karugo-Narugo [S]'
R.names[97] = 'Meriphataud Mountains [S]'
R.names[98] = 'Sauromugue Champaign [S]'
R.names[99] = 'Castle Oztroja [S]'
R.names[100] = 'West Ronfaure'
R.names[101] = 'East Ronfaure'
R.names[102] = 'La Theine Plateau'
R.names[103] = 'Valkurm Dunes'
R.names[104] = 'Jugner Forest'
R.names[105] = 'Batallia Downs'
R.names[106] = 'North Gustaberg'
R.names[107] = 'South Gustaberg'
R.names[108] = 'Konschtat Highlands'
R.names[109] = 'Pashhow Marshlands'
R.names[110] = 'Rolanberry Fields'
R.names[111] = 'Beaucedine Glacier'
R.names[112] = 'Xarcabard'
R.names[113] = 'Cape Teriggan'
R.names[114] = 'Eastern Altepa Desert'
R.names[115] = 'West Sarutabaruta'
R.names[116] = 'East Sarutabaruta'
R.names[117] = 'Tahrongi Canyon'
R.names[118] = 'Buburimu Peninsula'
R.names[119] = 'Meriphataud Mountains'
R.names[120] = 'Sauromugue Champaign'
R.names[121] = 'The Sanctuary of ZiTah'
R.names[122] = 'RoMaeve'
R.names[123] = 'Yuhtunga Jungle'
R.names[124] = 'Yhoator Jungle'
R.names[125] = 'Western Altepa Desert'
R.names[126] = 'Qufim Island'
R.names[127] = 'Behemoths Dominion'
R.names[128] = 'Valley of Sorrows'
R.names[129] = 'Ghoyus Reverie'
R.names[130] = 'RuAun Gardens'
R.names[131] = 'Mordion Gaol'
R.names[132] = 'Abyssea-La Theine'
R.names[133] = 'Outer RaKaznar [U2]'
R.names[134] = 'Dynamis-Beaucedine'
R.names[135] = 'Dynamis-Xarcabard'
R.names[136] = 'Beaucedine Glacier [S]'
R.names[137] = 'Xarcabard [S]'
R.names[138] = 'Castle Zvahl Baileys [S]'
R.names[139] = 'Horlais Peak'
R.names[140] = 'Ghelsba Outpost'
R.names[141] = 'Fort Ghelsba'
R.names[142] = 'Yughott Grotto'
R.names[143] = 'Palborough Mines'
R.names[144] = 'Waughroon Shrine'
R.names[145] = 'Giddeus'
R.names[146] = 'Balgas Dais'
R.names[147] = 'Beadeaux'
R.names[148] = 'Qulun Dome'
R.names[149] = 'Davoi'
R.names[150] = 'Monastic Cavern'
R.names[151] = 'Castle Oztroja'
R.names[152] = 'Altar Room'
R.names[153] = 'The Boyahda Tree'
R.names[154] = 'Dragons Aery'
R.names[155] = 'Castle Zvahl Keep [S]'
R.names[156] = 'Throne Room [S]'
R.names[157] = 'Middle Delkfutts Tower'
R.names[158] = 'Upper Delkfutts Tower'
R.names[159] = 'Temple of Uggalepih'
R.names[160] = 'Den of Rancor'
R.names[161] = 'Castle Zvahl Baileys'
R.names[162] = 'Castle Zvahl Keep'
R.names[163] = 'Sacrificial Chamber'
R.names[164] = 'Garlaige Citadel [S]'
R.names[165] = 'Throne Room'
R.names[166] = 'Ranguemont Pass'
R.names[167] = 'Bostaunieux Oubliette'
R.names[168] = 'Chamber of Oracles'
R.names[169] = 'Toraimarai Canal'
R.names[170] = 'Full Moon Fountain'
R.names[171] = 'Crawlers Nest [S]'
R.names[172] = 'Zeruhn Mines'
R.names[173] = 'Korroloka Tunnel'
R.names[174] = 'Kuftal Tunnel'
R.names[175] = 'The Eldieme Necropolis [S]'
R.names[176] = 'Sea Serpent Grotto'
R.names[177] = 'VeLugannon Palace'
R.names[178] = 'The Shrine of RuAvitau'
R.names[179] = 'Stellar Fulcrum'
R.names[180] = 'LaLoff Amphitheater'
R.names[181] = 'The Celestial Nexus'
R.names[182] = 'Walk of Echoes'
R.names[183] = 'Maquette Abdhaljs-Legion A'
R.names[184] = 'Lower Delkfutts Tower'
R.names[185] = 'Dynamis-San dOria'
R.names[186] = 'Dynamis-Bastok'
R.names[187] = 'Dynamis-Windurst'
R.names[188] = 'Dynamis-Jeuno'
R.names[189] = 'Outer RaKaznar [U3]'
R.names[190] = 'King Ranperres Tomb'
R.names[191] = 'Dangruf Wadi'
R.names[192] = 'Inner Horutoto Ruins'
R.names[193] = 'Ordelles Caves'
R.names[194] = 'Outer Horutoto Ruins'
R.names[195] = 'The Eldieme Necropolis'
R.names[196] = 'Gusgen Mines'
R.names[197] = 'Crawlers Nest'
R.names[198] = 'Maze of Shakhrami'
R.names[199] = 'Residential Area 199'
R.names[200] = 'Garlaige Citadel'
R.names[201] = 'Cloister of Gales'
R.names[202] = 'Cloister of Storms'
R.names[203] = 'Cloister of Frost'
R.names[204] = 'FeiYin'
R.names[205] = 'Ifrits Cauldron'
R.names[206] = 'QuBia Arena'
R.names[207] = 'Cloister of Flames'
R.names[208] = 'Quicksand Caves'
R.names[209] = 'Cloister of Tremors'
R.names[210] = 'GM Home'
R.names[211] = 'Cloister of Tides'
R.names[212] = 'Gustav Tunnel'
R.names[213] = 'Labyrinth of Onzozo'
R.names[214] = 'Residential Area 214'
R.names[215] = 'Abyssea-Attohwa'
R.names[216] = 'Abyssea-Misareaux'
R.names[217] = 'Abyssea-Vunkerl'
R.names[218] = 'Abyssea-Altepa'
R.names[219] = 'Residential Area 219'
R.names[220] = 'Ship bound for Selbina'
R.names[221] = 'Ship bound for Mhaura'
R.names[222] = 'Provenance'
R.names[223] = 'San dOria-Jeuno Airship'
R.names[224] = 'Bastok-Jeuno Airship'
R.names[225] = 'Windurst-Jeuno Airship'
R.names[226] = 'Kazham-Jeuno Airship'
R.names[227] = 'Ship bound for Selbina Pirates'
R.names[228] = 'Ship bound for Mhaura Pirates'
R.names[229] = 'Throne Room [V]'
R.names[230] = 'Southern San dOria'
R.names[231] = 'Northern San dOria'
R.names[232] = 'Port San dOria'
R.names[233] = 'Chateau dOraguille'
R.names[234] = 'Bastok Mines'
R.names[235] = 'Bastok Markets'
R.names[236] = 'Port Bastok'
R.names[237] = 'Metalworks'
R.names[238] = 'Windurst Waters'
R.names[239] = 'Windurst Walls'
R.names[240] = 'Port Windurst'
R.names[241] = 'Windurst Woods'
R.names[242] = 'Heavens Tower'
R.names[243] = 'RuLude Gardens'
R.names[244] = 'Upper Jeuno'
R.names[245] = 'Lower Jeuno'
R.names[246] = 'Port Jeuno'
R.names[247] = 'Rabao'
R.names[248] = 'Selbina'
R.names[249] = 'Mhaura'
R.names[250] = 'Kazham'
R.names[251] = 'Hall of the Gods'
R.names[252] = 'Norg'
R.names[253] = 'Abyssea-Uleguerand'
R.names[254] = 'Abyssea-Grauberg'
R.names[255] = 'Abyssea-Empyreal Paradox'
R.names[256] = 'Western Adoulin'
R.names[257] = 'Eastern Adoulin'
R.names[258] = 'Rala Waterways'
R.names[259] = 'Rala Waterways U'
R.names[260] = 'Yahse Hunting Grounds'
R.names[261] = 'Ceizak Battlegrounds'
R.names[262] = 'Foret de Hennetiel'
R.names[263] = 'Yorcia Weald'
R.names[264] = 'Yorcia Weald U'
R.names[265] = 'Morimar Basalt Fields'
R.names[266] = 'Marjami Ravine'
R.names[267] = 'Kamihr Drifts'
R.names[268] = 'Sih Gates'
R.names[269] = 'Moh Gates'
R.names[270] = 'Cirdas Caverns'
R.names[271] = 'Cirdas Caverns U'
R.names[272] = 'Dho Gates'
R.names[273] = 'Woh Gates'
R.names[274] = 'Outer RaKaznar'
R.names[275] = 'Outer RaKaznar [U1]'
R.names[276] = 'RaKaznar Inner Court'
R.names[277] = 'RaKaznar Turris'
R.names[278] = 'Gwora-Corridor'
R.names[279] = 'Walk of Echoes [P2]'
R.names[280] = 'Mog Garden'
R.names[281] = 'Leafallia'
R.names[282] = 'Mount Kamihr'
R.names[283] = 'Silver Knife'
R.names[284] = 'Celennia Memorial Library'
R.names[285] = 'Feretory'
R.names[286] = '286'
R.names[287] = 'Maquette Abdhaljs-Legion B'
R.names[288] = 'Escha ZiTah'
R.names[289] = 'Escha RuAun'
R.names[290] = 'Desuetia Empyreal Paradox'
R.names[291] = 'Reisenjima'
R.names[292] = 'Reisenjima Henge'
R.names[293] = 'Reisenjima Sanctorium'
R.names[294] = 'Dynamis-San dOria [D]'
R.names[295] = 'Dynamis-Bastok [D]'
R.names[296] = 'Dynamis-Windurst [D]'
R.names[297] = 'Dynamis-Jeuno [D]'
R.names[298] = 'Walk of Echoes [P1]'
R.names[299] = 'Gwora-Throne Room'
R.links[2] = { [104] = { 0.8, -819.9 }, [231] = { -479.7, 672.9 } }
R.links[4] = { [118] = { 673.8, 911.9 } }
R.links[5] = { [6] = { 360.1, -59.9 }, [112] = { -300.0, -605.7 } }
R.links[6] = { [5] = { -677.0, -540.0 } }
R.links[7] = { [8] = { -191.0, 336.8 }, [198] = { -167.1, -261.7 } }
R.links[8] = { [7] = { -713.0, 458.0 } }
R.links[9] = { [10] = { -60.0, 1.1 }, [111] = { 404.9, -20.0 } }
R.links[10] = { [9] = { -300.0, -215.2 } }
R.links[11] = { [12] = { 73.9, 139.8 }, [106] = { -325.1, -259.7 }, [196] = { -375.3, 464.8 } }
R.links[12] = { [11] = { -264.8, 180.4 }, [13] = { 454.9, -19.4 } }
R.links[13] = { [12] = { -120.0, -620.0 } }
R.links[16] = { [17] = { 180.0, -20.0 } }
R.links[17] = { [16] = { -0.0, -296.0 } }
R.links[18] = { [19] = { 20.0, 60.0 } }
R.links[19] = { [18] = { -0.0, 296.0 } }
R.links[20] = { [21] = { 100.0, 180.0 } }
R.links[21] = { [20] = { -0.0, 296.0 } }
R.links[22] = { [23] = { -140.0, -59.9 } }
R.links[23] = { [22] = { -0.0, 296.0 } }
R.links[24] = { [25] = { -482.6, 283.5 }, [26] = { -601.0, -100.1 } }
R.links[25] = { [24] = { 572.4, 282.7 }, [26] = { 602.5, 20.0 }, [28] = { 61.1, 740.0 } }
R.links[26] = { [24] = { 9.9, 157.2 }, [25] = { -48.4, 160.0 }, [27] = { 28.0, 57.1 }, [32] = { -0.0, -42.0 } }
R.links[27] = { [26] = { 260.0, -293.4 } }
R.links[28] = { [25] = { -220.1, 85.0 } }
R.links[32] = { [26] = { 599.8, 802.1 } }
R.links[33] = { [34] = { 0.1, -439.2 }, [37] = { 0.0, 723.1 } }
R.links[34] = { [33] = { -20.0, -364.3 }, [35] = { -20.0, -271.8 } }
R.links[35] = { [34] = { -420.0, 235.7 } }
R.links[37] = { [33] = { 580.0, -4.3 } }
R.links[48] = { [50] = { 122.1, 40.0 }, [51] = { -120.2, 68.0 }, [52] = { -68.0, 120.0 } }
R.links[50] = { [48] = { -158.1, 0.0 } }
R.links[51] = { [48] = { 614.4, 356.3 }, [52] = { 381.3, 440.8 }, [62] = { -853.5, 100.0 }, [65] = { -480.5, -540.0 }, [68] = { 440.0, -100.0 } }
R.links[52] = { [48] = { 438.0, -40.0 }, [51] = { 300.0, -32.2 }, [62] = { -41.1, 300.0 }, [65] = { -31.0, -619.1 }, [67] = { -100.0, -477.0 }, [68] = { 440.0, 420.0 }, [72] = { 83.0, 620.0 } }
R.links[53] = { [79] = { 42.9, -24.0 } }
R.links[54] = { [57] = { -180.0, -563.6 }, [79] = { 500.0, -43.5 } }
R.links[57] = { [54] = { 64.0, -97.0 }, [79] = { -43.0, -260.0 } }
R.links[61] = { [62] = { 901.3, 182.2 }, [64] = { -518.0, 60.0 }, [72] = { -19.5, 321.2 } }
R.links[62] = { [51] = { 122.1, -380.0 }, [52] = { 522.0, 260.0 }, [61] = { 158.0, 140.0 }, [68] = { -20.0, -442.0 } }
R.links[64] = { [61] = { -660.6, -203.2 } }
R.links[65] = { [51] = { 400.0, -220.0 }, [52] = { -120.0, -300.0 } }
R.links[67] = { [52] = { 340.7, -160.0 } }
R.links[68] = { [51] = { 360.0, -180.0 }, [52] = { 519.9, 459.9 }, [62] = { -540.0, -160.1 } }
R.links[72] = { [52] = { 320.0, -620.0 }, [61] = { 100.0, -680.0 }, [79] = { -20.0, 840.0 } }
R.links[78] = { [79] = { 654.7, -107.7 } }
R.links[79] = { [53] = { 22.4, -700.1 }, [54] = { 140.1, -37.5 }, [57] = { -438.5, -500.0 }, [72] = { 340.0, -724.0 }, [78] = { -540.0, -556.0 } }
R.links[80] = { [81] = { 113.5, -57.4 } }
R.links[81] = { [80] = { 79.2, 280.8 }, [82] = { 706.2, -591.2 } }
R.links[82] = { [81] = { -340.9, 465.8 }, [83] = { 625.8, 298.4 }, [84] = { 591.9, 560.1 }, [85] = { -240.4, -597.5 } }
R.links[83] = { [82] = { -399.0, 740.1 }, [91] = { 243.8, -579.2 } }
R.links[84] = { [82] = { -444.0, -240.1 }, [91] = { 479.8, -358.2 }, [136] = { -501.6, 508.8 }, [175] = { 167.1, -407.1 } }
R.links[85] = { [82] = { 240.0, 20.0 } }
R.links[87] = { [88] = { -234.0, 105.0 } }
R.links[88] = { [87] = { 380.1, 144.1 }, [89] = { -262.3, 574.4 } }
R.links[89] = { [88] = { -680.0, -880.0 }, [90] = { 489.5, 927.6 } }
R.links[90] = { [89] = { -216.3, -494.1 }, [91] = { 551.3, 697.0 }, [92] = { 582.5, -377.9 } }
R.links[91] = { [83] = { -419.6, 341.2 }, [84] = { -36.6, 616.6 }, [90] = { -108.9, -918.1 }, [98] = { 367.7, 478.2 }, [171] = { -382.0, -791.7 } }
R.links[92] = { [90] = { -300.1, 96.0 } }
R.links[94] = { [95] = { -40.2, 248.8 } }
R.links[95] = { [94] = { 320.0, -48.1 }, [96] = { 118.9, 648.8 } }
R.links[96] = { [95] = { -576.2, -733.6 }, [97] = { 820.0, 121.0 } }
R.links[97] = { [96] = { 540.0, -602.0 }, [98] = { -454.6, 661.8 }, [99] = { 756.3, -40.0 } }
R.links[98] = { [91] = { -458.6, 205.4 }, [97] = { 519.9, -507.9 }, [164] = { -104.0, -427.8 } }
R.links[99] = { [97] = { -242.0, -20.0 } }
R.links[100] = { [101] = { -11.7, 140.0 }, [102] = { -560.4, -613.2 }, [140] = { -740.6, 623.3 }, [167] = { -716.8, 18.2 }, [230] = { -119.1, 280.9 }, [231] = { -157.7, 380.0 } }
R.links[101] = { [100] = { -30.1, 140.0 }, [166] = { 821.7, 666.4 }, [190] = { 200.0, -544.6 }, [230] = { 79.2, 280.8 } }
R.links[102] = { [100] = { -558.6, 688.0 }, [103] = { 160.2, -764.0 }, [104] = { 801.8, -37.6 }, [193] = { -276.6, 99.6 } }
R.links[103] = { [102] = { 758.3, 412.2 }, [108] = { 919.2, -440.0 }, [212] = { -767.9, 18.4 }, [248] = { 60.0, -154.5 } }
R.links[104] = { [2] = { 344.4, 8.2 }, [102] = { -600.0, -440.1 }, [105] = { 591.9, 560.1 }, [149] = { -240.4, -597.5 }, [190] = { -340.9, 465.8 } }
R.links[105] = { [104] = { -444.0, -240.1 }, [110] = { 480.0, -363.9 }, [111] = { -501.6, 508.8 }, [195] = { -467.3, 332.7 }, [244] = { 491.9, -160.0 } }
R.links[106] = { [11] = { 581.0, 695.9 }, [107] = { 0.7, -79.1 }, [108] = { -518.8, 592.1 }, [143] = { 497.9, 1174.9 }, [191] = { -697.0, 311.8 }, [236] = { 660.0, 302.7 } }
R.links[107] = { [106] = { 0.9, 80.2 }, [191] = { -605.3, -520.2 }, [234] = { 580.0, -301.8 }, [235] = { 260.0, -180.0 } }
R.links[108] = { [103] = { -160.5, 887.7 }, [106] = { 101.2, -612.0 }, [109] = { 520.1, 752.9 }, [196] = { 707.6, 217.5 } }
R.links[109] = { [108] = { -543.9, -652.0 }, [110] = { 551.3, 697.0 }, [147] = { 582.5, -377.9 } }
R.links[110] = { [105] = { -38.7, 640.1 }, [109] = { -124.2, -920.1 }, [120] = { 376.9, 480.0 }, [197] = { -382.0, -791.7 }, [245] = { 340.1, 613.4 } }
R.links[111] = { [9] = { 238.8, -20.0 }, [105] = { 18.1, -658.1 }, [112] = { -252.0, 260.7 }, [166] = { -542.0, -378.7 }, [204] = { 280.0, 571.9 } }
R.links[112] = { [5] = { -131.8, 139.0 }, [111] = { 600.0, -260.1 }, [161] = { -437.0, 20.0 } }
R.links[113] = { [128] = { 239.9, -180.1 }, [174] = { -218.7, -328.0 }, [201] = { -290.9, 540.1 }, [212] = { 260.0, 440.0 } }
R.links[114] = { [125] = { 260.3, 324.0 }, [173] = { 500.0, -80.0 }, [208] = { 420.1, 194.9 }, [209] = { 85.1, -99.9 } }
R.links[115] = { [116] = { 504.4, 133.9 }, [145] = { -374.5, 61.1 }, [146] = { -228.6, -186.1 }, [192] = { 221.2, 39.3 }, [194] = { -279.2, 660.0 }, [238] = { 320.0, -48.1 }, [240] = { 169.2, -320.0 } }
R.links[116] = { [115] = { -343.9, 106.5 }, [117] = { 306.1, 664.7 }, [192] = { 399.3, 100.0 }, [194] = { -60.0, 759.4 }, [241] = { -128.1, -520.0 } }
R.links[117] = { [116] = { -64.8, -740.9 }, [118] = { 446.6, -40.3 }, [119] = { -238.2, 704.0 }, [198] = { 485.9, 514.7 } }
R.links[118] = { [4] = { -280.0, -324.0 }, [117] = { -625.8, 159.8 }, [198] = { -360.1, 315.5 }, [213] = { 444.1, 201.0 }, [249] = { 187.8, -227.5 } }
R.links[119] = { [117] = { -119.9, -620.1 }, [120] = { -454.6, 661.8 }, [121] = { 774.9, 621.6 }, [151] = { 756.3, -40.0 } }
R.links[120] = { [110] = { -480.0, 200.8 }, [119] = { 519.9, -507.9 }, [200] = { -104.0, -427.8 }, [246] = { -580.0, 399.8 } }
R.links[121] = { [119] = { -460.0, -483.8 }, [122] = { -240.0, 647.4 }, [153] = { 543.2, -581.2 }, [154] = { 177.2, -181.8 } }
R.links[122] = { [121] = { -0.0, -150.1 }, [251] = { 0.0, 126.6 } }
R.links[123] = { [124] = { 120.0, 100.0 }, [176] = { -640.0, -419.9 }, [205] = { 420.0, 480.0 }, [250] = { -241.9, 531.9 } }
R.links[124] = { [123] = { -360.0, 140.0 }, [159] = { 300.0, -627.2 }, [160] = { 380.0, 80.0 }, [205] = { -102.1, 258.7 } }
R.links[125] = { [114] = { 378.7, -12.1 }, [173] = { 680.3, -100.2 }, [174] = { -19.8, 443.8 }, [208] = { 179.9, -285.1 }, [247] = { 420.3, 363.9 } }
R.links[126] = { [127] = { -642.0, 460.0 }, [184] = { -289.9, 320.0 }, [246] = { 140.0, -480.0 } }
R.links[127] = { [126] = { 361.0, -60.0 } }
R.links[128] = { [113] = { -239.1, -20.0 } }
R.links[130] = { [177] = { -91.5, -433.7 }, [178] = { 0.0, -106.6 }, [180] = { 541.9, 176.1 }, [251] = { -1.1, -641.5 } }
R.links[136] = { [84] = { 18.1, -658.1 }, [137] = { -180.0, 283.0 } }
R.links[137] = { [136] = { 683.3, -300.2 }, [138] = { -437.0, 20.0 } }
R.links[138] = { [137] = { 415.0, -20.0 }, [155] = { -185.0, 20.0 } }
R.links[139] = { [142] = { -540.0, -210.0 } }
R.links[140] = { [100] = { 99.7, -45.7 }, [141] = { 130.0, 181.6 }, [142] = { -7.9, -60.9 } }
R.links[141] = { [140] = { -172.1, 16.9 }, [142] = { 225.7, 18.6 } }
R.links[142] = { [139] = { 443.2, 169.7 }, [140] = { -251.3, -69.7 }, [141] = { 273.0, 150.4 } }
R.links[143] = { [106] = { 1.5, 59.9 }, [144] = { 117.4, -140.1 } }
R.links[144] = { [143] = { -364.0, -260.0 } }
R.links[145] = { [115] = { -100.9, 411.4 }, [146] = { -140.0, -300.3 } }
R.links[146] = { [115] = { -260.3, -363.6 }, [145] = { 321.7, 380.0 } }
R.links[147] = { [109] = { -300.1, 96.0 }, [148] = { 384.5, 19.6 } }
R.links[148] = { [147] = { 340.8, 20.1 } }
R.links[149] = { [104] = { 219.5, 0.0 }, [150] = { 279.0, -18.1 } }
R.links[150] = { [149] = { 263.0, 19.9 } }
R.links[151] = { [119] = { -242.0, -20.0 }, [152] = { -165.5, -140.0 } }
R.links[152] = { [151] = { -244.9, -100.0 } }
R.links[153] = { [121] = { 394.0, -60.6 }, [154] = { -140.9, 207.0 }, [202] = { 96.5, -221.5 } }
R.links[154] = { [121] = { 121.5, 140.0 }, [153] = { -60.0, -42.5 } }
R.links[155] = { [138] = { 64.9, -20.0 }, [156] = { -559.6, 60.0 } }
R.links[156] = { [155] = { 117.1, 0.0 } }
R.links[159] = { [124] = { 180.0, 44.6 }, [160] = { 430.5, 213.3 }, [163] = { -230.4, 67.2 } }
R.links[160] = { [124] = { 260.0, 323.0 }, [159] = { 460.0, 240.0 }, [163] = { -104.9, 56.0 }, [211] = { 200.0, -60.1 } }
R.links[161] = { [112] = { 415.0, -20.0 }, [162] = { -185.0, 20.0 } }
R.links[162] = { [161] = { 64.9, -20.0 }, [165] = { -559.6, 60.0 } }
R.links[163] = { [159] = { -367.7, -343.2 }, [160] = { 320.0, 340.0 } }
R.links[164] = { [98] = { -300.0, 160.0 } }
R.links[165] = { [162] = { 117.1, 0.0 } }
R.links[166] = { [101] = { -140.0, -324.6 }, [111] = { 305.9, 258.0 } }
R.links[167] = { [100] = { -380.0, -239.6 }, [233] = { 100.0, 75.0 } }
R.links[168] = { [208] = { -179.5, -42.0 } }
R.links[169] = { [170] = { -260.0, 85.8 }, [192] = { -340.0, 275.0 }, [239] = { 140.0, 133.0 } }
R.links[170] = { [169] = { -260.1, -329.1 } }
R.links[171] = { [91] = { 380.1, 6.9 } }
R.links[172] = { [173] = { -273.9, -20.3 }, [234] = { 23.0, 3.9 } }
R.links[173] = { [114] = { -500.0, 4.0 }, [125] = { -523.0, 340.0 }, [172] = { 460.0, 157.0 } }
R.links[174] = { [113] = { 20.4, 280.0 }, [125] = { -20.0, -245.6 } }
R.links[175] = { [84] = { 420.0, -122.0 } }
R.links[176] = { [123] = { 232.1, 337.8 }, [252] = { -60.6, 415.6 } }
R.links[177] = { [130] = { -100.0, -396.0 } }
R.links[178] = { [130] = { -40.0, -235.6 }, [181] = { -0.0, 60.0 } }
R.links[180] = { [130] = { 526.0, 561.9 } }
R.links[181] = { [178] = { -701.0, -32.3 } }
R.links[184] = { [126] = { 460.0, -106.5 } }
R.links[190] = { [101] = { -130.0, 260.8 }, [104] = { 250.6, 340.2 } }
R.links[191] = { [106] = { 7.1, 619.3 }, [107] = { 0.2, -0.0 } }
R.links[192] = { [115] = { -193.0, 60.0 }, [116] = { 429.0, 180.0 }, [169] = { -260.0, 250.1 } }
R.links[193] = { [102] = { -74.1, 660.0 } }
R.links[194] = { [115] = { -309.0, 860.0 }, [116] = { 420.0, 709.0 } }
R.links[195] = { [105] = { -555.0, 100.0 } }
R.links[196] = { [11] = { 100.2, -240.5 }, [108] = { 44.0, -340.1 } }
R.links[197] = { [110] = { 380.1, 6.9 } }
R.links[198] = { [7] = { -140.3, 164.2 }, [117] = { -370.0, -180.8 }, [118] = { 480.0, -260.0 } }
R.links[200] = { [120] = { -380.0, 401.0 } }
R.links[201] = { [113] = { -403.0, -420.0 } }
R.links[202] = { [153] = { 514.1, 539.3 } }
R.links[203] = { [204] = { 500.0, 520.0 } }
R.links[204] = { [111] = { -180.0, -200.0 }, [203] = { 100.0, 280.0 }, [206] = { 245.0, 60.0 } }
R.links[205] = { [123] = { -419.3, 228.0 }, [124] = { 300.0, -85.0 }, [207] = { -58.7, 110.3 } }
R.links[206] = { [204] = { -244.0, 20.0 } }
R.links[207] = { [205] = { -698.6, -650.2 } }
R.links[208] = { [114] = { 940.0, -361.0 }, [125] = { 180.0, -145.1 }, [168] = { -980.4, -278.3 }, [209] = { 578.6, -492.0 } }
R.links[209] = { [114] = { -640.0, -500.0 }, [208] = { -580.9, -568.0 } }
R.links[211] = { [160] = { 561.3, 500.0 } }
R.links[212] = { [103] = { 276.7, 100.0 }, [113] = { -260.0, -280.0 } }
R.links[213] = { [118] = { -58.9, -290.2 } }
R.links[230] = { [100] = { -113.4, -57.4 }, [101] = { 113.5, -57.4 }, [231] = { 0.0, 58.0 } }
R.links[231] = { [2] = { -123.6, 192.8 }, [100] = { -252.2, 43.9 }, [230] = { -0.1, -36.1 }, [232] = { -123.5, 270.5 } }
R.links[232] = { [231] = { -111.8, -136.5 } }
R.links[233] = { [167] = { 12.5, 24.0 } }
R.links[234] = { [107] = { -16.0, -136.0 }, [172] = { -196.0, -21.9 }, [235] = { -104.1, 84.6 } }
R.links[235] = { [107] = { -365.7, -185.6 }, [234] = { -202.2, -197.8 }, [236] = { -234.0, 92.3 }, [237] = { -212.0, -0.0 } }
R.links[236] = { [106] = { 150.3, 6.3 }, [235] = { -193.5, -84.0 } }
R.links[237] = { [235] = { -6.2, -0.0 } }
R.links[238] = { [115] = { -40.2, 248.8 }, [239] = { 160.1, 60.4 }, [240] = { -59.6, -209.0 } }
R.links[239] = { [169] = { -18.3, 253.7 }, [238] = { -205.0, 139.6 }, [241] = { 100.5, -166.5 } }
R.links[240] = { [115] = { -249.1, 200.0 }, [238] = { -114.6, 215.8 }, [241] = { 230.6, 179.9 } }
R.links[241] = { [116] = { 126.7, -40.0 }, [239] = { -60.7, 92.0 }, [240] = { -94.2, -72.7 } }
R.links[243] = { [244] = { -0.0, -109.7 } }
R.links[244] = { [105] = { -106.1, 190.0 }, [243] = { 46.0, -30.9 }, [245] = { 4.8, -54.9 } }
R.links[245] = { [110] = { -123.1, -200.7 }, [244] = { 0.2, 59.6 }, [246] = { 29.7, 41.4 } }
R.links[246] = { [120] = { 55.0, -0.0 }, [126] = { -157.1, 100.1 }, [245] = { -151.0, -22.8 } }
R.links[247] = { [125] = { -20.6, -128.0 } }
R.links[248] = { [103] = { 16.9, 104.3 } }
R.links[249] = { [118] = { -0.2, 121.0 } }
R.links[250] = { [123] = { -50.0, -111.5 } }
R.links[251] = { [122] = { 0.0, -180.1 }, [130] = { 0.0, 365.1 } }
R.links[252] = { [176] = { -19.2, -67.5 } }
R.links[256] = { [257] = { 180.0, -20.0 }, [258] = { 74.0, -148.0 }, [261] = { -160.3, -26.0 } }
R.links[257] = { [256] = { -165.0, -20.0 }, [258] = { -122.0, 28.0 } }
R.links[258] = { [256] = { -265.0, -380.0 }, [257] = { 145.0, 140.0 } }
R.links[260] = { [261] = { -379.6, -446.0 }, [269] = { -540.0, -117.5 } }
R.links[261] = { [256] = { 460.8, 176.9 }, [260] = { -299.7, 405.0 }, [268] = { -540.0, -315.0 } }
R.links[262] = { [268] = { 380.4, 462.2 }, [272] = { -360.1, 305.1 } }
R.links[263] = { [270] = { 235.0, 59.5 }, [273] = { -405.0, 259.5 } }
R.links[265] = { [269] = { 580.0, -482.0 }, [273] = { -540.0, -405.0 } }
R.links[266] = { [272] = { 445.0, 299.0 }, [273] = { -501.0, 325.0 } }
R.links[267] = { [273] = { 500.5, -483.0 } }
R.links[268] = { [261] = { -36.5, -19.7 }, [262] = { -164.1, -420.8 }, [270] = { -501.3, 4.2 } }
R.links[269] = { [260] = { 300.0, -364.0 }, [265] = { 99.5, 116.0 }, [270] = { -126.3, -381.6 } }
R.links[270] = { [263] = { 207.6, 217.9 }, [268] = { 419.0, -286.0 }, [269] = { 527.5, 418.6 }, [272] = { -180.2, -321.0 }, [273] = { -219.8, 524.0 } }
R.links[272] = { [262] = { 60.0, 85.0 }, [266] = { -325.0, 340.0 }, [270] = { 60.0, 525.0 } }
R.links[273] = { [263] = { 484.0, 140.0 }, [265] = { 500.0, 404.0 }, [266] = { 180.0, 37.0 }, [267] = { 340.0, 524.0 }, [270] = { 404.0, 100.0 } }
R.links[281] = { [267] = { 19.4, -43.0 } }
R.tp[#R.tp + 1] = { 'sg', 2, 225.0, -528.0, 'Survival Guide' }
R.tp[#R.tp + 1] = { 'sg', 4, 495.0, 728.0, 'Survival Guide' }
R.tp[#R.tp + 1] = { 'hp', 5, 65.0, 181.0, 'Home Point #1' }
R.tp[#R.tp + 1] = { 'hp', 5, 379.0, -62.6, 'Home Point #2' }
R.tp[#R.tp + 1] = { 'hp', 5, 424.0, 220.0, 'Home Point #3' }
R.tp[#R.tp + 1] = { 'hp', 5, 64.0, 460.0, 'Home Point #4' }
R.tp[#R.tp + 1] = { 'hp', 5, -219.0, -62.0, 'Home Point #5' }
R.tp[#R.tp + 1] = { 'hp', 7, -200.0, 342.0, 'Home Point #1' }
R.tp[#R.tp + 1] = { 'hp', 9, -58.0, 14.0, 'Home Point #1' }
R.tp[#R.tp + 1] = { 'sg', 11, -262.0, -54.0, 'Survival Guide' }
R.tp[#R.tp + 1] = { 'hp', 12, 440.0, -18.0, 'Home Point #1' }
R.tp[#R.tp + 1] = { 'op', 24, -535.9, -53.6, 'Tavnazian Archipelago' }
R.tp[#R.tp + 1] = { 'sg', 24, -554.0, -56.0, 'Survival Guide' }
R.tp[#R.tp + 1] = { 'hp', 25, -65.0, 563.0, 'Home Point #1' }
R.tp[#R.tp + 1] = { 'sg', 25, -61.0, 261.0, 'Survival Guide' }
R.tp[#R.tp + 1] = { 'hp', 26, -1.2, 107.4, 'Home Point #1' }
R.tp[#R.tp + 1] = { 'hp', 26, 14.0, -5.0, 'Home Point #2' }
R.tp[#R.tp + 1] = { 'hp', 26, 73.6, 38.9, 'Home Point #3' }
R.tp[#R.tp + 1] = { 'sg', 26, -5.0, 102.0, 'Survival Guide' }
R.tp[#R.tp + 1] = { 'sg', 27, 252.0, -266.0, 'Survival Guide' }
R.tp[#R.tp + 1] = { 'sg', 28, -220.0, 57.0, 'Survival Guide' }
R.tp[#R.tp + 1] = { 'hp', 29, -520.0, 505.0, 'Home Point #1' }
R.tp[#R.tp + 1] = { 'hp', 30, 187.0, 361.0, 'Home Point #1' }
R.tp[#R.tp + 1] = { 'hp', 33, 7.0, 709.0, 'Home Point #1' }
R.tp[#R.tp + 1] = { 'hp', 33, -532.0, 447.0, 'Home Point #2' }
R.tp[#R.tp + 1] = { 'hp', 33, 569.0, 410.0, 'Home Point #3' }
R.tp[#R.tp + 1] = { 'hp', 34, -12.0, -288.0, 'Home Point #1' }
R.tp[#R.tp + 1] = { 'hp', 35, -426.0, 368.0, 'Home Point #1' }
R.tp[#R.tp + 1] = { 'hp', 50, -21.1, -20.9, 'Home Point #1' }
R.tp[#R.tp + 1] = { 'hp', 50, 130.0, -16.0, 'Home Point #2' }
R.tp[#R.tp + 1] = { 'hp', 50, -108.0, 108.0, 'Home Point #3' }
R.tp[#R.tp + 1] = { 'hp', 50, -99.0, -68.0, 'Home Point #4' }
R.tp[#R.tp + 1] = { 'sg', 50, 134.0, 17.0, 'Survival Guide' }
R.tp[#R.tp + 1] = { 'sg', 51, -839.0, 98.0, 'Survival Guide' }
R.tp[#R.tp + 1] = { 'hp', 52, -98.0, -493.0, 'Home Point #1' }
R.tp[#R.tp + 1] = { 'hp', 52, -98.0, -493.0, 'Home Point #1' }
R.tp[#R.tp + 1] = { 'hp', 53, -19.9, -25.4, 'Home Point #1' }
R.tp[#R.tp + 1] = { 'sg', 53, -20.0, -33.0, 'Survival Guide' }
R.tp[#R.tp + 1] = { 'sg', 54, 475.0, -20.0, 'Survival Guide' }
R.tp[#R.tp + 1] = { 'hp', 61, -533.0, 56.5, 'Home Point #1' }
R.tp[#R.tp + 1] = { 'sg', 62, 504.0, 241.0, 'Survival Guide' }
R.tp[#R.tp + 1] = { 'sg', 65, 218.0, -104.0, 'Survival Guide' }
R.tp[#R.tp + 1] = { 'sg', 68, 4.0, -91.0, 'Survival Guide' }
R.tp[#R.tp + 1] = { 'hp', 79, -449.0, -497.0, 'Home Point #1' }
R.tp[#R.tp + 1] = { 'sg', 79, -659.0, 340.0, 'Survival Guide' }
R.tp[#R.tp + 1] = { 'hp', 80, -85.5, -66.5, 'Home Point #1' }
R.tp[#R.tp + 1] = { 'sg', 80, 82.0, -68.0, 'Survival Guide' }
R.tp[#R.tp + 1] = { 'sg', 81, 661.0, -599.0, 'Survival Guide' }
R.tp[#R.tp + 1] = { 'sg', 82, -196.0, -498.0, 'Survival Guide' }
R.tp[#R.tp + 1] = { 'sg', 83, -521.0, 207.0, 'Survival Guide' }
R.tp[#R.tp + 1] = { 'sg', 84, -404.0, -163.0, 'Survival Guide' }
R.tp[#R.tp + 1] = { 'hp', 87, -293.0, -102.6, 'Home Point #1' }
R.tp[#R.tp + 1] = { 'sg', 87, -247.0, 95.0, 'Survival Guide' }
R.tp[#R.tp + 1] = { 'sg', 88, -289.0, 533.0, 'Survival Guide' }
R.tp[#R.tp + 1] = { 'sg', 89, 794.0, 772.0, 'Survival Guide' }
R.tp[#R.tp + 1] = { 'sg', 90, 549.0, -341.0, 'Survival Guide' }
R.tp[#R.tp + 1] = { 'sg', 91, -37.0, -866.0, 'Survival Guide' }
R.tp[#R.tp + 1] = { 'hp', 94, -32.0, 131.7, 'Home Point #1' }
R.tp[#R.tp + 1] = { 'sg', 94, -58.0, 216.0, 'Survival Guide' }
R.tp[#R.tp + 1] = { 'sg', 95, 83.0, 567.0, 'Survival Guide' }
R.tp[#R.tp + 1] = { 'sg', 96, 126.0, 606.0, 'Survival Guide' }
R.tp[#R.tp + 1] = { 'sg', 97, 734.0, -10.0, 'Survival Guide' }
R.tp[#R.tp + 1] = { 'sg', 98, 476.0, -437.0, 'Survival Guide' }
R.tp[#R.tp + 1] = { 'op', 100, -437.7, -219.2, 'Ronfaure' }
R.tp[#R.tp + 1] = { 'sg', 100, -452.6, -218.0, 'Survival Guide' }
R.tp[#R.tp + 1] = { 'sg', 102, 775.0, -18.0, 'Survival Guide' }
R.tp[#R.tp + 1] = { 'op', 103, 148.2, 93.5, 'Zulkheim' }
R.tp[#R.tp + 1] = { 'sg', 103, 137.0, 98.0, 'Survival Guide' }
R.tp[#R.tp + 1] = { 'op', 104, 62.0, -2.0, 'Norvallen' }
R.tp[#R.tp + 1] = { 'sg', 104, 63.0, -14.0, 'Survival Guide' }
R.tp[#R.tp + 1] = { 'sg', 105, -67.0, 449.0, 'Survival Guide' }
R.tp[#R.tp + 1] = { 'op', 106, -580.2, 62.7, 'Gustaberg' }
R.tp[#R.tp + 1] = { 'sg', 106, -582.7, 52.3, 'Survival Guide' }
R.tp[#R.tp + 1] = { 'sg', 108, -222.0, 827.0, 'Survival Guide' }
R.tp[#R.tp + 1] = { 'op', 109, 465.8, 423.2, 'Derfland' }
R.tp[#R.tp + 1] = { 'sg', 109, 467.0, 410.0, 'Survival Guide' }
R.tp[#R.tp + 1] = { 'sg', 110, -228.0, 386.0, 'Survival Guide' }
R.tp[#R.tp + 1] = { 'op', 111, -18.7, -109.2, 'Fauregandi' }
R.tp[#R.tp + 1] = { 'sg', 111, -28.0, -125.0, 'Survival Guide' }
R.tp[#R.tp + 1] = { 'op', 112, 211.2, -207.3, 'Valdeaunia' }
R.tp[#R.tp + 1] = { 'sg', 112, 204.0, -203.0, 'Survival Guide' }
R.tp[#R.tp + 1] = { 'hp', 113, -303.0, 526.0, 'Home Point #1' }
R.tp[#R.tp + 1] = { 'op', 113, -176.4, -63.6, 'Vollbow' }
R.tp[#R.tp + 1] = { 'sg', 113, -188.0, -67.0, 'Survival Guide' }
R.tp[#R.tp + 1] = { 'op', 114, -250.0, -253.0, 'Kuzotz' }
R.tp[#R.tp + 1] = { 'sg', 114, -260.0, -265.0, 'Survival Guide' }
R.tp[#R.tp + 1] = { 'op', 115, -17.9, 318.2, 'Sarutabaruta' }
R.tp[#R.tp + 1] = { 'sg', 115, -13.3, 315.7, 'Survival Guide' }
R.tp[#R.tp + 1] = { 'sg', 117, -160.0, 648.0, 'Survival Guide' }
R.tp[#R.tp + 1] = { 'op', 118, -480.2, 58.1, 'Kolshushu' }
R.tp[#R.tp + 1] = { 'sg', 118, -485.7, 46.2, 'Survival Guide' }
R.tp[#R.tp + 1] = { 'op', 119, -297.0, 418.0, 'Aragoneu' }
R.tp[#R.tp + 1] = { 'sg', 119, -297.0, 423.0, 'Survival Guide' }
R.tp[#R.tp + 1] = { 'sg', 120, 344.0, -256.0, 'Survival Guide' }
R.tp[#R.tp + 1] = { 'op', 121, -37.7, -141.2, 'Li\'Telor' }
R.tp[#R.tp + 1] = { 'sg', 121, -45.0, -151.0, 'Survival Guide' }
R.tp[#R.tp + 1] = { 'sg', 122, 15.0, 53.0, 'Survival Guide' }
R.tp[#R.tp + 1] = { 'op', 123, -240.9, -388.4, 'Elshimo Lowlands' }
R.tp[#R.tp + 1] = { 'sg', 123, -239.5, -404.0, 'Survival Guide' }
R.tp[#R.tp + 1] = { 'op', 124, 207.8, -86.6, 'Elshimo Uplands' }
R.tp[#R.tp + 1] = { 'sg', 124, 197.0, -81.0, 'Survival Guide' }
R.tp[#R.tp + 1] = { 'sg', 125, 420.0, 11.0, 'Survival Guide' }
R.tp[#R.tp + 1] = { 'hp', 126, -212.0, 93.0, 'Home Point #1' }
R.tp[#R.tp + 1] = { 'op', 126, -243.0, 306.7, 'Qufim Island' }
R.tp[#R.tp + 1] = { 'sg', 126, -252.0, 297.0, 'Survival Guide' }
R.tp[#R.tp + 1] = { 'sg', 127, 336.0, -74.0, 'Survival Guide' }
R.tp[#R.tp + 1] = { 'sg', 128, -167.0, 24.0, 'Survival Guide' }
R.tp[#R.tp + 1] = { 'hp', 130, 5.0, 526.0, 'Home Point #1' }
R.tp[#R.tp + 1] = { 'hp', 130, -312.0, -422.0, 'Home Point #2' }
R.tp[#R.tp + 1] = { 'hp', 130, -499.0, 167.0, 'Home Point #3' }
R.tp[#R.tp + 1] = { 'hp', 130, 500.0, 158.0, 'Home Point #4' }
R.tp[#R.tp + 1] = { 'hp', 130, 305.0, -427.0, 'Home Point #5' }
R.tp[#R.tp + 1] = { 'sg', 130, 13.0, -593.0, 'Survival Guide' }
R.tp[#R.tp + 1] = { 'sg', 136, -144.0, 234.0, 'Survival Guide' }
R.tp[#R.tp + 1] = { 'hp', 137, 223.3, -254.2, 'Home Point #1' }
R.tp[#R.tp + 1] = { 'sg', 138, 372.0, -25.0, 'Survival Guide' }
R.tp[#R.tp + 1] = { 'sg', 141, -143.0, 7.0, 'Survival Guide' }
R.tp[#R.tp + 1] = { 'hp', 142, 434.0, 171.0, 'Home Point #1' }
R.tp[#R.tp + 1] = { 'hp', 143, 109.0, -147.0, 'Home Point #1' }
R.tp[#R.tp + 1] = { 'hp', 145, -132.0, -303.0, 'Home Point #1' }
R.tp[#R.tp + 1] = { 'sg', 147, -264.0, 107.0, 'Survival Guide' }
R.tp[#R.tp + 1] = { 'sg', 149, 223.0, -10.0, 'Survival Guide' }
R.tp[#R.tp + 1] = { 'sg', 151, -221.0, -13.0, 'Survival Guide' }
R.tp[#R.tp + 1] = { 'hp', 153, 88.0, -217.0, 'Home Point #1' }
R.tp[#R.tp + 1] = { 'sg', 154, -61.0, -33.0, 'Survival Guide' }
R.tp[#R.tp + 1] = { 'hp', 155, -554.0, 66.0, 'Home Point #1' }
R.tp[#R.tp + 1] = { 'hp', 158, -365.0, -36.0, 'Home Point #1' }
R.tp[#R.tp + 1] = { 'sg', 159, 60.0, 57.0, 'Survival Guide' }
R.tp[#R.tp + 1] = { 'hp', 160, -80.0, 62.0, 'Home Point #1' }
R.tp[#R.tp + 1] = { 'hp', 160, 183.0, -61.0, 'Home Point #2' }
R.tp[#R.tp + 1] = { 'sg', 161, 372.0, -25.0, 'Survival Guide' }
R.tp[#R.tp + 1] = { 'hp', 162, -554.0, 66.0, 'Home Point #1' }
R.tp[#R.tp + 1] = { 'sg', 164, -303.0, 127.5, 'Survival Guide' }
R.tp[#R.tp + 1] = { 'sg', 166, -146.0, -298.0, 'Survival Guide' }
R.tp[#R.tp + 1] = { 'sg', 167, -11.7, 25.4, 'Survival Guide' }
R.tp[#R.tp + 1] = { 'hp', 169, -257.5, 82.0, 'Home Point #1' }
R.tp[#R.tp + 1] = { 'sg', 169, -308.2, 262.0, 'Survival Guide' }
R.tp[#R.tp + 1] = { 'sg', 171, 364.0, -23.0, 'Survival Guide' }
R.tp[#R.tp + 1] = { 'sg', 172, -10.0, 7.0, 'Survival Guide' }
R.tp[#R.tp + 1] = { 'sg', 173, -463.0, -23.0, 'Survival Guide' }
R.tp[#R.tp + 1] = { 'sg', 174, -16.0, -237.0, 'Survival Guide' }
R.tp[#R.tp + 1] = { 'sg', 175, 418.0, -99.5, 'Survival Guide' }
R.tp[#R.tp + 1] = { 'sg', 176, 223.0, 335.0, 'Survival Guide' }
R.tp[#R.tp + 1] = { 'hp', 178, -13.0, 61.0, 'Home Point #1' }
R.tp[#R.tp + 1] = { 'sg', 184, 464.0, -51.0, 'Survival Guide' }
R.tp[#R.tp + 1] = { 'sg', 190, -119.0, 248.5, 'Survival Guide' }
R.tp[#R.tp + 1] = { 'sg', 191, -24.0, 1.0, 'Survival Guide' }
R.tp[#R.tp + 1] = { 'sg', 192, 453.0, 182.3, 'Survival Guide' }
R.tp[#R.tp + 1] = { 'sg', 193, -104.0, 633.0, 'Survival Guide' }
R.tp[#R.tp + 1] = { 'sg', 195, 418.0, -99.5, 'Survival Guide' }
R.tp[#R.tp + 1] = { 'sg', 196, 60.0, -266.0, 'Survival Guide' }
R.tp[#R.tp + 1] = { 'sg', 197, 364.0, -23.0, 'Survival Guide' }
R.tp[#R.tp + 1] = { 'sg', 198, -338.0, -179.0, 'Survival Guide' }
R.tp[#R.tp + 1] = { 'sg', 200, -383.0, 363.5, 'Survival Guide' }
R.tp[#R.tp + 1] = { 'hp', 204, 243.0, 62.0, 'Home Point #1' }
R.tp[#R.tp + 1] = { 'hp', 204, 102.3, 270.4, 'Home Point #2' }
R.tp[#R.tp + 1] = { 'hp', 205, -63.0, 81.0, 'Home Point #1' }
R.tp[#R.tp + 1] = { 'sg', 205, 89.0, -297.0, 'Survival Guide' }
R.tp[#R.tp + 1] = { 'hp', 208, -984.0, -289.0, 'Home Point #1' }
R.tp[#R.tp + 1] = { 'hp', 208, 573.0, -499.0, 'Home Point #2' }
R.tp[#R.tp + 1] = { 'sg', 212, 296.0, 64.0, 'Survival Guide' }
R.tp[#R.tp + 1] = { 'sg', 213, -63.0, -280.0, 'Survival Guide' }
R.tp[#R.tp + 1] = { 'hp', 230, -85.5, -66.5, 'Home Point #1' }
R.tp[#R.tp + 1] = { 'hp', 230, 45.0, -35.0, 'Home Point #2' }
R.tp[#R.tp + 1] = { 'hp', 230, 140.0, 123.0, 'Home Point #3' }
R.tp[#R.tp + 1] = { 'hp', 230, -165.0, 11.0, 'Home Point #4' }
R.tp[#R.tp + 1] = { 'hp', 231, -178.1, 71.3, 'Home Point #1' }
R.tp[#R.tp + 1] = { 'hp', 231, 10.0, 95.0, 'Home Point #2' }
R.tp[#R.tp + 1] = { 'hp', 231, 70.0, 10.0, 'Home Point #3' }
R.tp[#R.tp + 1] = { 'hp', 231, -133.0, 195.0, 'Home Point #4' }
R.tp[#R.tp + 1] = { 'sg', 231, -174.0, 80.0, 'Survival Guide' }
R.tp[#R.tp + 1] = { 'hp', 232, -38.0, -63.0, 'Home Point #1' }
R.tp[#R.tp + 1] = { 'hp', 232, 48.0, -105.0, 'Home Point #2' }
R.tp[#R.tp + 1] = { 'hp', 232, -6.0, -150.0, 'Home Point #3' }
R.tp[#R.tp + 1] = { 'hp', 234, 39.2, -42.6, 'Home Point #1' }
R.tp[#R.tp + 1] = { 'hp', 234, 118.0, -58.0, 'Home Point #2' }
R.tp[#R.tp + 1] = { 'hp', 234, 87.0, 1.0, 'Home Point #3' }
R.tp[#R.tp + 1] = { 'sg', 234, 20.0, -115.0, 'Survival Guide' }
R.tp[#R.tp + 1] = { 'hp', 235, -344.0, -155.0, 'Home Point #1' }
R.tp[#R.tp + 1] = { 'hp', 235, -328.0, -33.0, 'Home Point #2' }
R.tp[#R.tp + 1] = { 'hp', 235, -189.0, 26.0, 'Home Point #3' }
R.tp[#R.tp + 1] = { 'hp', 235, -191.0, -69.0, 'Home Point #4' }
R.tp[#R.tp + 1] = { 'hp', 236, 126.0, 8.0, 'Home Point #1' }
R.tp[#R.tp + 1] = { 'hp', 236, 40.0, -238.0, 'Home Point #2' }
R.tp[#R.tp + 1] = { 'hp', 236, -127.0, 10.0, 'Home Point #3' }
R.tp[#R.tp + 1] = { 'hp', 237, 45.0, -19.0, 'Home Point #1' }
R.tp[#R.tp + 1] = { 'hp', 237, -78.0, 3.0, 'Home Point #2' }
R.tp[#R.tp + 1] = { 'hp', 238, -32.0, 131.7, 'Home Point #1' }
R.tp[#R.tp + 1] = { 'hp', 238, 138.0, -14.0, 'Home Point #2' }
R.tp[#R.tp + 1] = { 'hp', 238, 5.0, -175.0, 'Home Point #3' }
R.tp[#R.tp + 1] = { 'hp', 238, -92.0, 54.0, 'Home Point #4' }
R.tp[#R.tp + 1] = { 'hp', 239, -72.1, 124.8, 'Home Point #1' }
R.tp[#R.tp + 1] = { 'hp', 239, -212.0, -99.0, 'Home Point #2' }
R.tp[#R.tp + 1] = { 'hp', 239, 31.0, -40.0, 'Home Point #3' }
R.tp[#R.tp + 1] = { 'hp', 240, -188.0, 101.0, 'Home Point #1' }
R.tp[#R.tp + 1] = { 'hp', 240, -207.0, 210.0, 'Home Point #2' }
R.tp[#R.tp + 1] = { 'hp', 240, 180.0, 226.0, 'Home Point #3' }
R.tp[#R.tp + 1] = { 'sg', 240, -220.0, 179.0, 'Survival Guide' }
R.tp[#R.tp + 1] = { 'hp', 241, 9.1, -0.4, 'Home Point #1' }
R.tp[#R.tp + 1] = { 'hp', 241, 107.0, -56.0, 'Home Point #2' }
R.tp[#R.tp + 1] = { 'hp', 241, -92.0, 62.0, 'Home Point #3' }
R.tp[#R.tp + 1] = { 'hp', 241, 74.0, -139.0, 'Home Point #4' }
R.tp[#R.tp + 1] = { 'hp', 241, -43.5, -145.0, 'Home Point #5' }
R.tp[#R.tp + 1] = { 'hp', 243, -6.0, 0.0, 'Home Point #1' }
R.tp[#R.tp + 1] = { 'hp', 243, 53.0, -57.0, 'Home Point #2' }
R.tp[#R.tp + 1] = { 'hp', 243, -67.0, -25.0, 'Home Point #3' }
R.tp[#R.tp + 1] = { 'sg', 243, 43.0, -69.0, 'Survival Guide' }
R.tp[#R.tp + 1] = { 'hp', 244, -99.0, 167.6, 'Home Point #1' }
R.tp[#R.tp + 1] = { 'hp', 244, 32.0, -44.0, 'Home Point #2' }
R.tp[#R.tp + 1] = { 'hp', 244, -52.0, 16.0, 'Home Point #3' }
R.tp[#R.tp + 1] = { 'hp', 245, -98.6, -183.4, 'Home Point #1' }
R.tp[#R.tp + 1] = { 'hp', 245, 18.0, 54.0, 'Home Point #2' }
R.tp[#R.tp + 1] = { 'hp', 246, 37.1, 8.8, 'Home Point #1' }
R.tp[#R.tp + 1] = { 'hp', 246, -155.0, -4.0, 'Home Point #2' }
R.tp[#R.tp + 1] = { 'hp', 247, -29.3, -76.6, 'Home Point #1' }
R.tp[#R.tp + 1] = { 'hp', 247, -21.0, 110.0, 'Home Point #2' }
R.tp[#R.tp + 1] = { 'sg', 247, -3.5, -95.0, 'Survival Guide' }
R.tp[#R.tp + 1] = { 'hp', 248, 36.1, 34.6, 'Home Point #1' }
R.tp[#R.tp + 1] = { 'hp', 249, -12.8, 87.3, 'Home Point #1' }
R.tp[#R.tp + 1] = { 'hp', 250, 77.7, -94.5, 'Home Point #1' }
R.tp[#R.tp + 1] = { 'sg', 250, -40.0, -93.0, 'Survival Guide' }
R.tp[#R.tp + 1] = { 'hp', 252, -26.9, -47.2, 'Home Point #1' }
R.tp[#R.tp + 1] = { 'hp', 252, -66.0, 54.0, 'Home Point #2' }
R.tp[#R.tp + 1] = { 'sg', 252, -13.0, -34.0, 'Survival Guide' }
R.tp[#R.tp + 1] = { 'hp', 256, -84.4, -32.3, 'Home Point #1' }
R.tp[#R.tp + 1] = { 'hp', 256, 31.9, -164.0, 'Home Point #2' }
R.tp[#R.tp + 1] = { 'hp', 257, -51.9, 59.9, 'Home Point #1' }
R.tp[#R.tp + 1] = { 'hp', 257, -51.5, -96.5, 'Home Point #2' }
R.tp[#R.tp + 1] = { 'sg', 257, -50.0, -120.0, 'Survival Guide' }
R.tp[#R.tp + 1] = { 'hp', 261, -107.0, 295.0, 'Home Point #1' }
R.tp[#R.tp + 1] = { 'hp', 262, -193.0, -252.0, 'Home Point #1' }
R.tp[#R.tp + 1] = { 'hp', 263, -420.0, -62.0, 'Home Point #1' }
R.tp[#R.tp + 1] = { 'hp', 265, -415.0, 409.0, 'Home Point #1' }
R.tp[#R.tp + 1] = { 'hp', 266, -23.0, 174.0, 'Home Point #1' }
R.tp[#R.tp + 1] = { 'hp', 267, 210.0, 315.0, 'Home Point #1' }
R.tp[#R.tp + 1] = { 'hp', 276, 757.0, 17.5, 'Home Point #1' }
R.tp[#R.tp + 1] = { 'hp', 281, 4.0, 8.5, 'Home Point #1' }
return R
