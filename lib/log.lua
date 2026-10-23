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

return M
