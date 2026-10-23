#!/usr/bin/env python3
"""Build data/quests.lua for FFXI Questlog from a LandSandBoat server checkout.
Author: Guabancex

usage: build_quests.py <server checkout> <zone_settings.sql> <out lua file>

The default data is built from LandSandBoat (the retail-accurate FFXI server
project, i.e. original FFXI). Older checkouts keep enums in scripts/enum/*.lua
and NPCs in sql/npc_list.sql; newer ones in data/enums/*.yaml and
data/zones/*/npcs.yaml -- both are read.

Reads:
  scripts/globals/quests.lua, missions.lua    quest and mission ids
  scripts/quests/**, scripts/missions/**      step-by-step scripts (Quest:new / Mission:new)
  scripts/zones/*/npcs/*.lua                  which NPCs touch quests without such a script
  scripts/enum/key_item.lua, item.lua, zone.lua
  sql/npc_list.sql                            NPC positions
Steps are generated from the scripts: talk to / trade to an NPC, defeat a mob,
enter a zone, receive an item or key item -- in the order the script handles them.
"""
import glob, os, re, sys

root, zone_sql, out = sys.argv[1], sys.argv[2], sys.argv[3]
P = lambda *a: os.path.join(root, *a)
def read(p):
    try:
        return open(p, encoding='utf-8', errors='replace').read()
    except OSError:
        return ''

def enum_table(text, start_pat):
    m = re.search(start_pat, text)
    if not m:
        return {}
    body = text[m.end():]
    out = {}
    for k, v in re.findall(r'^\s*([A-Z0-9_]+)\s*=\s*(\d+)', body[:body.find('\n}')], re.M):
        out[k] = int(v)
    return out

def yaml_enum(path):
    """values: name: number (data/enums/*.yaml) -> { NAME: number } as the scripts write it."""
    out = {}
    body = read(path)
    i = body.find('\nvalues:')
    for k, v in re.findall(r'^\s+([a-z0-9_]+):\s+(\d+)', body[i:] if i >= 0 else '', re.M):
        out[k.upper()] = int(v)
    return out

zone_enum = enum_table(read(P('scripts/enum/zone.lua')), r'xi\.zone\s*=\s*\{') or yaml_enum(P('data/enums/zone.yaml'))
ki_enum = enum_table(read(P('scripts/enum/key_item.lua')), r'xi\.keyItem\s*=\s*\{') or yaml_enum(P('data/enums/key_item.yaml'))
item_enum = enum_table(read(P('scripts/enum/item.lua')), r'xi\.item\s*=\s*\{') or yaml_enum(P('data/enums/item.yaml'))

# Zone names from zone_settings.sql (the same names Tidy uses).
zone_names = {}
for line in open(zone_sql, encoding='utf-8', errors='replace'):
    m = re.match(r"INSERT INTO `zone_settings` VALUES \((\d+),\d+,'?[^,]*'?,'([^']+)'", line)
    if m:
        zone_names[int(m.group(1))] = m.group(2).replace('_', ' ')
    else:
        m = re.match(r"INSERT INTO `zone_settings` VALUES \((\d+),(.*)\);", line)
        if m:
            for cand in re.findall(r"'([^']*)'", m.group(2)):
                if re.match(r"^[A-Za-z][A-Za-z0-9_'\-]+$", cand):
                    zone_names[int(m.group(1))] = cand.replace('_', ' ')
                    break

def nice(key):
    small = {'a', 'an', 'the', 'of', 'in', 'on', 'at', 'to', 'for', 'and', 'or', 'with', 'from', 'by'}
    words = key.lower().split('_')
    return ' '.join(w if (i and w in small) else w[:1].upper() + w[1:] for i, w in enumerate(words) if w)

# ---------------------------------------------------------------------------
# Quest and mission ids
# ---------------------------------------------------------------------------
QUEST_LOG = {'SANDORIA': 0, 'BASTOK': 1, 'WINDURST': 2, 'JEUNO': 3, 'OTHER_AREAS': 4, 'OUTLANDS': 5,
             'AHT_URHGAN': 6, 'CRYSTAL_WAR': 7, 'ABYSSEA': 8, 'ADOULIN': 9, 'COALITION': 10}
MISSION_LOG = {'SANDORIA': 0, 'BASTOK': 1, 'WINDURST': 2, 'ZILART': 3, 'TOAU': 4, 'WOTG': 5, 'COP': 6,
               'ASSAULT': 7, 'CAMPAIGN': 8, 'ACP': 9, 'AMK': 10, 'ASA': 11, 'SOA': 12, 'ROV': 13}

def id_blocks(text, kind):
    """{ log_id: { KEY: id } } from xi.quest.id / xi.mission.id."""
    logs = {}
    pat = r'\[xi\.%s\.area\[xi\.%s\.([A-Z_]+)\]\]\s*=\s*\{' % (kind, 'questLog' if kind == 'quest' else 'mission.log_id')
    for m in re.finditer(pat, text):
        logname = m.group(1)
        table = QUEST_LOG if kind == 'quest' else MISSION_LOG
        if logname not in table:
            continue
        body = text[m.end():]
        body = body[:body.find('\n    }')]
        logs[table[logname]] = {k: int(v) for k, v in re.findall(r'^\s*([A-Z0-9_]+)\s*=\s*(\d+)', body, re.M)}
    return logs

quest_ids = id_blocks(read(P('scripts/globals/quests.lua')), 'quest')
mission_ids = id_blocks(read(P('scripts/globals/missions.lua')), 'mission')

# ---------------------------------------------------------------------------
# NPC positions
# ---------------------------------------------------------------------------
npc_pos = {}          # (zone, name) -> (x, y, z)
npc_disp = {}         # (zone, name) -> the name the game shows (e.g. _0q1 -> Sewer Entrance)
by_disp = {}          # (zone, shown name with _ for spaces, lowercase) -> script name
for line in open(P('sql/npc_list.sql'), encoding='utf-8', errors='replace'):
    m = re.match(r"INSERT INTO `npc_list` VALUES \((\d+),'((?:[^'\\]|\\.)*)','((?:[^'\\]|\\.)*)',\d+,(-?[\d.]+),(-?[\d.]+),(-?[\d.]+),", line)
    if not m:
        continue
    npcid, name = int(m.group(1)), m.group(2).replace("\\'", "'")
    disp = m.group(3).replace("\\'", "'").replace('\\"', '"')
    x, y, z = float(m.group(4)), float(m.group(5)), float(m.group(6))
    zone = (npcid >> 12) & 0xFFF
    if disp != name and (zone, name) not in npc_disp:
        npc_disp[(zone, name)] = disp
        key = (zone, (disp or name).replace(' ', '_').lower())
        # Only a shown name that belongs to one NPC in the zone can be matched
        # (two "Dilapidated Gate"s: no telling which one a script line means).
        by_disp[key] = name if key not in by_disp or by_disp[key] == name else None
    if (x, y, z) == (0.0, 0.0, 0.0):
        continue
    npc_pos.setdefault((zone, name), (x, y, z))

# Newer LandSandBoat: one npcs.yaml per zone (id, script name, shown name, at: [x, y, z, rot]).
for path in glob.glob(P('data/zones/*/npcs.yaml')):
    text = read(path)
    for m in re.finditer(r'^  (\d+):\n((?:    .*\n|\s*\n)*)', text, re.M):
        npcid, block = int(m.group(1)), m.group(2)
        sm = re.search(r'^    script:\s*(.+?)\s*$', block, re.M)
        if not sm:
            continue
        name = sm.group(1).strip().strip('"\'')
        zone = (npcid >> 12) & 0xFFF
        dm = re.search(r'^    display_name:\s*(.*?)\s*$', block, re.M)
        disp = dm.group(1).strip() if dm else ''
        if len(disp) >= 2 and disp[0] in '"\'' and disp[-1] == disp[0]:
            disp = disp[1:-1].replace("''", "'").replace('\\"', '"')
        if disp != name and (zone, name) not in npc_disp:
            npc_disp[(zone, name)] = disp
            key = (zone, (disp or name).replace(' ', '_').lower())
            by_disp[key] = name if key not in by_disp or by_disp[key] == name else None
        am = re.search(r'^    at:\s*\[\s*(-?[\d.]+)\s*,\s*(-?[\d.]+)\s*,\s*(-?[\d.]+)', block, re.M)
        if am:
            xyz = (float(am.group(1)), float(am.group(2)), float(am.group(3)))
            if xyz != (0.0, 0.0, 0.0):
                npc_pos.setdefault((zone, name), xyz)

# ---------------------------------------------------------------------------
# Script parsing
# ---------------------------------------------------------------------------
def match_brace(s, i):
    """s[i] == '{' -> index of the matching '}' (skips strings and comments)."""
    depth, j, n = 0, i, len(s)
    while j < n:
        c = s[j]
        if c == '-' and s.startswith('--', j):
            j = s.find('\n', j)
            if j < 0:
                return n - 1
        elif c in '"\'':
            q = c
            j += 1
            while j < n and s[j] != q:
                j += 2 if s[j] == '\\' else 1
        elif c == '{':
            depth += 1
        elif c == '}':
            depth -= 1
            if depth == 0:
                return j
        j += 1
    return n - 1

def top_tables(body):
    """Top-level { ... } items inside a table body."""
    out, i = [], 0
    while True:
        i = body.find('{', i)
        if i < 0:
            break
        j = match_brace(body, i)
        out.append(body[i:j + 1])
        i = j + 1
    return out

def fn_or_table(s, i):
    """Body starting at i: a { table } or a function ... end (approximate by next sibling key)."""
    k = i
    while k < len(s) and s[k] in ' \t\n=':
        k += 1
    if k < len(s) and s[k] == '{':
        return s[k:match_brace(s, k) + 1]
    # function: take until the next "\n<same indent>['" or "\n<indent>on" sibling, approximated
    m = re.compile(r"\n\s{0,14}(\[\'|\[\"|on[A-Z]|\},|\[xi\.zone)").search(s, k)
    return s[k:m.start() if m else len(s)]

def section_status(check):
    c = re.sub(r'not\s+player:hasCompletedMission\([^)]*\)', '', check)
    if re.search(r'QUEST_COMPLETED|MISSION_COMPLETED', c) or (
            re.search(r'hasCompletedMission', c) and not re.search(r'currentMission\s*==', c)):
        return 'done'
    if re.search(r'QUEST_AVAILABLE|nation\.NONE|currentMission\s*~=', check) or re.search(r'not\s+player:hasCompletedMission', check):
        return 'start'
    return 'progress'

def things(text, enum_name, table):
    found = []
    for m in re.finditer(r'xi\.(?:%s)\.([A-Z0-9_]+)' % enum_name, text):
        if m.group(1) in table and m.group(1) not in found:
            found.append(m.group(1))
    return found

def local_functions(script):
    """name -> body text of local helper functions (approximate: up to the next top-level line)."""
    out = {}
    pat = re.compile(r'^local\s+(?:function\s+(\w+)|(\w+)\s*=\s*function)', re.M)
    ms = list(pat.finditer(script))
    for i, m in enumerate(ms):
        name = m.group(1) or m.group(2)
        end = ms[i + 1].start() if i + 1 < len(ms) else len(script)
        nxt = re.compile(r'^(?:mission|quest)\.\w+\s*=', re.M).search(script, m.end())
        if nxt and nxt.start() < end:
            end = nxt.start()
        out[name] = script[m.end():end]
    return out

def inline(text, helpers, depth=2):
    for _ in range(depth):
        extra = ''
        for name in helpers:
            if re.search(r'\b%s\b' % re.escape(name), text) and helpers[name] not in text:
                extra += '\n' + helpers[name]
        if not extra:
            break
        text += extra
    return text

def effects(text):
    """What a piece of script does: (items given, key items given, begins, completes)."""
    kis = [k for k in things(text, 'ki|keyItem', ki_enum)
           if re.search(r'(giveKeyItem|addKeyItem|keyItem)\s*\([^)]*xi\.(?:ki|keyItem)\.%s\b' % k, text)]
    items = [i for i in re.findall(r'(?:npcUtil\.giveItem|addItem)\(\s*player\s*,\s*(?:\{\s*)?\{?\s*xi\.item\.([A-Z0-9_]+)', text) if i in item_enum]
    items = list(dict.fromkeys(items))
    return items, kis, bool(re.search(r':begin\(', text)), bool(re.search(r':complete\(', text))

def csids(text, raw=None):
    found = [int(n) for n in re.findall(r'(?:progressEvent|progressCutscene|startEvent|event|cutscene)\(\s*(\d+)', text)]
    if not found and raw is not None and re.search(r'progressEvent|progressCutscene|startEvent', text):
        # Event ids passed to a helper: take the numbers in the call.
        found = [int(n) for n in re.findall(r'\b(\d{2,5})\b', raw)]
    return found

TRADE_CALLS = re.compile(r'(tradeHasExactly|tradeHasOnly|tradeHas|hasItemQty)\s*\(')
def trade_items(text):
    out = []
    for m in TRADE_CALLS.finditer(text):
        depth, j = 1, m.end()
        while j < len(text) and depth:
            depth += {'(': 1, ')': -1}.get(text[j], 0)
            j += 1
        for it in re.findall(r'xi\.item\.([A-Z0-9_]+)', text[m.end():j]):
            if it in item_enum and it not in out:
                out.append(it)
    return out

def steps_for(script):
    helpers = local_functions(script)
    raw = []
    m = re.search(r'\.sections\s*=\s*\{', script)
    if not m:
        return []
    start = script.find('{', m.start())
    sections = top_tables(script[start + 1:match_brace(script, start)])
    for si, sec in enumerate(sections):
        cm = re.search(r'check\s*=\s*function(.*?)\n\s*end,', sec, re.S)
        status = section_status(cm.group(1) if cm else '')
        if status == 'done':
            continue
        for zm in re.finditer(r'\[xi\.zone\.([A-Z0-9_]+)\]\s*=\s*\{', sec):
            zone = zone_enum.get(zm.group(1))
            zstart = sec.find('{', zm.start())
            zbody = sec[zstart:match_brace(sec, zstart) + 1]
            finish = {}
            fm = re.search(r'onEventFinish\s*=\s*\{', zbody)
            if fm:
                fs = zbody.find('{', fm.start())
                ftab = zbody[fs:match_brace(zbody, fs) + 1]
                keys = list(re.finditer(r'\[(\d+)\]\s*=', ftab))
                for i, k in enumerate(keys):
                    end = keys[i + 1].start() if i + 1 < len(keys) else len(ftab)
                    finish[int(k.group(1))] = inline(ftab[k.end():end], helpers)
            def fx(ids, direct=''):
                items, kis, begins, completes = effects(direct)
                handled = False
                for c in ids:
                    if c in finish:
                        handled = True
                        i2, k2, b2, c2 = effects(finish[c])
                        items += [x for x in i2 if x not in items]
                        kis += [x for x in k2 if x not in kis]
                        begins, completes = begins or b2, completes or c2
                return handled or bool(items or kis or begins or completes), (tuple(items), tuple(kis), begins, completes)
            for em in re.finditer(r"\[\s*['\"]([^'\"]+)['\"]\s*\]\s*=", zbody):
                name = em.group(1)
                body = inline(fn_or_table(zbody, em.end()), helpers)
                if 'onMobDeath' in body:
                    raw.append({'k': 'kill', 'npc': [(zone, name)], 'need': (), 'fx': ((), (), False, False), 'sec': si})
                    continue
                tm = re.search(r'onTrade\s*=(.*?)(?=\n\s*on[A-Z]\w*\s*=|\Z)', body, re.S)
                if tm:
                    tpart = inline(tm.group(1), helpers)
                    need = tuple(trade_items(tpart)[:3])
                    ok, eff = fx(csids(tpart, tm.group(1)), tpart)
                    if need and ok:
                        raw.append({'k': 'trade', 'npc': [(zone, name)], 'need': need, 'fx': eff, 'sec': si})
                    body = body.replace(tm.group(0), '')
                ok, eff = fx(csids(body), body)
                if ok:
                    raw.append({'k': 'talk', 'npc': [(zone, name)], 'need': (), 'fx': eff, 'sec': si})
            zi = re.search(r'onZoneIn\s*=', zbody)
            if zi:
                zpart = inline(fn_or_table(zbody, zi.end()), helpers)
                ok, eff = fx(csids(zpart), zpart)
                if ok and csids(zpart):
                    raw.append({'k': 'zone', 'npc': [(zone, None)], 'need': (), 'fx': eff, 'sec': si})
    # Alternatives: the same kind of step with the same result in one section -> one step.
    merged = []
    for st in raw:
        prev = merged[-1] if merged else None
        if prev and prev['k'] == st['k'] and prev['sec'] == st['sec'] and prev['fx'] == st['fx'] \
                and prev['need'] == st['need'] and st['k'] in ('talk', 'trade'):
            if st['npc'][0] not in prev['npc']:
                prev['npc'].append(st['npc'][0])
        else:
            merged.append(st)
    # Order: a trade comes after the step that hands you what it needs.
    ordered = []
    for st in merged:
        ordered.append(st)
    changed = True
    guard = 0
    while changed and guard < 50:
        changed, guard = False, guard + 1
        for i, st in enumerate(ordered):
            for need in st['need']:
                for j in range(i + 1, len(ordered)):
                    if need in ordered[j]['fx'][0]:
                        ordered.insert(j, ordered.pop(i))
                        changed = True
                        break
                if changed:
                    break
            if changed:
                break
    # Steps that start it go first, steps that finish it go last.
    ordered = [st for st in ordered if st['fx'][2] and not st['fx'][3]] + \
              [st for st in ordered if not st['fx'][2] and not st['fx'][3]] + \
              [st for st in ordered if st['fx'][3]]
    # Drop exact repeats.
    out = []
    for st in ordered:
        key = (st['k'], tuple(st['npc']), st['need'], st['fx'])
        if not out or (out[-1]['k'], tuple(out[-1]['npc']), out[-1]['need'], out[-1]['fx']) != key:
            out.append(st)
    return out

def header_pos(script):
    """NPC positions from '-- Name : !pos x y z zone' lines in a script header.
    Returns (name, x, y, z, zone, exact): exact is False for names written with
    spaces or a note in brackets, e.g. '-- qm6 (???) : !pos ...'."""
    out = []
    for raw, note, x, y, z, zone in re.findall(
            r'^--\s*([A-Za-z0-9_\' .\-]+?)(\s*\([^)]*\))?\s*:\s*!pos\s+(-?[\d.]+)\s+(-?[\d.]+)\s+(-?[\d.]+)\s+(\d+)',
            script, re.M):
        name = raw.strip()
        out.append((name.replace(' ', '_'), float(x), float(y), float(z), int(zone), not note and ' ' not in name))
    return out

def header_title(script, key):
    lines = [l[2:].strip() for l in script.splitlines()[:4] if l.startswith('--') and l.strip('- ')]
    if lines and not lines[0].startswith('!') and len(lines[0]) < 60:
        t = lines[0].replace('_', ' ')
        return t, (lines[1] if len(lines) > 1 and '!' not in lines[1] and 'Log ID' not in lines[1] and len(lines[1]) < 40 else '')
    return nice(key), ''

entries = {}          # ('q'|'m', log, id) -> dict
used_npcs, used_kis, used_items = set(), set(), set()
for path in sorted(glob.glob(P('scripts/quests/**/*.lua'), recursive=True)) + sorted(glob.glob(P('scripts/missions/**/*.lua'), recursive=True)):
    s = read(path)
    m = re.search(r'Quest:new\(\s*xi\.questLog\.([A-Z_]+)\s*,\s*xi\.quest\.id\.\w+\.([A-Z0-9_]+)', s)
    kind = 'q'
    if not m:
        m = re.search(r'Mission:new\(\s*xi\.mission\.log_id\.([A-Z_]+)\s*,\s*xi\.mission\.id\.\w+\.([A-Z0-9_]+)', s)
        kind = 'm'
    if not m:
        continue
    log = (QUEST_LOG if kind == 'q' else MISSION_LOG).get(m.group(1))
    ids = (quest_ids if kind == 'q' else mission_ids).get(log, {})
    if log is None or m.group(2) not in ids:
        continue
    title, sub = header_title(s, m.group(2))
    steps = steps_for(s)
    # A script's '-- Name : !pos x y z zone' lines are the spot to stand at (the
    # one GMs !pos to), better than the object's own spot in npc_list (a door or
    # ??? can sit inside a wall). They win when they name the NPC by its script
    # name or by the name the game shows (Sewer Entrance -> _0q1).
    # Matched by the shown name or a spaced name, a line only refines the spot
    # when it's near the NPC (within 15 yalms): a far one is an old or mistaken
    # comment, and the server's own spot is kept.
    for name, x, y, z, zone, exact in header_pos(s):
        if exact:
            npc_pos[(zone, name)] = (x, y, z)
            continue
        real = name if (zone, name) in npc_pos else by_disp.get((zone, name.lower()))
        if real:
            ox, oy, oz = npc_pos.get((zone, real), (x, y, z))
            if ((ox - x) ** 2 + (oz - z) ** 2) ** 0.5 <= 15:
                npc_pos[(zone, real)] = (x, y, z)
        else:
            npc_pos.setdefault((zone, name), (x, y, z))   # only fills a gap
    for st in steps:
        for z, n in st['npc']:
            if n:
                used_npcs.add((z, n))
        used_kis.update(st['fx'][1])
    entries[(kind, log, ids[m.group(2)])] = {'key': m.group(2), 'title': title, 'sub': sub, 'steps': steps}

# Hand-checked steps replace the generated ones.
sys.path.insert(0, os.path.dirname(os.path.abspath(__file__)))
from overrides import OVERRIDES
for key, ov in OVERRIDES.items():
    if key not in entries:
        continue
    entries[key]['manual'] = ov['steps']
    ki_by_id = {v: k for k, v in ki_enum.items()}
    for st in ov['steps']:
        for z, n in st['n']:
            if n:
                used_npcs.add((z, n))
        for k in st.get('gk', []):
            if k in ki_by_id:
                used_kis.add(ki_by_id[k])
    for (z, n), xyz in ov.get('pos', {}).items():
        npc_pos[(z, n)] = xyz

# Quests without a step script: which NPCs mention them.
zone_by_folder = {}
for k, v in zone_enum.items():
    zone_by_folder[re.sub(r'[^A-Z0-9]', '', k)] = v
mentions = {}
area_log = {'sandoria': 0, 'bastok': 1, 'windurst': 2, 'jeuno': 3, 'otherAreas': 4, 'outlands': 5,
            'ahtUrhgan': 6, 'crystalWar': 7, 'abyssea': 8, 'adoulin': 9, 'coalition': 10}
npc_files = glob.glob(P('scripts/zones/*/npcs/*.lua'))
for path in npc_files:
    s = read(path)
    folder = os.path.basename(os.path.dirname(os.path.dirname(path)))
    zone = zone_by_folder.get(re.sub(r'[^A-Z0-9]', '', folder.upper()))
    npc = os.path.splitext(os.path.basename(path))[0]
    for area, key in set(re.findall(r'xi\.quest\.id\.(\w+)\.([A-Z0-9_]+)', s)):
        log = area_log.get(area)
        if log is None or key not in quest_ids.get(log, {}):
            continue
        mentions.setdefault((log, quest_ids[log][key]), []).append((zone, npc))

# Older quests are written into the NPC scripts themselves (no Quest:new step
# script). Their steps are worked out from those scripts: which events each NPC
# plays for the quest (the onTrigger / onTrade branches whose conditions name
# the quest, its status variable or its progress variable), and what each event
# does when it finishes (begins the quest, gives items or key items, finishes it).
def norm(t): return re.sub(r'[^A-Z0-9]', '', t.upper())

def fn_body(src, name):
    m = re.search(r'entity\.%s\s*=\s*function' % name, src)
    if not m:
        return ''
    nxt = re.compile(r'^entity\.\w+\s*=', re.M).search(src, m.end())
    return src[m.end():nxt.start() if nxt else len(src)]

def branches(body):
    """(condition, block) for each if/elseif in a function body (flat, good enough)."""
    out = []
    ms = list(re.finditer(r'\b(?:if|elseif)\b(.*?)\bthen\b', body, re.S))
    for i, m in enumerate(ms):
        end = ms[i + 1].start() if i + 1 < len(ms) else len(body)
        out.append((m.group(1), body[m.end():end]))
    return out

def quest_tokens(src, area, key):
    toks = {'xi.quest.id.%s.%s' % (area, key)}
    for var in re.findall(r'local\s+(\w+)\s*=\s*player:getQuestStatus\([^)]*xi\.quest\.id\.%s\.%s\b' % (area, key), src):
        toks.add(var)
    nk = norm(key)
    for cv in set(re.findall(r"CharVar\(\s*['\"]([^'\"]+)['\"]", src)):
        if len(nk) >= 6 and norm(cv).startswith(nk[:max(6, len(nk) - 2)]):
            toks.add(cv)
    return toks

def mentions_any(text, toks):
    return any(re.search(r'(?<![\w.])%s(?![\w])' % re.escape(t), text) for t in toks)

def legacy_effects(text, area, key):
    q = r'xi\.quest\.id\.%s\.%s\b' % (area, key)
    kis = [k for k in re.findall(r'(?:addKeyItem|giveKeyItem)\(\s*(?:player\s*,\s*)?xi\.(?:ki|keyItem)\.([A-Z0-9_]+)', text) if k in ki_enum]
    items = [i for i in re.findall(r'(?:npcUtil\.giveItem|addItem)\(\s*(?:player\s*,\s*)?(?:\{\s*)?\{?\s*xi\.item\.([A-Z0-9_]+)', text) if i in item_enum]
    begins = bool(re.search(r'addQuest\([^)]*%s' % q, text))
    completes = bool(re.search(r'completeQuest\([^)]*%s' % q, text, re.S))
    return tuple(dict.fromkeys(items)), tuple(dict.fromkeys(kis)), begins, completes

def legacy_steps(files, area, key):
    raw = []
    for zone, npc, src in files:
        toks = quest_tokens(src, area, key)
        fin = fn_body(src, 'onEventFinish')
        finish = {}
        for c, block in branches(fin):
            for n in re.findall(r'csid\s*==\s*(\d+)', c):
                finish[int(n)] = finish.get(int(n), '') + block
        def fx(ids, direct):
            items, kis, b, c = legacy_effects(direct, area, key)
            items, kis = list(items), list(kis)
            for i in ids:
                i2, k2, b2, c2 = legacy_effects(finish.get(i, ''), area, key)
                items += [x for x in i2 if x not in items]
                kis += [x for x in k2 if x not in kis]
                b, c = b or b2, c or c2
            return (tuple(items), tuple(kis), b, c)
        for kind, fname in (('trade', 'onTrade'), ('talk', 'onTrigger')):
            for cond, block in branches(fn_body(src, fname)):
                if not mentions_any(cond, toks) and not mentions_any(block, {'xi.quest.id.%s.%s' % (area, key)}):
                    continue
                ids = [int(n) for n in re.findall(r'startEvent\(\s*(\d+)', block)]
                if not ids and kind == 'talk':
                    continue
                eff = fx(ids, block)
                if kind == 'trade':
                    need = tuple(trade_items(cond + block)[:3])
                    if not need:
                        continue
                    raw.append({'k': 'trade', 'npc': [(zone, npc)], 'need': need, 'fx': eff, 'sec': 0})
                else:
                    raw.append({'k': 'talk', 'npc': [(zone, npc)], 'need': (), 'fx': eff, 'sec': 0})
    # Keep the steps that do something, plus one plain talk per NPC; merge repeats.
    out, seen = [], set()
    for st in raw:
        does = any(st['fx'][:2]) or st['fx'][2] or st['fx'][3] or st['k'] == 'trade'
        k = (st['k'], st['npc'][0], st['need'], st['fx'])
        if k in seen:
            continue
        if not does and any(o['npc'][0] == st['npc'][0] for o in out):
            continue
        seen.add(k)
        out.append(st)
    # Trades after whatever hands out what they need; start first, finish last.
    out = [st for st in out if st['fx'][2] and not st['fx'][3]] + \
          [st for st in out if not st['fx'][2] and not st['fx'][3]] + \
          [st for st in out if st['fx'][3]]
    if not any(st['fx'][2] or st['fx'][3] for st in out):
        return []          # nothing that starts or finishes it: not a real step list
    return out[:12]

area_name = {v: k for k, v in area_log.items()}
npc_src = {}
for path in npc_files:
    folder = os.path.basename(os.path.dirname(os.path.dirname(path)))
    zone = zone_by_folder.get(re.sub(r'[^A-Z0-9]', '', folder.upper()))
    npc_src[(zone, os.path.splitext(os.path.basename(path))[0])] = read(path)
legacy_count = 0
for (log, qid), who in mentions.items():
    if ('q', log, qid) in entries:
        continue
    key = next((k for k, v in quest_ids[log].items() if v == qid), None)
    files = [(z, n, npc_src[(z, n)]) for z, n in sorted(set(who), key=lambda t: (t[0] or 0, t[1])) if (z, n) in npc_src]
    steps = legacy_steps(files, area_name[log], key)
    if steps:
        for st in steps:
            for z, n in st['npc']:
                used_npcs.add((z, n))
            used_kis.update(st['fx'][1])
        entries[('q', log, qid)] = {'key': key, 'title': nice(key), 'sub': '', 'steps': steps}
        legacy_count += 1
print('older quests with steps from NPC scripts: %d' % legacy_count)

for log, table in quest_ids.items():
    for key, qid in table.items():
        e = entries.get(('q', log, qid))
        if e is None:
            npcs = sorted(set(mentions.get((log, qid), [])), key=lambda t: (t[0] or 0, t[1]))[:6]
            for z, n in npcs:
                used_npcs.add((z, n))
            entries[('q', log, qid)] = {'key': key, 'title': nice(key), 'sub': '', 'steps': [],
                                        'npcs': npcs, 'noscript': not npcs}
for log, table in mission_ids.items():
    for key, mid in table.items():
        if key == 'NONE':
            continue
        entries.setdefault(('m', log, mid), {'key': key, 'title': nice(key), 'sub': '', 'steps': [], 'noscript': True})

# ---------------------------------------------------------------------------
# Write
# ---------------------------------------------------------------------------
def L(s):
    return "'" + str(s).replace('\\', '\\\\').replace("'", "\\'").replace('\n', ' ') + "'"

def step_lua(st):
    items, kis, begins, completes = st['fx']
    npcs = ','.join('{%d,%s}' % (z or 0, L(n) if n else 'nil') for z, n in st['npc'])
    parts = ['k=%s' % L(st['k']), 'n={%s}' % npcs]
    if st['need']:
        parts.append('need={%s}' % ','.join(str(item_enum[i]) for i in st['need']))
    if items:
        parts.append('gi={%s}' % ','.join(str(item_enum[i]) for i in items))
    if kis:
        parts.append('gk={%s}' % ','.join(str(ki_enum[k]) for k in kis))
    if begins:
        parts.append('b=true')
    if completes:
        parts.append('c=true')
    return '{' + ','.join(parts) + '}'

def manual_lua(st):
    npcs = ','.join('{%d,%s}' % (z or 0, L(n) if n else 'nil') for z, n in st['n'])
    parts = ['k=%s' % L(st['k']), 'n={%s}' % npcs]
    for f in ('need', 'gi', 'gk'):
        if st.get(f):
            parts.append('%s={%s}' % (f, ','.join(str(i) for i in st[f])))
    for f in ('x', 'tip'):
        if st.get(f):
            parts.append('%s=%s' % (f, L(st[f])))
    if st.get('b'):
        parts.append('b=true')
    if st.get('c'):
        parts.append('c=true')
    return '{' + ','.join(parts) + '}'

with open(out, 'w', encoding='utf-8') as f:
    f.write('-- Generated by tools/build_quests.py from LandSandBoat (original FFXI). Do not edit.\n')
    f.write('local Q, M, npcs, kis, zones, names = {}, {}, {}, {}, {}, {}\n')
    for (kind, log, eid), e in sorted(entries.items(), key=lambda t: (t[0][0], t[0][1], t[0][2])):
        if e.get('manual'):
            steps = ','.join(manual_lua(s) for s in e['manual'])
        else:
            steps = ','.join(step_lua(s) for s in e['steps'])
        extra = ''
        if e.get('npcs'):
            extra = ',n={%s}' % ','.join('{%d,%s}' % (z or 0, L(n)) for z, n in e['npcs'])
        if e.get('noscript'):
            extra += ',x=true'      # no step script for it anywhere: no step list
        tbl = 'Q' if kind == 'q' else 'M'
        f.write('%s[#%s+1]={l=%d,i=%d,t=%s,s=%s,st={%s}%s}\n' % (tbl, tbl, log, eid, L(e['title']), L(e['sub']), steps, extra))
    for (zone, name) in sorted(used_npcs, key=lambda t: (t[0] or 0, t[1])):
        pos = npc_pos.get((zone, name))
        if pos:
            f.write('npcs[%s]={%.1f,%.1f,%.1f}\n' % (L('%d:%s' % (zone or 0, name)), pos[0], pos[1], pos[2]))
    shown = []
    for (zone, name) in sorted(used_npcs, key=lambda t: (t[0] or 0, t[1])):
        # The name the game shows: written when it differs from the script name.
        # '???' stays ??? in the addon; an empty name (an invisible trigger spot,
        # such as blank_lamp) is written as '' and shown as "Unmarked spot".
        d = npc_disp.get((zone, name))
        if d is None and npc_pos.get((zone, name)) is not None:
            pass
        if d is not None and d.strip() not in ('???', 'NOT_CAPTURED') and d.replace(' ', '_') != name:
            shown.append('[%s]=%s' % (L('%d:%s' % (zone or 0, name)), L(d.strip())))
    f.write('names={' + ','.join(shown) + '}\n')
    f.write('kis={' + ','.join('[%d]=%s' % (ki_enum[k], L(nice(k))) for k in sorted(used_kis)) + '}\n')
    f.write('zones={' + ','.join('[%d]=%s' % (z, L(n)) for z, n in sorted(zone_names.items())) + '}\n')
    f.write('return { quests = Q, missions = M, npcs = npcs, kis = kis, zones = zones, names = names }\n')

with_steps = sum(1 for e in entries.values() if e['steps'] or e.get('manual'))
print('quests %d, missions %d, with steps %d, npcs %d (positions %d), key items %d, npc scripts read %d' % (
    sum(1 for k in entries if k[0] == 'q'), sum(1 for k in entries if k[0] == 'm'), with_steps,
    len(used_npcs), sum(1 for z, n in used_npcs if (z, n) in npc_pos), len(used_kis), len(npc_files)))
