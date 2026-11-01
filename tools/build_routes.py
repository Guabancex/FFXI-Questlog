#!/usr/bin/env python3
"""Build data/routes.lua for FFXI Questlog: how the zones connect, and where you can
teleport to. Author: Guabancex

usage: build_routes.py <server checkout> <out lua file>

Reads <checkout>/sql/zone_settings.sql (zone ids and names), <checkout>/data/zones/*/zone.yaml
(each zone's zone lines: where they are and where they lead), <checkout>/data/zones/*/npcs.yaml
(Home Points and Survival Guides, and where they stand) and
<checkout>/scripts/globals/teleports.lua (where an outpost warp drops you).
"""
import os, re, sys

root, out = sys.argv[1], sys.argv[2]

def norm(s):
    return re.sub(r'[^a-z0-9]', '', s.lower())

names, by_norm = {}, {}
for line in open(os.path.join(root, 'sql', 'zone_settings.sql'), encoding='utf-8', errors='replace'):
    m = re.match(r"INSERT INTO `zone_settings` VALUES \((\d+),'[^']*',\d+,'([^']*)'", line)
    if m and int(m.group(1)) > 0 and m.group(2) != 'unknown':
        zid, nm = int(m.group(1)), m.group(2)
        names[zid] = nm.replace('_', ' ')
        by_norm[norm(nm)] = zid

zdir = os.path.join(root, 'data', 'zones')
links = {}          # zone -> { neighbour: (x, z) of the zone line in this zone }
tps = []            # (kind, zone, x, z, label)
FLOAT = r'(-?[\d.]+)'
for folder in sorted(os.listdir(zdir)):
    zid = by_norm.get(norm(folder))
    if zid is None:
        continue
    zy = os.path.join(zdir, folder, 'zone.yaml')
    if os.path.exists(zy):
        src = open(zy, encoding='utf-8', errors='replace').read()
        for m in re.finditer(r"from:\s*\[\s*" + FLOAT + r"\s*,\s*" + FLOAT + r"\s*,\s*" + FLOAT + r"\s*\]\s*\n\s*to:\s*(\S+)", src):
            to = by_norm.get(norm(m.group(4)))
            if to is None or to == zid:
                continue
            links.setdefault(zid, {}).setdefault(to, (float(m.group(1)), float(m.group(3))))
    ny = os.path.join(zdir, folder, 'npcs.yaml')
    if os.path.exists(ny):
        src = open(ny, encoding='utf-8', errors='replace').read()
        for m in re.finditer(r"script:\s*(HomePoint#\d+|Survival_Guide)\s*\n(?:\s*display_name:[^\n]*\n)?\s*at:\s*\[\s*" + FLOAT + r"\s*,\s*" + FLOAT + r"\s*,\s*" + FLOAT, src):
            kind = 'sg' if m.group(1) == 'Survival_Guide' else 'hp'
            tps.append((kind, zid, float(m.group(2)), float(m.group(4)), m.group(1).replace('#', ' #').replace('HomePoint', 'Home Point').replace('_', ' ')))

REGION = {'RONFAURE': 'Ronfaure', 'ZULKHEIM': 'Zulkheim', 'NORVALLEN': 'Norvallen', 'GUSTABERG': 'Gustaberg', 'DERFLAND': 'Derfland',
          'SARUTABARUTA': 'Sarutabaruta', 'KOLSHUSHU': 'Kolshushu', 'ARAGONEU': 'Aragoneu', 'FAUREGANDI': 'Fauregandi',
          'VALDEAUNIA': 'Valdeaunia', 'QUFIMISLAND': 'Qufim Island', 'LITELOR': "Li'Telor", 'KUZOTZ': 'Kuzotz', 'VOLLBOW': 'Vollbow',
          'ELSHIMO_LOWLANDS': 'Elshimo Lowlands', 'ELSHIMO_UPLANDS': 'Elshimo Uplands', 'TAVNAZIANARCH': 'Tavnazian Archipelago'}
tsrc = open(os.path.join(root, 'scripts', 'globals', 'teleports.lua'), encoding='utf-8', errors='replace').read()
block = re.search(r"local outpostDestinations =\s*\{(.*?)\n\}", tsrc, re.S).group(1)
for m in re.finditer(r"\[xi\.region\.(\w+)\s*\]\s*=\s*\{\s*" + FLOAT + r"\s*,\s*" + FLOAT + r"\s*,\s*" + FLOAT + r"\s*,\s*\d+\s*,\s*(\d+)\s*\}", block):
    if m.group(1) in REGION:
        tps.append(('op', int(m.group(5)), float(m.group(2)), float(m.group(4)), REGION[m.group(1)]))

def q(s):
    return "'" + s.replace('\\', '\\\\').replace("'", "\\'") + "'"
with open(out, 'w', encoding='utf-8') as f:
    w = f.write
    w("-- FFXI Questlog: how the zones connect and where you can teleport to (tools/build_routes.py).\n")
    w("-- names[zone] = its name; links[zone] = { [next zone] = { x, z of the zone line in this zone } };\n")
    w("-- tp = { { kind, zone, x, z, label } }: kind 'hp' Home Point, 'sg' Survival Guide, 'op' outpost warp (label: its region).\n")
    w("local R = { names = {}, links = {}, tp = {} }\n")
    for zid in sorted(names):
        w("R.names[%d] = %s\n" % (zid, q(names[zid])))
    for zid in sorted(links):
        w("R.links[%d] = { %s }\n" % (zid, ', '.join('[%d] = { %.1f, %.1f }' % (t, p[0], p[1]) for t, p in sorted(links[zid].items()))))
    for kind, zid, x, z, label in sorted(tps, key=lambda t: (t[1], t[0], t[4])):
        w("R.tp[#R.tp + 1] = { '%s', %d, %.1f, %.1f, %s }\n" % (kind, zid, x, z, q(label)))
    w("return R\n")
print('zones', len(names), 'linked', len(links), 'zone lines', sum(len(v) for v in links.values()),
      'home points', sum(1 for t in tps if t[0] == 'hp'), 'survival guides', sum(1 for t in tps if t[0] == 'sg'), 'outposts', sum(1 for t in tps if t[0] == 'op'))
