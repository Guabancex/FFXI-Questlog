--[[
    FFXI Questlog - quest/mission status from the game's packets, and step progress
    (no Ashita calls, so it can be tested offline).
    Author: Guabancex

    Packet layouts follow the retail client (as LandSandBoat documents them):
      0x056 quest / mission log: 8 x u32 data at 0x04, port u16 at 0x24
      0x055 key items: 16 x u32 "have" flags at 0x04, table index u16 at 0x84
]]--

local M = {}

local function u16(s, o) local a, b = s:byte(o + 1, o + 2) return a + b * 256 end
local function u32(s, o) local a, b, c, d = s:byte(o + 1, o + 4) return a + b * 256 + c * 65536 + d * 16777216 end

M.QUEST_CURRENT = { [0x50] = 0, [0x58] = 1, [0x60] = 2, [0x68] = 3, [0x70] = 4, [0x78] = 5, [0x80] = 6,
                    [0x88] = 7, [0xE0] = 8, [0xF0] = 9, [0x100] = 10 }
M.QUEST_DONE    = { [0x90] = 0, [0x98] = 1, [0xA0] = 2, [0xA8] = 3, [0xB0] = 4, [0xB8] = 5, [0xC0] = 6,
                    [0xC8] = 7, [0xE8] = 8, [0xF8] = 9, [0x108] = 10 }

-- Store an 0x056 packet into state. state = { q = {cur={}, done={}}, m = {...} }
function M.read_log(state, data)
    if #data < 0x26 then return false end
    local port = u16(data, 0x24)
    local d = {}
    for i = 0, 7 do d[i + 1] = u32(data, 0x04 + i * 4) end
    state.q = state.q or { cur = {}, done = {} }
    state.m = state.m or {}
    local m = state.m
    if M.QUEST_CURRENT[port] then
        state.q.cur[M.QUEST_CURRENT[port] + 1] = d
        if port == 0x80 then m.assault, m.toau, m.wotg = d[5], d[6], d[7] end
    elseif M.QUEST_DONE[port] then
        state.q.done[M.QUEST_DONE[port] + 1] = d
    elseif port == 0xFFFF then
        m.nation, m.nation_cur, m.zilart, m.cop = d[1], d[2], d[3], d[4]
        local addons = d[6] % 65536
        m.acp, m.amk, m.asa = addons % 16, math.floor(addons / 16) % 16, math.floor(addons / 256) % 16
        m.soa = d[7] >= 0x6E and (d[7] - 0x6E) / 2 or nil
        m.rov = d[8] >= 0x6C and (d[8] - 0x6C) or nil
    elseif port == 0xD0 then
        m.nation_done = d
    elseif port == 0xD8 then
        m.toau_wotg_done = d
    else
        return false
    end
    return true
end

-- Key items: state.ki[table] = { 16 x u32 }
function M.read_kis(state, data)
    if #data < 0x86 then return false end
    local t = u16(data, 0x84)
    local d = {}
    for i = 0, 15 do d[i + 1] = u32(data, 0x04 + i * 4) end
    state.ki = state.ki or {}
    state.ki[t + 1] = d
    return true
end

local function bit_set(words, n)
    if not words then return false end
    local w = words[math.floor(n / 32) + 1]
    if not w then return false end
    return math.floor(w / 2 ^ (n % 32)) % 2 == 1
end
M.bit_set = bit_set

function M.has_ki(state, id)
    local t = state.ki and state.ki[math.floor(id / 512) + 1]
    return bit_set(t, id % 512)
end

-- 'done' | 'active' | 'none' for a quest.
function M.quest_status(state, log, id)
    local q = state.q
    if not q then return 'none' end
    if bit_set(q.done[log + 1], id) then return 'done' end
    if bit_set(q.cur[log + 1], id) then return 'active' end
    return 'none'
end

-- 'done' | 'active' | 'none' for a mission (rules per storyline).
function M.mission_status(state, log, id)
    local m = state.m
    if not m then return 'none' end
    local function from_current(cur)
        if cur == nil or cur == 0xFFFF then return 'none' end
        if cur == id then return 'active' end
        if id < cur then return 'done' end
        return 'none'
    end
    if log <= 2 then
        if m.nation == log and m.nation_cur == id then return 'active' end
        if bit_set(m.nation_done and { m.nation_done[log * 2 + 1], m.nation_done[log * 2 + 2] }, id) then return 'done' end
        return 'none'
    elseif log == 3 then
        if m.zilart == id then return 'active' end
        if bit_set(m.nation_done and { m.nation_done[7], m.nation_done[8] }, id) then return 'done' end
        return 'none'
    elseif log == 4 or log == 5 then
        local cur = log == 4 and m.toau or m.wotg
        if cur == id then return 'active' end
        local d = m.toau_wotg_done
        local words = d and (log == 4 and { d[1], d[2] } or { d[3], d[4] })
        if bit_set(words, id) then return 'done' end
        return 'none'
    elseif log == 6 then return from_current(m.cop)
    elseif log == 9 then return from_current(m.acp)
    elseif log == 10 then return from_current(m.amk)
    elseif log == 11 then return from_current(m.asa)
    elseif log == 12 then return from_current(m.soa)
    elseif log == 13 then return from_current(m.rov)
    end
    return 'none'
end

-- Which steps are done. has_item(id) -> bool. marks = { [i] = true/false } (manual).
-- A step is done on its own when its result is visible (quest started/finished,
-- key item or item in hand); every step before a done step counts as done too.
function M.step_states(entry, status, state, has_item, marks)
    local steps = entry.st or {}
    local last = 0
    if status == 'done' then last = #steps end
    for i, st in ipairs(steps) do
        local ok = false
        if st.b and status ~= 'none' then ok = true end
        if st.c and status == 'done' then ok = true end
        for _, k in ipairs(st.gk or {}) do if M.has_ki(state, k) then ok = true end end
        for _, it in ipairs(st.gi or {}) do if has_item and has_item(it) then ok = true end end
        if ok and i > last then last = i end
    end
    local out, current = {}, nil
    for i = 1, #steps do
        local done = i <= last
        if marks and marks[i] ~= nil then done = marks[i] end
        out[i] = done
        if not done and not current then current = i end
    end
    return out, current
end

-- Auto checklist ------------------------------------------------------------
-- Does a game entity (its zone, name and x/z position) match one of a step's
-- NPCs? By name, or for unnamed points like ??? by standing within 6 yalms of
-- where the step's NPC is.
function M.npc_matches(step, npc_pos, zone, name, x, z)
    for _, n in ipairs(step.n or {}) do
        if n[1] == zone and n[2] then
            local want = n[2]:gsub('_', ' '):lower()
            if name and name ~= '' and name:lower() == want then return true end
            local p = npc_pos and npc_pos[zone .. ':' .. n[2]]
            if p and x and z then
                local dx, dz = p[1] - x, p[3] - z
                if dx * dx + dz * dz <= 36 then return true end
            end
        end
    end
    return false
end

-- Which step something that just happened finishes. what = { kind = 'event'
-- (a cutscene/menu with an NPC: talking or trading), 'kill' or 'zone', zone,
-- name, x, z }. Only the first two steps not yet done are considered, so a
-- chat with an NPC who shows up again later in the quest can't jump ahead.
-- Returns the step index or nil.
function M.auto_step(entry, done, what, npc_pos)
    local open = 0
    for i, st in ipairs(entry.st or {}) do
        if not done[i] then
            open = open + 1
            if open > 2 then break end
            local ok = false
            if what.kind == 'event' and (st.k == 'talk' or st.k == 'trade') then
                ok = M.npc_matches(st, npc_pos, what.zone, what.name, what.x, what.z)
            elseif what.kind == 'kill' and st.k == 'kill' then
                ok = M.npc_matches(st, nil, what.zone, what.name)
            elseif what.kind == 'zone' and st.k == 'zone' then
                ok = st.n and st.n[1] and st.n[1][1] == what.zone or false
            end
            if ok then return i end
        end
    end
    return nil
end

-- Distance (yalms) and compass direction from (px, pz) to (nx, nz); +z is north.
local DIRS = { 'E', 'NE', 'N', 'NW', 'W', 'SW', 'S', 'SE' }
function M.bearing(px, pz, nx, nz)
    local dx, dz = nx - px, nz - pz
    local dist = math.sqrt(dx * dx + dz * dz)
    if dist < 1 then return dist, 'here' end
    local a = math.atan2(dz, dx)
    local i = math.floor((a / (2 * math.pi) * 8) + 0.5) % 8
    return dist, DIRS[i + 1]
end

-- BG-Wiki link for a quest or mission: the wiki's "go to page" search, which
-- lands on the page when the title matches and on search results otherwise.
local function urlencode(t)
    return (tostring(t):gsub('[^%w%-%._~]', function(c) return string.format('%%%02X', c:byte()) end))
end
function M.wiki_url(title)
    return 'https://www.bg-wiki.com/index.php?title=Special:Search&go=Go&search=' .. urlencode(title)
end

-- How to get to a zone: the shortest way in zones crossed, either walking from where you are or
-- after a teleport (a Home Point, a Survival Guide or an outpost warp). R is data/routes.lua.
-- Returns up to two options, the best first; each is
--   { kind = 'walk' | 'hp' | 'sg' | 'op', label = (the teleport's name or region), path = { zone, ..., dest } }
-- (path starts in the zone you walk from, or the zone the teleport puts you in).
local KIND_COST = { walk = 0, hp = 300, sg = 350, op = 500 }   -- a teleport costs a little: walking wins a tie
local function d2(ax, az, bx, bz) local dx, dz = (bx or 0) - (ax or 0), (bz or 0) - (az or 0) return math.sqrt(dx * dx + dz * dz) end
function M.route(R, dest, dx, dz, cur, cx, cz)
    if not R or not R.links or not dest then return {} end
    -- hops from every zone to the destination (a search backwards along the zone lines)
    local rev = {}
    for z, ls in pairs(R.links) do
        for t in pairs(ls) do rev[t] = rev[t] or {} rev[t][#rev[t] + 1] = z end
    end
    local dist, nxt, queue, head = { [dest] = 0 }, {}, { dest }, 1
    while queue[head] do
        local t = queue[head] head = head + 1
        for _, z in ipairs(rev[t] or {}) do
            if dist[z] == nil then dist[z], nxt[z] = dist[t] + 1, t queue[#queue + 1] = z end
        end
    end
    -- the cost of starting at (zone, x, z): zones crossed, then how far to the first zone line (or to the place)
    local function cost(z, x, y, kind)
        local h = dist[z]
        if h == nil then return nil end
        local walk
        if h == 0 then walk = (dx and x) and d2(x, y, dx, dz) or 0
        else local e = R.links[z][nxt[z]] walk = (x and e) and d2(x, y, e[1], e[2]) or 300 end
        return h * 1000 + math.min(walk, 900) + KIND_COST[kind]
    end
    local function path(z)
        local p, guard = { z }, 0
        while z ~= dest and guard < 64 do z = nxt[z] p[#p + 1] = z guard = guard + 1 end
        return p
    end
    local opts = {}
    if cur and cur ~= dest then
        local c = cost(cur, cx, cz, 'walk')
        if c then opts[#opts + 1] = { kind = 'walk', c = c, zone = cur } end
    end
    for _, t in ipairs(R.tp or {}) do
        local c = cost(t[2], t[3], t[4], t[1])
        if c then opts[#opts + 1] = { kind = t[1], label = t[5], c = c, zone = t[2], x = t[3], z = t[4] } end
    end
    table.sort(opts, function(a, b) if a.c ~= b.c then return a.c < b.c end return (a.label or '') < (b.label or '') end)
    -- the best, and the best of another kind (so a teleport you haven't unlocked has a fallback)
    local out = {}
    for _, o in ipairs(opts) do
        local dup = false
        for _, p in ipairs(out) do if p.kind == o.kind or (p.zone == o.zone and p.kind ~= 'walk' and o.kind ~= 'walk') then dup = true end end
        if not dup then out[#out + 1] = { kind = o.kind, label = o.label, path = path(o.zone), x = o.x, z = o.z } end
        if #out == 2 then break end
    end
    -- and always the walk from where you are when it isn't one of them (a new player hasn't touched any teleport yet)
    local has = false
    for _, p in ipairs(out) do if p.kind == 'walk' then has = true end end
    if not has then
        for _, o in ipairs(opts) do
            if o.kind == 'walk' then out[#out + 1] = { kind = 'walk', path = path(o.zone) } break end
        end
    end
    return out
end
-- "Survival Guide > Buburimu Peninsula > Tahrongi Canyon" (zone names from name_of(zone)).
local KIND_TEXT = { walk = 'Walk', hp = 'Home Point', sg = 'Survival Guide', op = 'Outpost' }
function M.route_text(r, name_of)
    local parts = { KIND_TEXT[r.kind] or r.kind }
    local skip_first = r.kind == 'walk'
    if r.kind == 'op' and r.label then parts[1] = 'Outpost (' .. r.label .. ')' end
    if r.kind == 'hp' then
        -- the exact one, as the Home Point menu lists it: "Home Point: Port Windurst #2"
        local n = r.label and r.label:match('#(%d+)')
        parts[1] = 'Home Point: ' .. name_of(r.path[1]) .. (n and (' #' .. n) or '')
        skip_first = true
    elseif r.kind == 'sg' then
        parts[1] = 'Survival Guide: ' .. name_of(r.path[1])
        skip_first = true
    end
    for i, z in ipairs(r.path) do
        if not (skip_first and i == 1) then parts[#parts + 1] = name_of(z) end
    end
    return table.concat(parts, ' > ')
end

-- The route as steps a new player can follow, each a heading and a "->" line (as the old fan wiki wrote them):
--   Warp to Port Windurst          -> Any Home Point: pick Port Windurst #2 (F-6)
--   Go to Windurst Woods           -> Zone out of Port Windurst at (H-3)
--   Talk to Kupipi                 -> Kupipi - Windurst Woods (G-5)
-- grid_of(zone, x, z) gives a map grid like '(F-6)' or nil; npc = { name, zone, x, z } (nil: no last step).
function M.route_steps(R, r, name_of, grid_of, npc)
    local out = {}
    local function g(zone, x, z)
        if not (grid_of and x and z) then return nil end
        local ok, v = pcall(grid_of, zone, x, z)
        return ok and v or nil
    end
    local function at(s, gr) return gr and (s .. ' ' .. gr) or s end
    local first = r.path[1]
    if r.kind == 'hp' then
        local n = r.label and r.label:match('#(%d+)')
        out[#out + 1] = { 'Warp to ' .. name_of(first),
            at('Any Home Point: pick ' .. name_of(first) .. (n and (' #' .. n) or ''), g(first, r.x, r.z)) }
    elseif r.kind == 'sg' then
        out[#out + 1] = { 'Warp to ' .. name_of(first), at('Any Survival Guide: pick ' .. name_of(first), g(first, r.x, r.z)) }
    elseif r.kind == 'op' then
        out[#out + 1] = { 'Warp to ' .. name_of(first), at('Outpost warp to ' .. (r.label or name_of(first)) .. ' (your nation\'s gate guards)', g(first, r.x, r.z)) }
    end
    for i = 1, #r.path - 1 do
        local a, b = r.path[i], r.path[i + 1]
        local e = R.links[a] and R.links[a][b]
        out[#out + 1] = { 'Go to ' .. name_of(b), at('Zone out of ' .. name_of(a), e and g(a, e[1], e[2]) and ('at ' .. g(a, e[1], e[2])) or nil) }
    end
    if npc and npc[1] then
        out[#out + 1] = { 'Talk to ' .. npc[1], at(npc[1] .. ' - ' .. name_of(npc[2] or r.path[#r.path]), g(npc[2], npc[3], npc[4])) }
    end
    return out
end

-- The title over another way, under the quickest one: "NO SURVIVAL GUIDE THERE YET? BY HOME POINT", "OR WALK FROM HERE"
local WARP_NAME = { hp = 'Home Point', sg = 'Survival Guide', op = 'outpost warp' }
local BY = { hp = 'BY HOME POINT', sg = 'BY SURVIVAL GUIDE', op = 'BY OUTPOST WARP', walk = 'WALK FROM HERE' }
function M.route_alt_title(main, alt, k)
    local by = BY[alt.kind] or 'ANOTHER WAY'
    if k == 2 and main.kind ~= 'walk' then
        return "DON'T HAVE THAT " .. WARP_NAME[main.kind]:upper() .. '? ' .. by
    end
    return 'OR ' .. by
end

-- A "talk to" step with the same NPCs as the step before it reads as a repeat;
-- mark it so it shows as "Talk to X again" (the server's scripts often split one
-- NPC's conversation into a start and a return).
function M.mark_repeats(entry)
    local function who(st)
        if st.k ~= 'talk' then return nil end
        local t = {}
        for _, n in ipairs(st.n or {}) do t[#t + 1] = tostring(n[1]) .. ':' .. tostring(n[2]) end
        table.sort(t)
        return table.concat(t, ',')
    end
    local steps = entry.st or {}
    for i = 2, #steps do
        local a, b = who(steps[i - 1]), who(steps[i])
        if a and a ~= '' and a == b then steps[i].again = true end
    end
end

return M
