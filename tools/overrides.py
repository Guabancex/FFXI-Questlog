"""Hand-checked steps for quests the script reader gets wrong.

Each entry replaces the generated steps for one quest or mission, keyed by
('q' or 'm', log id, quest or mission id). Checked against the LandSandBoat
script for that quest.

Step fields:
  k     'talk', 'trade', 'kill' or 'zone'
  n     NPCs: [(zone id, 'Npc_Name'), ...]
  x     the step text to show (replaces the generated wording)
  tip   a short note shown under the step
  need  item ids traded       gi  item ids you get
  gk    key item ids you get  b   starts the quest   c  finishes it
pos adds NPC positions: {(zone, 'Name'): (x, y, z)}.
"""

GARLAIGE, LA_THEINE, MHAURA, WINDY_WOODS, LOWER_JEUNO = 200, 102, 249, 241, 245
QUAKE_GRENADE, CHANDELIER_COAL, PICKAXE = 17314, 1091, 605
CAT_BURGLARS_NOTE, BOMB_INCENSE = 202, 193

OVERRIDES = {
    # Windurst: Hitting the Marquisate (Thief AF3)
    ('q', 2, 71): {
        'steps': [
            {'k': 'talk', 'n': [(WINDY_WOODS, 'Nanaa_Mihgo')], 'gk': [CAT_BURGLARS_NOTE], 'b': True,
             'tip': 'Level 50+ Thief main. Zone once after finishing As Thick as Thieves first.'},
            {'k': 'talk', 'n': [(LOWER_JEUNO, 'Yatniel')],
             'x': 'Talk to Yatniel (top floor) - he asks for 4 Quake Grenades'},
            {'k': 'trade', 'n': [(LOWER_JEUNO, 'Yatniel')], 'need': [QUAKE_GRENADE],
             'x': 'Trade 4 Quake Grenades to Yatniel',
             'tip': 'Required: Nanaa Mihgo won\'t continue until this is done.'},
            {'k': 'talk', 'n': [(MHAURA, 'Hagain')], 'gk': [BOMB_INCENSE],
             'tip': 'Upstairs in the Sailor\'s Stay.'},
            {'k': 'talk', 'n': [(GARLAIGE, 'qm6')],
             'x': 'Garlaige Citadel ??? 1 of 7 (I-9, in the ceiling): use Bomb Incense',
             'tip': 'Do the ??? in this order without leaving the zone, or you start over.'},
            {'k': 'talk', 'n': [(GARLAIGE, 'qm5')], 'x': 'Garlaige ??? 2 of 7 (H-9): use Bomb Incense'},
            {'k': 'talk', 'n': [(GARLAIGE, 'qm12')], 'x': 'Garlaige ??? 3 of 7 (F-9): use Bomb Incense'},
            {'k': 'talk', 'n': [(GARLAIGE, 'qm13')], 'x': 'Garlaige ??? 4 of 7 (F/G-9): use Bomb Incense'},
            {'k': 'talk', 'n': [(GARLAIGE, 'qm10')], 'x': 'Garlaige ??? 5 of 7 (G-8/9): use Bomb Incense'},
            {'k': 'talk', 'n': [(GARLAIGE, 'qm9')], 'x': 'Garlaige ??? 6 of 7 (G-7): use Bomb Incense'},
            {'k': 'talk', 'n': [(GARLAIGE, 'qm15')],
             'x': 'Garlaige ??? 7 of 7 (I-6): use Bomb Incense - Chandelier appears',
             'tip': 'Claim it before it sees you (Hide or Spectral Jig after the cutscene; no spells). '
                    'If it self-destructs there is no coal: wait 10 minutes and use this ??? again.'},
            {'k': 'kill', 'n': [(GARLAIGE, 'Chandelier')], 'gi': [CHANDELIER_COAL]},
            {'k': 'trade', 'n': [(MHAURA, 'Hagain')], 'need': [CHANDELIER_COAL]},
            {'k': 'talk', 'n': [(WINDY_WOODS, 'Nanaa_Mihgo')],
             'tip': 'She asks which letter was on your papers. "Blank" is right, but any answer works.'},
            {'k': 'trade', 'n': [(LA_THEINE, 'qm2')], 'need': [PICKAXE], 'c': True,
             'x': 'Trade a Pickaxe to the ??? in the La Theine valley (H-10, southwest corner)',
             'tip': 'Reach the valley through Ordelle\'s Caves (or its Proto-Waypoint; zone into the caves '
                    'and back first). Reward: Rogue\'s Poulaines.'},
        ],
        'pos': {
            (GARLAIGE, 'qm6'): (-220.0, -5.5, 194.2),
            (GARLAIGE, 'qm5'): (-259.9, -5.5, 194.4),
            (GARLAIGE, 'qm12'): (-245.6, -5.5, 139.9),
            (GARLAIGE, 'qm13'): (-194.2, -5.5, 140.0),
            (GARLAIGE, 'qm10'): (-139.9, -5.5, 154.5),
            (GARLAIGE, 'qm9'): (-140.0, -5.5, 286.0),
            (GARLAIGE, 'qm15'): (19.9, -5.5, 325.8),
            (GARLAIGE, 'Chandelier'): (19.9, -5.5, 325.8),   # appears at the last ???
            (LA_THEINE, 'qm2'): (-73.0, 54.6, -443.1),
        },
    },

    # Rhapsodies of Vana'diel 2-14: Cauterize (checked against LandSandBoat's
    # scripts/missions/rov/2_14_Cauterize.lua and xi.rhapsodies.charactersAvailable)
    ('m', 13, 72): {
        'steps': [
            {'k': 'talk',
             'n': [(105, 'qm_maw'), (110, 'qm_maw'), (120, 'qm_maw'), (84, 'qm_maw'), (91, 'qm_maw'), (98, 'qm_maw')],
             'gk': [2843], 'c': True,
             'x': 'Click the sparkling ??? at a Cavernous Maw for a cutscene (Batallia Downs, Rolanberry Fields '
                  'or Sauromugue Champaign, past or present)',
             'tip': 'You need Cait Sith available: your current Wings of the Goddess mission must not be '
                    'Cavernous Maws, Back to the Beginning, Where It All Began, A Token of Troth or Lest We Forget '
                    '(being on WotG 3 Cait Sith or later works; so does not having started WotG). '
                    'Next: Ganged Up On (Uncertain Destinations is completed for you).'},
        ],
        'pos': {
            (105, 'qm_maw'): (-45.3, 0.1, 442.1),     # Batallia Downs
            (110, 'qm_maw'): (-195.1, 8.0, 356.4),    # Rolanberry Fields
            (120, 'qm_maw'): (368.0, 9.1, -222.0),    # Sauromugue Champaign
            (84, 'qm_maw'): (-44.5, 0.1, 431.9),      # Batallia Downs [S]
            (91, 'qm_maw'): (-202.5, 8.0, 362.5),     # Rolanberry Fields [S]
            (98, 'qm_maw'): (374.0, 9.3, -226.3),     # Sauromugue Champaign [S]
        },
    },
}
