--[[
FFXI Questlog - a quest and mission helper.
Author: Guabancex

For Ashita v4. Lists your quests and missions, shows the steps for
each one, scratches out the steps you've done, and tells you where the NPCs
are: zone, coordinates, and -- when you're in that zone -- how far and which way.

Your progress comes from the game's own quest log, mission log and key items
(the server sends them when you log in or zone), plus the items you carry.
Steps the game can't see, you tick off yourself. The step lists are generated
from original FFXI: LandSandBoat's retail-accurate quest and mission scripts.

Commands:
  /ql               show / hide the window
  /ql find <text>   search quests and missions
  /ql mini          minimize to the crystal / open the full window
  /ql pos <x> <y>   put the window at this screen position
  /ql lock          lock / unlock the window and the crystal in place (or use the Lock switch)
  /ql help
]]--

addon.name    = 'FFXI Questlog'
addon.author  = 'Guabancex'
addon.version = '3.2.1'
addon.desc    = 'Quest and mission helper: steps, progress and NPC locations.'
addon.link    = ''

require('common')
local chat     = require('chat')
local imgui    = require('imgui')
local settings = require('settings')
local log      = require('lib.log')

local START_W, START_H = 680, 460
local MIN_W, MIN_H     = 560, 360
local LIST_W           = 236        -- the sidebar: wordmark, filters, search, the list
local SIDE_GAP         = 26         -- between the sidebar and the steps
local RADIUS           = 0          -- square corners (cinematic menu look)

local defaults = T{
    visible = true,
    mini    = false,        -- minimized to the crystal
    full_size = T{ -1, -1 },    -- the full window's size, restored when you open it again
    filter  = 'active',     -- 'active' | 'all' (completed ones are never listed)
    marks   = T{},          -- ['q:0:11'] = { [step] = true/false }  ticks (yours and auto)
    opacity = 82,           -- window opacity, 30-100
    auto    = true,         -- auto checklist: tick talk/trade/kill/zone steps as they happen
    unscripted = true,      -- list quests/missions that have no step list (false hides them)
    cache   = T{},          -- last quest/mission/key item data from the game
    pos     = T{ -1, -1 },
    locked  = false,        -- lock style: the window and the crystal stay where they are
}

local S, data = nil, nil
local routes = nil          -- data/routes.lua: how the zones connect, where you can teleport to
local guides = {}        -- detailed walkthroughs (data/guides.lua), by quest area then quest id
local mguides = {}       -- mission walkthroughs (data/mission_guides.lua), by mission area then mission id
local ui = { open = { true }, search = { '' }, selected = nil }
local item_names = {}

local function say(fmt, ...) print(chat.header(addon.name):append(chat.message(string.format(fmt, ...)))) end
local function err(fmt, ...) print(chat.header(addon.name):append(chat.error(string.format(fmt, ...)))) end

local QUEST_AREAS = { [0] = "San d'Oria", 'Bastok', 'Windurst', 'Jeuno', 'Other Areas', 'Outlands',
                      'Aht Urhgan', 'Crystal War', 'Abyssea', 'Adoulin', 'Coalition' }
local MISSION_AREAS = { [0] = "San d'Oria", 'Bastok', 'Windurst', 'Rise of the Zilart', 'Treasures of Aht Urhgan',
                        'Wings of the Goddess', 'Chains of Promathia', 'Assault', 'Campaign',
                        'A Crystalline Prophecy', 'A Moogle Kupo d\'Etat', 'A Shantotto Ascension',
                        'Seekers of Adoulin', 'Rhapsodies of Vana\'diel' }

-- ---------------------------------------------------------------------------
-- Game state
-- ---------------------------------------------------------------------------

local function item_name(id)
    if item_names[id] then return item_names[id] end
    local name = 'Item #' .. id
    pcall(function()
        local r = AshitaCore:GetResourceManager():GetItemById(id)
        if r and r.Name and r.Name[1] and r.Name[1] ~= '' then name = r.Name[1] end
    end)
    item_names[id] = name
    return name
end

local held, held_at = {}, -10
local BAGS = { 0, 5, 6, 7, 8, 10, 11, 12, 13, 14, 15, 16 }
local function refresh_held(now)
    if now - held_at < 2 then return end
    held_at, held = now, {}
    pcall(function()
        local inv = AshitaCore:GetMemoryManager():GetInventory()
        for _, bag in ipairs(BAGS) do
            local max = inv:GetContainerCountMax(bag) or 0
            for i = 1, max - 1 do
                local it = inv:GetContainerItem(bag, i)
                if it and (it.Id or 0) ~= 0 and it.Id ~= 0xFFFF then held[it.Id] = true end
            end
        end
    end)
end
local function has_item(id) return held[id] == true end

-- Your zone and position. x and z are the map (east-west, north-south), y is
-- height, the same order the server uses (!pos x y z).
local my_y = nil
local function where_am_i()
    local zone, x, z
    my_y = nil
    pcall(function()
        local mm = AshitaCore:GetMemoryManager()
        zone = mm:GetParty():GetMemberZone(0)
        local idx = mm:GetParty():GetMemberTargetIndex(0)
        local em = mm:GetEntity()
        -- Ashita keeps a position as X, Z, Y with Z the height: the map is X and Y (the server's x and z).
        x, z = em:GetLocalPositionX(idx), em:GetLocalPositionY(idx)
        local ok, h = pcall(em.GetLocalPositionZ, em, idx)
        if ok and type(h) == 'number' then my_y = h end
    end)
    return zone, x, z
end

-- Coordinates as Ashita shows them: x, y on the map, z the height (whole numbers).
local function coords(x, map_y, height)
    local function r(v) return type(v) == 'number' and math.floor(v + 0.5) or 0 end
    return string.format('(%d, %d, %d)', r(x), r(map_y), r(height))
end

local function entry_key(kind, e) return string.format('%s:%d:%d', kind, e.l, e.i) end
local function status_of(kind, e)
    if kind == 'q' then return log.quest_status(S.cache, e.l, e.i) end
    return log.mission_status(S.cache, e.l, e.i)
end

-- ---------------------------------------------------------------------------
-- Text for steps and NPCs
-- ---------------------------------------------------------------------------

-- The name the game shows for an NPC: from the server's NPC list when it differs
-- from the script name (_0q1 -> Sewer Entrance); unnamed points are ???.
local function npc_label(n, zone)
    n = n or '?'
    local shown = data and data.names and zone and data.names[tostring(zone) .. ':' .. n]
    if shown == '' then return 'Unmarked spot' end                -- an invisible trigger (no name in game)
    if shown then return shown end
    if n:match('^qm') or n:match('^_') then return '???' end   -- unnamed points like qm6, qm_maw
    return (n:gsub('_', ' '))
end
local function zone_label(z) return (data and data.zones[z]) or ('zone ' .. tostring(z)) end

local function join_or(list)
    if #list <= 1 then return list[1] or '' end
    return table.concat(list, ', ', 1, #list - 1) .. ' or ' .. list[#list]
end

-- What a trade asks for: all its items go in together ("A and B"); when the game takes other sets
-- instead, ng holds each set's size ("A and B, or C").
local function join_and(list)
    if #list <= 1 then return list[1] or '' end
    return table.concat(list, ', ', 1, #list - 1) .. ' and ' .. list[#list]
end
local function trade_list(need, ng, name)
    local sets, k = {}, 1
    for _, size in ipairs(ng or { #(need or {}) }) do
        local set = {}
        for i = k, k + size - 1 do if need[i] then set[#set + 1] = name(need[i]) end end
        k = k + size
        if #set > 0 then sets[#sets + 1] = join_and(set) end
    end
    return table.concat(sets, ', or ')
end
QL_TRADE_LIST = trade_list   -- (for the tests)

local function step_text(st)
    local names = {}
    for _, n in ipairs(st.n or {}) do names[#names + 1] = npc_label(n[2], n[1]) end
    local t
    if st.x then t = st.x                      -- hand-checked wording
    elseif st.k == 'talk' then t = 'Talk to ' .. join_or(names) .. (st.again and ' again' or '')
    elseif st.k == 'trade' then
        t = 'Trade ' .. trade_list(st.need, st.ng, item_name) .. ' to ' .. join_or(names)
    elseif st.k == 'kill' then t = 'Defeat ' .. join_or(names)
    elseif st.k == 'zone' then t = 'Enter ' .. zone_label(st.n[1] and st.n[1][1])
    else t = st.k end
    local get = {}
    for _, id in ipairs(st.gi or {}) do get[#get + 1] = item_name(id) end
    for _, id in ipairs(st.gk or {}) do get[#get + 1] = (data.kis[id] or ('key item #' .. id)) .. ' (key item)' end
    local tail = {}
    if #get > 0 then tail[#tail + 1] = 'get ' .. table.concat(get, ', ') end
    if st.b then tail[#tail + 1] = 'starts it' end
    if st.c then tail[#tail + 1] = 'finishes it' end
    if #tail > 0 then t = t .. '  ->  ' .. table.concat(tail, '; ') end
    return t
end

-- "Andecia  Southern San dOria (167, 45)  23y NE" for each NPC of a step.
-- Map grids, as the game's <pos> gives them: "(F-6)". The game's map table (FFXiMain.dll, as YunaUI and boussole
-- find it) holds every zone's maps - the scale and offset of each - so a place in any zone has its square: 15 a side,
-- A-O and 1-15, from map pixel 16. A zone with several maps (floors): the first whose map has the place on it.
local MAPT = { ptr = nil, zones = {} }
local function map_entries(zone)
    if MAPT.ptr == nil then
        MAPT.ptr = 0
        pcall(function()
            local at = ashita.memory.find('FFXiMain.dll', 0, '8A0D????????5333C05684C95774??8A5424188B7424148B7C2410B9', 0, 0)
            if at ~= nil and at ~= 0 then MAPT.ptr = ashita.memory.read_uint32(at + 0x1C) or 0 end
        end)
    end
    if MAPT.ptr == 0 then return nil end
    local got = MAPT.zones[zone]
    if got then return got end
    got = {}
    pcall(function()
        for i = 0, 1999 do
            local b = MAPT.ptr + i * 0x0E
            local z, dat = ashita.memory.read_uint16(b), ashita.memory.read_uint16(b + 8)
            if z == 0 and dat == 0 and i > 10 then break end
            if z == zone then
                local sv = ashita.memory.read_uint8(b + 5)
                got[#got + 1] = { floor = ashita.memory.read_uint8(b + 2), scale = (sv >= 0x80) and (sv - 0x100) or sv,
                                  ox = ashita.memory.read_int16(b + 0x0A), oy = ashita.memory.read_int16(b + 0x0C) }
            end
        end
    end)
    table.sort(got, function(a, b) return a.floor < b.floor end)
    MAPT.zones[zone] = got
    return got
end
-- x: east, z: north (the server's x and z)
local function grid_of(zone, x, z)
    if not (zone and x and z) then return nil end
    local es = map_entries(zone)
    if not es then return nil end
    for _, e in ipairs(es) do
        local k = math.abs(e.scale) / 2560 * 512
        local mx, my = x * k - e.ox, -z * k - e.oy
        local c, r = math.floor((mx - 16) / 32), math.floor((my - 16) / 32) + 1
        if c >= 0 and c <= 14 and r >= 1 and r <= 15 then return string.format('(%s-%d)', string.char(65 + c), r) end
    end
    return nil
end

local function npc_lines(npcs, my_zone, px, pz)
    local out = {}
    for _, n in ipairs(npcs or {}) do
        if n[2] then
            local pos = data.npcs[n[1] .. ':' .. n[2]]
            local line = string.format('%s - %s', npc_label(n[2], n[1]), zone_label(n[1]))
            local here = nil
            if pos then
                line = line .. ' ' .. (grid_of(n[1], pos[1], pos[3]) or coords(pos[1], pos[3], pos[2]))   -- (its map grid; the data is the server's !pos x, height, z)
                if my_zone == n[1] and px and pz then
                    local dist, dir = log.bearing(px, pz, pos[1], pos[3])
                    here = dir == 'here' and 'here' or string.format('%dy %s', math.floor(dist + 0.5), dir)
                end
            end
            out[#out + 1] = { line, here, n[1], pos }
        end
    end
    return out
end

-- ---------------------------------------------------------------------------
-- Window
-- ---------------------------------------------------------------------------

local function rgb(hex, a)
    return { tonumber(hex:sub(1, 2), 16) / 255, tonumber(hex:sub(3, 4), 16) / 255, tonumber(hex:sub(5, 6), 16) / 255, a or 1 }
end
local function alpha(c, a) return { c[1], c[2], c[3], a } end

-- FFXI Questlog's look, after Final Fantasy XV's menus: a see-through
-- blue-black glass panel (its opacity is a setting) with white hairlines that
-- fade out at their ends; a sidebar on the left with the QUESTLOG wordmark in
-- spaced white capitals, the filters (the open one on a bright light band in
-- dark ink with a chevron), search and the list; the steps on the right.
-- Pale FFXV blue = "you are here", periwinkle = tips and step numbers, soft
-- gold = rewards. Done steps fade to grey and get struck out. Folded, the
-- window becomes FFXI's home point crystal.
-- Aether's look (Guabancex's HUD): ink panels with one corner cut, neutral text in three steps, and one cyan accent.
local INK, INK2      = rgb('0c0f12', 0.92), rgb('14181d')
local BONE, CHALK    = rgb('e9edf0'), rgb('c4ccd2')
local ASH, SOOT      = rgb('9aa4ad'), rgb('667079')
local ACID           = rgb('4fd8ec')                    -- cyan: you are here, the current step
local ON_ACID        = rgb('0c0f12')
local VERM           = ACID                             -- step numbers and tips: the accent too
local SUN, AMBER     = rgb('2a3138'), rgb('e8bf4f')     -- a quiet steel, Aether's TP gold (rewards)
local RED            = rgb('ff5f56')                    -- Aether's "bad": close
local LINE           = rgb('ffffff')                    -- hairlines: white, kept faint
local DEEP           = rgb('0c0f12')
local RULE           = { 1, 1, 1, 0.08 }
local VIOLET         = SUN
local NEON, NEON2    = SUN, ACID
local FRAME, FRAME_HI = rgb('1b2026'), rgb('252c33')
local DARK, DARK_HI, DARK_ACT = { 0.047, 0.059, 0.071, 1 }, { 0.078, 0.094, 0.114, 1 }, { 0.145, 0.169, 0.196, 1 }

-- ImGui reads text as a printf format: never hand it a '%'.
local function clean(t) return (tostring(t or ''):gsub('%%', '')) end
local function track(t) return (clean(t):upper():gsub('(.)', '%1 '):gsub(' $', '')) end  -- letter-spaced caps
local function ctext(c, t) imgui.TextColored(c, clean(t)) end
local show_tip   -- the styled tooltip, defined with the other widgets below
local function tip(t) if imgui.IsItemHovered() then show_tip(clean(t)) end end

-- Everything pushed is counted, so an error mid-draw can't unbalance ImGui.
local pushed_colors, child_depth = 0, 0
local group_open = false
local function push_colors(list)
    local n = 0
    for _, c in ipairs(list) do
        local id = _G[c[1]]
        if type(id) == 'number' and pcall(imgui.PushStyleColor, id, c[2]) then n = n + 1 end
    end
    pushed_colors = pushed_colors + n
    return n
end
local function pop_colors(n)
    if n > 0 then imgui.PopStyleColor(n) end
    pushed_colors = pushed_colors - n
end

local function style_colors() return {
    { 'ImGuiCol_WindowBg', alpha(INK, 0.92) }, { 'ImGuiCol_ChildBg', alpha(INK, 0) }, { 'ImGuiCol_PopupBg', alpha(INK2, 0.97) },
    { 'ImGuiCol_Border', alpha(BONE, 0.20) }, { 'ImGuiCol_Text', BONE }, { 'ImGuiCol_TextDisabled', ASH },
    { 'ImGuiCol_FrameBg', alpha(BONE, 0.035) }, { 'ImGuiCol_FrameBgHovered', alpha(BONE, 0.07) }, { 'ImGuiCol_FrameBgActive', alpha(ACID, 0.14) },
    { 'ImGuiCol_Button', alpha(BONE, 0.02) }, { 'ImGuiCol_ButtonHovered', alpha(BONE, 0.10) }, { 'ImGuiCol_ButtonActive', alpha(ACID, 0.25) },
    { 'ImGuiCol_Header', alpha(ACID, 0.14) }, { 'ImGuiCol_HeaderHovered', alpha(BONE, 0.08) }, { 'ImGuiCol_HeaderActive', alpha(ACID, 0.22) },
    { 'ImGuiCol_CheckMark', ACID }, { 'ImGuiCol_Separator', alpha(BONE, 0.07) },
    { 'ImGuiCol_PlotHistogram', ACID }, { 'ImGuiCol_ScrollbarBg', alpha(INK, 0) },
    { 'ImGuiCol_ScrollbarGrab', alpha(BONE, 0.22) }, { 'ImGuiCol_ScrollbarGrabHovered', alpha(BONE, 0.40) },
    { 'ImGuiCol_ScrollbarGrabActive', ACID }, { 'ImGuiCol_TextSelectedBg', alpha(ACID, 0.30) },
    { 'ImGuiCol_ResizeGrip', alpha(BONE, 0.10) }, { 'ImGuiCol_ResizeGripHovered', alpha(ACID, 0.6) }, { 'ImGuiCol_ResizeGripActive', ACID },
} end
local STYLE_COLORS = style_colors()
local STYLE_VARS = {
    { 'ImGuiStyleVar_WindowRounding', 0 }, { 'ImGuiStyleVar_ChildRounding', 0 }, { 'ImGuiStyleVar_FrameRounding', 0 },
    { 'ImGuiStyleVar_GrabRounding', 0 }, { 'ImGuiStyleVar_ScrollbarRounding', 0 }, { 'ImGuiStyleVar_PopupRounding', 0 },
    { 'ImGuiStyleVar_WindowBorderSize', 0 }, { 'ImGuiStyleVar_ChildBorderSize', 0 }, { 'ImGuiStyleVar_FrameBorderSize', 1 },
    { 'ImGuiStyleVar_WindowPadding', { 16, 14 } }, { 'ImGuiStyleVar_FramePadding', { 8, 3 } },
    { 'ImGuiStyleVar_ItemSpacing', { 8, 6 } }, { 'ImGuiStyleVar_ScrollbarSize', 6 },
}
local function push_style()
    local nc, nv = 0, 0
    -- The panel's see-through-ness comes from the opacity setting (30-100).
    for _, c in ipairs(STYLE_COLORS) do
        local id = _G[c[1]]
        local col = c[2]
        if c[1] == 'ImGuiCol_WindowBg' then col = { 0, 0, 0, 0 } end   -- the glass is drawn by hand (glass())
        if type(id) == 'number' and pcall(imgui.PushStyleColor, id, col) then nc = nc + 1 end
    end
    for _, v in ipairs(STYLE_VARS) do
        local id = _G[v[1]]
        local val = v[2]
        if v[1] == 'ImGuiStyleVar_WindowPadding' and S and S.mini then val = { 2, 2 } end  -- the folded crystal
        if type(id) == 'number' and pcall(imgui.PushStyleVar, id, val) then nv = nv + 1 end
    end
    return nc, nv
end
local function pop_style(nc, nv)
    if nv > 0 then imgui.PopStyleVar(nv) end
    if nc > 0 then imgui.PopStyleColor(nc) end
end

-- Drawing straight onto the window: optional, skipped if this build differs.
local function xy(a, b) if type(a) == 'table' then return a.x or a[1], a.y or a[2] end return a, b end
local function decorate(fn) pcall(fn, imgui.GetWindowDrawList()) end
local function col32(c) return imgui.GetColorU32(c) end
local RALL = ImDrawFlags_RoundCornersAll or ImDrawCornerFlags_All or 15   -- round all four corners
local function num(v, d) return type(v) == 'number' and v or d end
local function cursor() local x, y = xy(imgui.GetCursorScreenPos()) return num(x, 0), num(y, 0) end
local function text_w(t) return num((xy(imgui.CalcTextSize(t))), 7 * #t) end
local function line_h() return num(imgui.GetTextLineHeight(), 13) end
local function avail_w() local w = imgui.GetContentRegionAvail() return num(type(w) == 'table' and (w.x or w[1]) or w, 300) end
local function mix(a, b, t)
    return { a[1] + (b[1] - a[1]) * t, a[2] + (b[2] - a[2]) * t, a[3] + (b[3] - a[3]) * t, (a[4] or 1) + ((b[4] or 1) - (a[4] or 1)) * t }
end
-- A left-to-right gradient bar (one colour if this build can't do gradients).
local function gradient(dl, x1, y1, x2, y2, a, b)
    if not pcall(function() dl:AddRectFilledMultiColor({ x1, y1 }, { x2, y2 }, col32(a), col32(b), col32(b), col32(a)) end) then
        dl:AddRectFilled({ x1, y1 }, { x2, y2 }, col32(a))
    end
end
-- YunaUI's mark: a small diamond outline, filled inside when it's lit.
local function diamond(dl, cx, cy, r, lit, a)
    a = a or 1
    local c = col32(lit and alpha(NEON2, a) or { 0.62, 0.60, 0.70, a })
    dl:AddLine({ cx, cy - r }, { cx + r, cy }, c, 1.4)
    dl:AddLine({ cx + r, cy }, { cx, cy + r }, c, 1.4)
    dl:AddLine({ cx, cy + r }, { cx - r, cy }, c, 1.4)
    dl:AddLine({ cx - r, cy }, { cx, cy - r }, c, 1.4)
    local q = r * 0.45
    local f = col32(lit and { 0.95, 0.85, 1, a } or { 0.55, 0.52, 0.65, a * 0.8 })
    pcall(function()
        dl:AddTriangleFilled({ cx, cy - q }, { cx + q, cy }, { cx, cy + q }, f)
        dl:AddTriangleFilled({ cx, cy + q }, { cx - q, cy }, { cx, cy - q }, f)
    end)
end

-- The cinematic look's pieces, in Questlog's colours.
-- A hairline that fades out at both ends.
local function fade_rule(dl, x1, x2, y, c, a)
    local mid = (x1 + x2) / 2
    local c0, c1 = col32(alpha(c, 0)), col32(alpha(c, a or 0.35))
    if not pcall(function()
        dl:AddRectFilledMultiColor({ x1, y }, { mid, y + 1 }, c0, c1, c1, c0)
        dl:AddRectFilledMultiColor({ mid, y }, { x2, y + 1 }, c1, c0, c0, c1)
    end) then dl:AddLine({ x1, y }, { x2, y }, c1, 1) end
end
-- A light band, bright on the left and fading right (the selected row).
local function band(dl, x1, y1, x2, y2, c, a)
    gradient(dl, x1, y1, x2, y2, alpha(c, a or 0.6), alpha(c, 0))
end
local function chevron(dl, x, y, s, c)
    dl:AddTriangleFilled({ x, y - s }, { x + s, y }, { x, y + s }, col32(c))
end
-- The glass: blue-black shading to near black, see-through by the opacity
-- setting, with white hairlines along the top and bottom and a cool sheen.
local function glass()
    decorate(function(dl)
        local wx, wy = xy(imgui.GetWindowPos())
        local ww, wh = xy(imgui.GetWindowSize())
        if type(wx) ~= 'number' or type(ww) ~= 'number' then return end
        local o = math.max(30, math.min(100, (S and S.opacity) or 82)) / 100
        local k = S and S.mini and 0 or 14                              -- (the cut corner; none on the folded crystal)
        local u = col32(rgb('0c0f12', o))
        dl:AddRectFilled({ wx, wy + k }, { wx + ww, wy + wh }, u)
        dl:AddRectFilled({ wx + k, wy }, { wx + ww, wy + k }, u)
        if k > 0 then
            dl:AddTriangleFilled({ wx, wy + k }, { wx + k, wy }, { wx + k, wy + k }, u)
            local e = col32({ 1, 1, 1, 0.06 })                           -- a faint edge all round
            dl:AddLine({ wx + k, wy + 0.5 }, { wx + ww - 0.5, wy + 0.5 }, e, 1)
            dl:AddLine({ wx + ww - 0.5, wy }, { wx + ww - 0.5, wy + wh - 0.5 }, e, 1)
            dl:AddLine({ wx + ww - 0.5, wy + wh - 0.5 }, { wx + 0.5, wy + wh - 0.5 }, e, 1)
            dl:AddLine({ wx + 0.5, wy + wh - 0.5 }, { wx + 0.5, wy + k }, e, 1)
            dl:AddLine({ wx + 0.5, wy + k }, { wx + k, wy + 0.5 }, col32(ACID), 1.4)   -- the cut, lit in the day's colour
            gradient(dl, wx + k, wy, wx + k + 120, wy + 1, ACID, alpha(ACID, 0))
        end
    end)
end

-- Tooltips: a dark glass card, a faint white edge and a pale blue line along
-- the top that fades out; the first line bright, the rest softer.
show_tip = function(t)
    if imgui.BeginTooltip == nil then return imgui.SetTooltip(t) end
    local nv, nc = 0, 0
    for _, v in ipairs({ { 'ImGuiStyleVar_WindowRounding', 0 }, { 'ImGuiStyleVar_WindowPadding', { 9, 5 } },
                         { 'ImGuiStyleVar_WindowBorderSize', 1 } }) do
        local id = _G[v[1]]
        if type(id) == 'number' and pcall(imgui.PushStyleVar, id, v[2]) then nv = nv + 1 end
    end
    for _, c in ipairs({ { 'ImGuiCol_PopupBg', rgb('14181d', 0.98) }, { 'ImGuiCol_Border', { 1, 1, 1, 0.10 } } }) do
        local id = _G[c[1]]
        if type(id) == 'number' and pcall(imgui.PushStyleColor, id, c[2]) then nc = nc + 1 end
    end
    if imgui.BeginTooltip() == false then
        imgui.SetTooltip(t)
    else
        pcall(function()
            local first = true
            for l in (t .. '\n'):gmatch('([^\n]*)\n') do
                if first then imgui.Text(l) else imgui.TextColored(CHALK, l) end
                first = false
            end
            decorate(function(dl)
                local wx, wy = xy(imgui.GetWindowPos())
                local ww = xy(imgui.GetWindowSize())
                gradient(dl, wx + 8, wy + 1, wx + ww - 8, wy + 2, ACID, alpha(ACID, 0))
            end)
        end)
        imgui.EndTooltip()
    end
    if nc > 0 then imgui.PopStyleColor(nc) end
    if nv > 0 then imgui.PopStyleVar(nv) end
end

-- A line through the last item drawn: the strike-out.
local function strike(color)
    decorate(function(dl)
        local x1, y1 = xy(imgui.GetItemRectMin())
        local x2, y2 = xy(imgui.GetItemRectMax())
        local y = math.floor((y1 + y2) / 2) + 0.5
        dl:AddLine({ x1, y }, { x2, y }, col32(color), 1.0)
    end)
end

-- A round status mark: pale blue dot with a halo = in progress, open ring = done, dash = not started.
local function mark(status)
    decorate(function(dl)
        local x, y = xy(imgui.GetCursorScreenPos())
        local cy = y + imgui.GetTextLineHeight() / 2 + 1
        if status == 'active' then
            dl:AddCircleFilled({ x + 5, cy }, 6, col32(alpha(ACID, 0.22)), 16)
            dl:AddCircleFilled({ x + 5, cy }, 3.5, col32(ACID), 16)
        elseif status == 'done' then
            dl:AddCircle({ x + 5, cy }, 3.5, col32(CHALK), 16, 1)
        else
            dl:AddLine({ x + 2, cy }, { x + 8, cy }, col32(SOOT), 1)
        end
    end)
    imgui.Dummy({ 12, 1 })
    imgui.SameLine(0, 2)
end

-- A sidebar row (the filters): the open one on FFXV's light band (bright on the
-- left, fading right) in dark ink with a chevron; a hovered one gets a faint band.
local NAV_H = 26
local function nav_row(label, name, count, active)
    local x, y = cursor()
    local w = avail_w()
    local clicked = imgui.InvisibleButton(label, { w, NAV_H })
    local hov = imgui.IsItemHovered() == true
    decorate(function(dl)
        if active then
            band(dl, x, y + 1, x + w, y + NAV_H - 1, BONE, 0.92)
            chevron(dl, x + 6, y + NAV_H / 2, 4, DEEP)
        elseif hov then
            band(dl, x, y + 1, x + w, y + NAV_H - 1, BONE, 0.08)
        end
        local ty = y + (NAV_H - line_h()) / 2
        dl:AddText({ x + 18, ty }, col32(active and DEEP or (hov and BONE or CHALK)), track(name))
        local c = string.format('%d', count)
        dl:AddText({ x + w - 10 - text_w(c), ty }, col32(active and BONE or SOOT), c)
        if not active then dl:AddLine({ x + 12, y + NAV_H }, { x + w, y + NAV_H }, col32(alpha(BONE, 0.05)), 1) end
    end)
    return clicked
end

-- An on/off toggle in the cinematic style: ON / OFF in spaced capitals and a
-- square check box at the right; the box fills pale blue when on.
local function switch(id, on)
    local x, y = cursor()
    local w, h = 40, 20
    local clicked = imgui.InvisibleButton(id, { w, h })
    local hov = imgui.IsItemHovered() == true
    decorate(function(dl)
        local bx, by, b = x + w - 15, y + (h - 14) / 2, 14
        dl:AddRect({ bx, by }, { bx + b, by + b }, col32(on and ACID or { 1, 1, 1, hov and 0.85 or 0.5 }), 0, RALL, 1)
        if on then
            dl:AddRectFilled({ bx + 3, by + 3 }, { bx + b - 3, by + b - 3 }, col32(ACID))
            dl:AddRect({ bx - 2, by - 2 }, { bx + b + 2, by + b + 2 }, col32(alpha(ACID, 0.25)), 0, RALL, 2)
        end
    end)
    return clicked
end

-- Lock style: the window and the folded crystal stay put (no dragging) until unlocked.
local function set_locked(on)
    S.locked = on and true or false
    settings.save()
    say('%s', S.locked and 'Locked in place (/ql lock to unlock).' or 'Unlocked: drag to move.')
end
local function lock_row()
    local x0, w = num(imgui.GetCursorPosX(), 0), avail_w()
    imgui.AlignTextToFramePadding()
    ctext(S.locked and ACID or SOOT, track(S.locked and 'Locked' or 'Lock'))
    tip(S.locked and 'Locked in place. Click the switch to move it again.' or 'Lock the window and the crystal in place.')
    imgui.SameLine(math.max(num(imgui.GetCursorPosX(), 0) + 8, x0 + w - 40))
    if switch('##ql_lock', S.locked) then set_locked(not S.locked) end
    tip(S.locked and 'Locked in place. Click to unlock.' or 'Lock the window and the crystal in place.')
end

-- A small round icon button (- and x in the corner).
local function round_button(label, glyph, danger)
    local x, y = cursor()
    local s = 22
    local clicked = imgui.InvisibleButton(label, { s, s })
    local hov = imgui.IsItemHovered() == true
    decorate(function(dl)
        local cx, cy, r = x + s / 2, y + s / 2, s * 0.2
        if hov then
            dl:AddRectFilled({ x, y }, { x + s, y + s }, col32(danger and alpha(RED, 0.35) or alpha(ACID, 0.16)))
            dl:AddRect({ x, y }, { x + s, y + s }, col32({ 1, 1, 1, 0.45 }), 0, RALL, 1)
        end
        local c = col32(hov and BONE or alpha(CHALK, 0.85))
        r = s * 0.22
        if glyph == 'x' then
            dl:AddLine({ cx - r, cy - r }, { cx + r, cy + r }, c, 1.6)
            dl:AddLine({ cx - r, cy + r }, { cx + r, cy - r }, c, 1.6)
        else
            dl:AddLine({ cx - r, cy }, { cx + r, cy }, c, 1.6)
        end
    end)
    return clicked
end

-- A square key-cap button: the panel's dark colour inside, a pale blue edge
-- (primary) or a quiet grey one, its name in spaced capitals.
local function pill(label, primary)
    local name = track(label:gsub('##.*$', ''))
    local x, y = cursor()
    local bw, bh = text_w(name) + 26, math.floor(line_h() + 10)
    local clicked = imgui.InvisibleButton(label, { bw, bh })
    local hov, act = imgui.IsItemHovered() == true, imgui.IsItemActive() == true
    decorate(function(dl)
        dl:AddRectFilled({ x, y }, { x + bw, y + bh }, col32({ 0, 0, 0, 0.25 }))
        if hov or act then band(dl, x, y, x + bw, y + bh, BONE, act and 0.30 or 0.14) end
        dl:AddRect({ x, y }, { x + bw, y + bh }, col32(primary and alpha(NEON2, hov and 1 or 0.8) or { 1, 1, 1, hov and 0.55 or 0.28 }), 0, RALL, 1)
        dl:AddText({ x + (bw - text_w(name)) / 2, y + (bh - line_h()) / 2 }, col32({ 0.93, 0.91, 0.98, 1 }), name)
    end)
    return clicked
end

-- A rounded tag that does nothing: inverted (filled) or quiet.
local function chip(label, color, id, filled)
    local bg = filled and color or alpha(color, 0.12)
    local n = push_colors({ { 'ImGuiCol_Button', bg }, { 'ImGuiCol_ButtonHovered', bg },
                            { 'ImGuiCol_ButtonActive', bg }, { 'ImGuiCol_Text', filled and ON_ACID or color } })
    local rv = (ImGuiStyleVar_FrameRounding and pcall(imgui.PushStyleVar, ImGuiStyleVar_FrameRounding, 0)) and 1 or 0
    imgui.SmallButton(clean(label) .. '##chip_' .. id)
    if rv > 0 then imgui.PopStyleVar(1) end
    pop_colors(n)
end

-- Section heading: the name in spaced capitals, a faint line on to the edge.
local function heading(label, index)
    local x, y = cursor()
    local w = avail_w()
    if index then ctext(SOOT, string.format('%02d', index)) imgui.SameLine(0, 8) end
    local lx = cursor()
    ctext({ 0.93, 0.90, 1.00, 1 }, track(label))
    decorate(function(dl)
        local ex = lx + text_w(track(label)) + 14
        local cy = y + line_h() / 2
        if ex < x + w then fade_rule(dl, ex, x + w + 40, cy, LINE, 0.3) end
    end)
end

-- A full-width rule: a faint hairline, or a steel-to-pale-blue one (weight 2+).
local function rule(weight, color)
    decorate(function(dl)
        local x, y = cursor()
        local w = avail_w()
        if (weight or 1) >= 2 then
            gradient(dl, x, y, x + w, y + weight, NEON, alpha(NEON2, 0.15))
        else
            fade_rule(dl, x, x + w, y, color or BONE, color and (color[4] or 1) or 0.16)
        end
    end)
    imgui.Dummy({ 1, (weight or 1) + 2 })
end

-- One segment per step: periwinkle-to-steel = done, a bright pale blue one with
-- a glow = current, a faint one = still to do.
local function step_bar(done, current, n)
    decorate(function(dl)
        local x, y = cursor()
        local w = avail_w()
        local gap = n > 24 and 2 or 4
        local bw = math.max(2, (w - gap * (n - 1)) / n)
        local r = 0
        for i = 1, n do
            local x1 = x + (i - 1) * (bw + gap)
            if done[i] then
                dl:AddRectFilled({ x1, y }, { x1 + bw, y + 6 }, col32(mix(VERM, VIOLET, (i - 1) / math.max(1, n - 1))), r)
            elseif i == current then
                dl:AddRectFilled({ x1 - 1, y - 2 }, { x1 + bw + 1, y + 8 }, col32(alpha(ACID, 0.25)), r + 1)
                dl:AddRectFilled({ x1, y }, { x1 + bw, y + 6 }, col32(ACID), r)
            else
                dl:AddRectFilled({ x1, y }, { x1 + bw, y + 6 }, col32(alpha(BONE, 0.08)), r)
            end
        end
    end)
    imgui.Dummy({ 1, 10 })
end

local function scaled(scale, color, t)
    pcall(imgui.SetWindowFontScale, scale)
    ctext(color, t)
    pcall(imgui.SetWindowFontScale, 1.0)
end

local function begin_child(id, w, h)
    local ok = pcall(imgui.BeginChild, id, { w, h }, false)
    if not ok then ok = pcall(imgui.BeginChild, id, { w, h }, 0) end
    if ok then child_depth = child_depth + 1 end
    return ok
end
local function end_child()
    if child_depth > 0 then imgui.EndChild() child_depth = child_depth - 1 end
end

local function matches(e)
    local q = (ui.search[1] or ''):lower()
    if q == '' then return true end
    return (e.t or ''):lower():find(q, 1, true) ~= nil or (e.s or ''):lower():find(q, 1, true) ~= nil
end

-- Quests and missions with no step list (x=true) are listed like the rest;
-- /ql unscripted hides them (ones you've started or finished always show).
local function playable(e, status)
    return not e.x or S.unscripted ~= false or status == 'active' or status == 'done'
end

-- Completed quests and missions are left off the list (the header still counts them).
local function shown(status)
    if status == 'done' then return false end
    if S.filter == 'all' then return true end
    return status == 'active'
end


-- Totals for the header and the filter pills.
local counts, counts_at = { active = 0, done = 0, all = 0 }, -10
local function refresh_counts(now)
    if now - counts_at < 1 then return end
    counts_at = now
    local c = { active = 0, done = 0, all = 0 }
    for _, g in ipairs({ { 'm', data.missions }, { 'q', data.quests } }) do
        for _, e in ipairs(g[2]) do
            local st = status_of(g[1], e)
            if playable(e, st) and st ~= 'done' then c.all = c.all + 1 end
            if st == 'active' then c.active = c.active + 1 elseif st == 'done' then c.done = c.done + 1 end
        end
    end
    counts = c
end

-- What the slim bar shows: the quest you picked, or else the first one in progress.
local function focus()
    if ui.sel_entry then return ui.sel_kind, ui.sel_entry end
    for _, g in ipairs({ { 'm', data.missions }, { 'q', data.quests } }) do
        for _, e in ipairs(g[2]) do
            if status_of(g[1], e) == 'active' then return g[1], e end
        end
    end
    return nil, nil
end

local restore_size = false
local function minimize()
    pcall(function()
        local w, h = xy(imgui.GetWindowSize())
        if w and h and not S.mini then S.full_size = T{ math.floor(w), math.floor(h) } end
    end)
    S.mini = true
    settings.save()
end
local function maximize()
    S.mini, restore_size = false, true
    settings.save()
end

-- FFXI Questlog's folded icon: the FFXI home point crystal, drawn with shapes
-- (no image files needed). A tall, slender shard of pale ice-blue light -- a
-- long point above, a short one below -- turning slowly and floating over a
-- glowing rune circle, with blue-violet flames licking up round its foot and a
-- glint now and then. dim = grey and still.
local function crystal(dl, cx, cy, s, dim)
    local function c(r, g, b, a)
        r, g, b = math.min(1, r), math.min(1, g), math.min(1, b)
        if dim then local v = (r + g + b) / 3 return col32({ v, v, v, a or 1 }) end
        return col32({ r, g, b, a or 1 })
    end
    local t = dim and 0 or os.clock()
    local floor_y = cy + s * 0.86                                    -- the rune circle on the ground
    local fy = dim and 0 or math.sin(t * 1.5) * s * 0.04            -- the crystal floats
    local top, bot = cy - s * 1.00 + fy, cy + s * 0.70 + fy          -- a long point up, a shorter one down
    local gy, rx, rz = cy + s * 0.02 + fy, s * 0.19, s * 0.06        -- its widest ring, a little below the middle
    local turn = t * (2 * math.pi / 6)                              -- (one full turn every 6 seconds)
    local breathe = 0.5 + 0.5 * math.sin(t * 1.7)
    -- the cold glow round it
    for i = 6, 1, -1 do
        dl:AddCircleFilled({ cx, cy - s * 0.15 }, s * (0.22 + 0.11 * i), c(0.30, 0.55, 1.00, 0.020 + 0.016 * breathe), 32)
    end
    -- the rune circle: a glowing ring seen from the side, with ticks round it
    local erx, ery = s * 0.62, s * 0.13
    local function ring(scale, col, w)
        local n = 28
        for i = 0, n - 1 do
            local a1, a2 = i * 2 * math.pi / n, (i + 1) * 2 * math.pi / n
            dl:AddLine({ cx + math.cos(a1) * erx * scale, floor_y + math.sin(a1) * ery * scale },
                       { cx + math.cos(a2) * erx * scale, floor_y + math.sin(a2) * ery * scale }, col, w)
        end
    end
    ring(1.00, c(0.45, 0.70, 1.00, 0.45 + 0.25 * breathe), 1.2)
    ring(0.72, c(0.55, 0.80, 1.00, 0.30 + 0.20 * breathe), 1)
    for i = 0, 11 do
        local a = i * math.pi / 6 + t * 0.2
        local x1, y1 = cx + math.cos(a) * erx * 0.74, floor_y + math.sin(a) * ery * 0.74
        local x2, y2 = cx + math.cos(a) * erx * 0.98, floor_y + math.sin(a) * ery * 0.98
        dl:AddLine({ x1, y1 }, { x2, y2 }, c(0.60, 0.85, 1.00, 0.35), 1)
    end
    -- the flames: blue-violet tongues round the foot, flickering; the ones
    -- behind the crystal are drawn first, the ones in front last
    local flames = {}
    for k = 0, 10 do
        local a = k * 2 * math.pi / 11 + 0.3
        local fl = dim and 0.5 or (0.5 + 0.5 * math.sin(t * 5.0 + k * 1.9)) * (0.65 + 0.35 * math.sin(t * 2.7 + k))
        flames[#flames + 1] = { z = math.sin(a), x = cx + math.cos(a) * erx * 0.55, y = floor_y + math.sin(a) * ery * 0.55,
                                h = s * (0.55 + 0.50 * fl), w = s * (0.10 + 0.03 * (k % 3)),
                                sway = dim and 0 or math.sin(t * 3.0 + k * 2.3) * s * 0.08 }
    end
    -- one tongue: a soft outer flame and a brighter core, bulging a little low down
    local function flame(f)
        local tip = { f.x + f.sway, f.y - f.h }
        local my = f.y - f.h * 0.35
        dl:AddQuadFilled({ f.x - f.w, f.y }, { f.x - f.w * 1.1 + f.sway * 0.3, my }, tip, { f.x + f.w * 1.1 + f.sway * 0.3, my }, c(0.40, 0.35, 1.00, 0.16))
        dl:AddTriangleFilled({ f.x + f.w * 1.1 + f.sway * 0.3, my }, { f.x + f.w, f.y }, { f.x - f.w, f.y }, c(0.40, 0.35, 1.00, 0.16))
        local w2 = f.w * 0.5
        dl:AddQuadFilled({ f.x - w2, f.y }, { f.x - w2 * 1.2 + f.sway * 0.2, my }, { f.x + f.sway * 0.75, f.y - f.h * 0.72 }, { f.x + w2 * 1.2 + f.sway * 0.2, my }, c(0.50, 0.65, 1.00, 0.30))
        dl:AddTriangleFilled({ f.x + w2 * 1.2 + f.sway * 0.2, my }, { f.x + w2, f.y }, { f.x - w2, f.y }, c(0.50, 0.65, 1.00, 0.30))
    end
    -- the light pooling on the ground under it
    for i = 3, 1, -1 do
        local k = i / 3
        local n = 20
        for j = 0, n - 1 do
            local a1, a2 = j * 2 * math.pi / n, (j + 1) * 2 * math.pi / n
            dl:AddTriangleFilled({ cx, floor_y }, { cx + math.cos(a1) * erx * 0.8 * k, floor_y + math.sin(a1) * ery * 0.8 * k },
                { cx + math.cos(a2) * erx * 0.8 * k, floor_y + math.sin(a2) * ery * 0.8 * k }, c(0.45, 0.60, 1.00, 0.10 + 0.05 * breathe))
        end
    end
    for _, f in ipairs(flames) do if f.z < 0 then flame(f) end end
    -- the shard as a real 3D model: a six-sided prism with a long point above and a short one below (sides of uneven
    -- width), turned about its upright axis, tipped a little toward you, lit from the upper left and drawn back to front
    local R = { [0] = 1.00, 0.80, 0.94, 0.72, 0.97, 0.84 }
    local V = { { 0, 1.00, 0 }, { 0, -0.74, 0 } }                     -- [1] top point, [2] bottom point
    for i = 0, 5 do
        local a = i * math.pi / 3
        V[3 + i] = { math.cos(a) * 0.26 * R[i], 0.34, math.sin(a) * 0.26 * R[i] }       -- upper ring
        V[9 + i] = { math.cos(a) * 0.23 * R[i], -0.22, math.sin(a) * 0.23 * R[i] }      -- lower ring
    end
    local cy_, sy_ = math.cos(turn), math.sin(turn)
    local tilt = 0.22
    local ct, st = math.cos(tilt), math.sin(tilt)
    local W, S2 = {}, {}
    for k, v in ipairs(V) do
        local x, y, z = v[1] * cy_ + v[3] * sy_, v[2], -v[1] * sy_ + v[3] * cy_        -- turn about the upright axis
        y, z = y * ct - z * st, y * st + z * ct                                          -- tip toward you
        W[k] = { x, y, z }
        local pk = 1 / (1 - z * 0.25)                                                    -- a touch of perspective
        S2[k] = { cx + x * s * pk, cy - s * 0.15 + fy - y * s * pk }
    end
    local L = { -0.55, 0.62, 0.56 }                                   -- the light (normalised below)
    local ll = math.sqrt(L[1] ^ 2 + L[2] ^ 2 + L[3] ^ 2)
    L = { L[1] / ll, L[2] / ll, L[3] / ll }
    local tris = {}
    local function tri(a, b, c_)
        local A, B, C = W[a], W[b], W[c_]
        local ux, uy, uz = B[1] - A[1], B[2] - A[2], B[3] - A[3]
        local vx, vy, vz = C[1] - A[1], C[2] - A[2], C[3] - A[3]
        local nx, ny, nz = uy * vz - uz * vy, uz * vx - ux * vz, ux * vy - uy * vx
        local nl = math.sqrt(nx * nx + ny * ny + nz * nz) + 1e-9
        nx, ny, nz = nx / nl, ny / nl, nz / nl
        local mx, mz = (A[1] + B[1] + C[1]) / 3, (A[3] + B[3] + C[3]) / 3
        if nx * mx + nz * mz < 0 then nx, ny, nz = -nx, -ny, -nz end                     -- (normals point outward)
        tris[#tris + 1] = { a, b, c_, z = (A[3] + B[3] + C[3]) / 3, front = nz > 0,
                            lit = math.max(0, nx * L[1] + ny * L[2] + nz * L[3]) }
    end
    for i = 0, 5 do
        local j = (i + 1) % 6
        tri(1, 3 + i, 3 + j)                                          -- the long point
        tri(3 + i, 9 + i, 9 + j) tri(3 + i, 9 + j, 3 + j)               -- the sides
        tri(2, 9 + j, 9 + i)                                          -- the short point
    end
    table.sort(tris, function(a, b) return a.z < b.z end)
    for _, f in ipairs(tris) do
        local v = 0.30 + 0.75 * f.lit
        local a = f.front and 0.88 or 0.55                            -- see-through: the far side shows, dimmer
        dl:AddTriangleFilled(S2[f[1]], S2[f[2]], S2[f[3]], c(0.20 + 0.70 * v * v, 0.50 + 0.48 * v, 0.92 + 0.08 * v, a))
        if f.front then
            local e = c(0.85, 0.95, 1.00, 0.30 + 0.45 * f.lit)
            dl:AddLine(S2[f[1]], S2[f[2]], e, 1) dl:AddLine(S2[f[2]], S2[f[3]], e, 1)
            if f.lit > 0.82 then dl:AddTriangleFilled(S2[f[1]], S2[f[2]], S2[f[3]], c(1, 1, 1, 0.25 * (f.lit - 0.82) / 0.18)) end   -- a facet catching the light
        end
    end
    top, bot, gy = S2[1][2], S2[2][2], (S2[3][2] + S2[9][2]) / 2
    local tx = S2[1][1]
    -- the light inside it: a pale core down the middle
    dl:AddQuadFilled({ tx, top + s * 0.20 }, { cx + s * 0.05, gy }, { S2[2][1], bot - s * 0.12 }, { cx - s * 0.05, gy }, c(0.92, 0.98, 1.00, 0.35 + 0.20 * breathe))
    for _, f in ipairs(flames) do if f.z >= 0 then flame(f) end end
    if dim then return end
    -- a glint at the top point, now and then
    local ph = (t % 3.2) / 3.2
    if ph < 0.22 then
        local q = math.sin(math.pi * ph / 0.22)
        local x, y = tx, top + s * 0.05
        dl:AddQuadFilled({ x - s * 0.36 * q, y }, { x, y - s * 0.04 * q - 0.5 }, { x + s * 0.36 * q, y }, { x, y + s * 0.04 * q + 0.5 }, c(1, 1, 1, 0.95 * q))
        dl:AddQuadFilled({ x, y - s * 0.36 * q }, { x + s * 0.04 * q + 0.5, y }, { x, y + s * 0.36 * q }, { x - s * 0.04 * q - 0.5, y }, c(1, 1, 1, 0.95 * q))
    end
end

-- Folded: just the home point crystal. Click it to open the window; drag it to move it.
local ICON = 46
local function mouse() local x, y = xy(imgui.GetMousePos()) return num(x, -1), num(y, -1) end
local eye_press = nil
local function eye_icon(dim, tooltip, on_click, on_right)
    local x, y = cursor()
    imgui.Dummy({ ICON, ICON })
    local hov = imgui.IsItemHovered() == true
    decorate(function(dl)
        crystal(dl, x + ICON / 2, y + ICON / 2, ICON * 0.47, dim)
    end)
    local mx, my = mouse()
    if hov and imgui.IsMouseClicked(0) then eye_press = { mx, my } end
    if eye_press and not imgui.IsMouseDown(0) then
        if hov and math.abs(mx - eye_press[1]) < 4 and math.abs(my - eye_press[2]) < 4 then on_click() end
        eye_press = nil
    end
    if hov and on_right and imgui.IsMouseClicked(1) then on_right() end
    if hov and not imgui.IsMouseDown(0) then show_tip(tooltip) end
end

local function mini_bar()
    local lines = { 'FFXI Questlog' }
    local kind, e = focus()
    if e then
        lines[#lines + 1] = e.t or ''
        local steps = e.st or {}
        if #steps > 0 then
            local _, current = log.step_states(e, status_of(kind, e), S.cache, has_item, S.marks[entry_key(kind, e)])
            if current then
                lines[#lines + 1] = string.format('Step %d/%d: %s', current, #steps, step_text(steps[current]))
            else
                lines[#lines + 1] = string.format('All %d steps done', #steps)
            end
        end
    else
        lines[#lines + 1] = 'Nothing in progress'
    end
    lines[#lines + 1] = S.locked and 'Click: open  |  Locked in place' or 'Click: open  |  Drag: move'
    eye_icon(false, table.concat(lines, '\n'), maximize)
end

-- The QUESTLOG wordmark: F F X I small above, then a pale blue diamond and
-- QUESTLOG in spaced white capitals, a hairline under it fading at both ends.
local function wordmark()
    local x, y = cursor()
    local size = 26
    local h = size + 26
    decorate(function(dl)
        local font = imgui.GetFont()
        local k = size / num(imgui.GetFontSize(), 13)
        dl:AddText({ x + 1, y }, col32(SOOT), 'F F X I')
        local ty = y + line_h() + 1
        local m, my = size * 0.20, ty + size / 2
        dl:AddQuadFilled({ x + m, my - m }, { x + 2 * m, my }, { x + m, my + m }, { x, my }, col32(alpha(ACID, 0.30)))
        for _, seg in ipairs({ { { x + m, my - m }, { x + 2 * m, my } }, { { x + 2 * m, my }, { x + m, my + m } },
                               { { x + m, my + m }, { x, my } }, { { x, my }, { x + m, my - m } } }) do
            dl:AddLine(seg[1], seg[2], col32(ACID), 1)
        end
        local cx = x + 2 * m + 10
        local word = 'QUESTLOG'
        local room = avail_w() - (cx - x)
        local gap = size * 0.16
        local wide = 0
        for i = 1, #word do wide = wide + text_w(word:sub(i, i)) * k + gap end
        if wide > room then gap = math.max(1, gap - (wide - room) / #word) end  -- a narrow sidebar packs it tighter
        for i = 1, #word do
            local ch = word:sub(i, i)
            dl:AddText(font, size, { cx, ty }, col32(BONE), ch)
            cx = cx + text_w(ch) * k + gap
        end
        local by = ty + size + 4
        fade_rule(dl, x - 4, x + avail_w() + 4, by, LINE, 0.6)
    end)
    imgui.Dummy({ 1, h })
end

-- The top of the sidebar: wordmark, version and the big counters.
local function header()
    wordmark()
    scaled(1.45, ACID, string.format('%02d', counts.active))
    imgui.SameLine(0, 4)
    ctext(ASH, 'ACTIVE')
    imgui.SameLine(0, 12)
    scaled(1.45, CHALK, string.format('%d', counts.done))
    imgui.SameLine(0, 4)
    ctext(ASH, 'DONE')
    ctext(SOOT, 'v' .. addon.version)
end

-- The line between the sidebar and the steps: a faint white line fading at both ends.
local function divider(dl, x, y1, y2)
    local mid = (y1 + y2) / 2
    local c0, c1 = col32(alpha(LINE, 0)), col32(alpha(LINE, 0.22))
    if not pcall(function()
        dl:AddRectFilledMultiColor({ x - 2, y1 }, { x - 1, mid }, c0, c0, c1, c1)
        dl:AddRectFilledMultiColor({ x - 2, mid }, { x - 1, y2 }, c1, c1, c0, c0)
    end) then dl:AddLine({ x - 2, y1 }, { x - 2, y2 }, c1, 1) end
end

local folded_once = {}   -- areas folded since load
local function draw_list()
    for _, f in ipairs({ { 'active', 'Active' }, { 'all', 'All' } }) do
        if nav_row(string.format('%s %d##flt_%s', f[2]:upper(), counts[f[1]], f[1]), f[2]:upper(), counts[f[1]], S.filter == f[1]) then
            S.filter = f[1]
            settings.save()
        end
    end
    imgui.Spacing()
    lock_row()
    imgui.Spacing()
    imgui.PushItemWidth(-1)
    local ok = pcall(imgui.InputTextWithHint, '##ql_search', 'Search quests, missions', ui.search, 48)
    if not ok then imgui.InputText('##ql_search', ui.search, 48) end
    imgui.PopItemWidth()
    imgui.Spacing()
    if not begin_child('##ql_list', 0, 0) then return end

    local any = false
    for gi, group in ipairs({ { 'm', data.missions, MISSION_AREAS, 'MISSIONS' }, { 'q', data.quests, QUEST_AREAS, 'QUESTS' } }) do
        local kind, list, areas, label = group[1], group[2], group[3], group[4]
        local by_area = {}
        for _, e in ipairs(list) do
            local st = status_of(kind, e)
            if shown(st) and matches(e) and playable(e, st) then
                by_area[e.l] = by_area[e.l] or {}
                table.insert(by_area[e.l], { e = e, st = st })
            end
        end
        local first = true
        for area = 0, 13 do
            local rows = by_area[area]
            if rows and #rows > 0 and areas[area] then
                if first then
                    if gi > 1 then imgui.Spacing() end
                    heading(label, gi)
                    first = false
                end
                any = true
                -- Every area starts folded each time the addon loads (ImGui would
                -- otherwise remember what was open from before a reload).
                local hid = kind .. ':' .. area
                if not folded_once[hid] then
                    folded_once[hid] = true
                    if imgui.SetNextItemOpen then pcall(imgui.SetNextItemOpen, false, ImGuiCond_Always or 1) end
                end
                local open = imgui.CollapsingHeader(string.format('%s   %d###hdr_%s_%d', areas[area]:upper(), #rows, kind, area), 0)
                if open then
                    for _, r in ipairs(rows) do
                        local key = entry_key(kind, r.e)
                        mark(r.st)
                        local name = ((r.e.s or '') ~= '' and r.e.s .. '  ' or '') .. (r.e.t or '?')
                        if imgui.Selectable(clean(name) .. '##sel_' .. key, ui.selected == key) then
                            ui.selected = key
                            ui.sel_kind, ui.sel_entry = kind, r.e
                        end
                        if text_w(name) > avail_w() - 4 then tip(name) end   -- a long name is cut off: show it whole
                    end
                end
            end
        end
    end
    if not any then
        imgui.Spacing()
        ctext(ASH, S.filter == 'active' and 'NOTHING IN PROGRESS.' or 'NOTHING HERE.')
        if not S.cache.q then
            local w = pcall(imgui.PushTextWrapPos, 0)
            ctext(SOOT, 'Zone or log in once so the game sends your quest log.')
            if w then imgui.PopTextWrapPos() end
        end
    end
    end_child()
end

-- Open a web page in the default browser; if that isn't possible, copy the link.
local function open_url(url)
    local ok = false
    if ashita and ashita.misc and ashita.misc.open_url then ok = pcall(ashita.misc.open_url, url) end
    if not ok and os and os.execute then ok = pcall(os.execute, 'start "" "' .. url .. '"') end
    if not ok then
        pcall(imgui.SetClipboardText, url)
        say('Couldn\'t open your browser -- the link is copied: %s', url)
    end
end

-- More on BG-Wiki, at the bottom.
local function wiki_links(e)
    imgui.Spacing()
    rule(1)
    ctext(ASH, track('More on BG-Wiki'))
    imgui.SameLine(0, 12)
    local url = log.wiki_url(e.t)
    if pill('OPEN PAGE ->##wiki_open', true) then open_url(url) end
    tip('Opens ' .. e.t .. ' on BG-Wiki in your browser')
    imgui.SameLine(0, 4)
    if imgui.SmallButton('COPY LINK##wiki_copy') then
        pcall(imgui.SetClipboardText, url)
        say('Copied the BG-Wiki link for %s.', e.t)
    end
end

-- How to get to an NPC in another zone (worked out every few seconds, not every frame).
local route_cache = {}
ROUTE_OPEN = ROUTE_OPEN or {}   -- (the directions opened, per NPC: folded until you click)
local function routes_to(zone, pos, my_zone, px, pz)
    if not routes or not zone or zone == my_zone then return nil end
    local k = zone .. ':' .. tostring(my_zone) .. ':' .. (pos and (math.floor(pos[1] or 0) .. ',' .. math.floor(pos[3] or 0)) or '')   -- (the NPC's spot picks the Home Point)
    local c = route_cache[k]
    local now = os.clock()
    if c and now - c.t < 3 then return c.r end
    local ok, r = pcall(log.route, routes, zone, pos and pos[1], pos and pos[3], my_zone, px, pz)
    r = (ok and type(r) == 'table' and #r > 0) and r or nil
    route_cache[k] = { t = now, r = r }
    return r
end
QL_ROUTES_TO = routes_to                                  -- (for the offline checks)
local function route_name(z) return (data and data.zones[z]) or (routes and routes.names[z]) or zone_label(z) end

local function npc_rows(npcs, my_zone, px, pz, indent, with_route)
    for _, l in ipairs(npc_lines(npcs, my_zone, px, pz)) do
        imgui.Dummy({ indent, 1 })
        imgui.SameLine(0, 0)
        ctext(SOOT, '->')
        imgui.SameLine(0, 6)
        ctext(ASH, l[1])
        if l[2] then
            imgui.SameLine(0, 8)
            chip(l[2], ACID, l[1] .. l[2], true)
        end
        -- in another zone: the way there, step by step - the warp, each zone to cross and where its exit is, the NPC.
        -- Under it the other ways, in case that warp isn't touched yet: by another warp, and walking from where you are.
        local r = with_route and routes_to(l[3], l[4], my_zone, px, pz) or nil
        if r then
            local npc = { (l[1]:match('^(.-) %- ')) or l[1], l[3], l[4] and l[4][1], l[4] and l[4][3] }
            local function steps_of(ro)
                local ok, st = pcall(log.route_steps, routes, ro, route_name, grid_of, npc)
                if not (ok and st) then return end
                for i, x in ipairs(st) do
                    imgui.Dummy({ indent + 18, 1 })
                    imgui.SameLine(0, 0)
                    ctext(VERM, string.format('%02d', i))
                    imgui.SameLine(0, 8)
                    ctext(CHALK, x[1])
                    imgui.Dummy({ indent + 18 + 26, 1 })
                    imgui.SameLine(0, 0)
                    ctext(ASH, '-> ' .. x[2])
                end
            end
            -- folded at first: one line with the quickest way; a click opens the steps (and the other ways)
            local key = tostring(l[3]) .. ':' .. l[1]
            local open = ROUTE_OPEN[key] == true
            imgui.Dummy({ indent + 18, 1 })
            imgui.SameLine(0, 0)
            if imgui.SmallButton((open and '- ' or '+ ') .. 'HOW TO GET THERE##qlway' .. key) then ROUTE_OPEN[key] = not open; open = not open end
            tip((open and 'Click to fold the directions away.' or 'Click for the step-by-step directions.') ..
                '\nThe quickest way first. A Home Point or Survival Guide works once you have touched it;\nan outpost warp needs your nation to hold the region. Walking always works.')
            if not open then
                imgui.SameLine(0, 8)
                local w = pcall(imgui.PushTextWrapPos, 0)
                ctext(ASH, log.route_text(r[1], route_name))
                if w then imgui.PopTextWrapPos() end
            end
            if open then steps_of(r[1]) end
            for k = 2, (open and #r or 1) do
                imgui.Spacing()
                imgui.Dummy({ indent + 18, 1 })
                imgui.SameLine(0, 0)
                ctext(SOOT, log.route_alt_title(r[1], r[k], k))
                steps_of(r[k])
            end
        end
    end
end

-- One step: a big numeral in the gutter (inverted acid block for the current
-- step), the tick box, the text; done steps fade to soot and are struck out.
-- Tick (or untick) step i yourself. Ticking a step also ticks every step before
-- it that isn't done yet, since you can't be past a step you haven't done.
local function set_mark(key, i, value, done)
    S.marks[key] = S.marks[key] or T{}
    local m = S.marks[key]
    m[i] = value
    if value then
        for j = 1, i - 1 do
            if not done[j] then m[j] = true end
        end
    end
    settings.save()
end

local function step_card(i, st, done, is_current, key, my_zone, px, pz, all_done)
    local color = done and SOOT or (is_current and BONE or CHALK)
    if is_current then
        decorate(function(dl)
            local x, y = xy(imgui.GetCursorScreenPos())
            local h = imgui.GetTextLineHeight()
            band(dl, x - 6, y - 4, x + 260, y + h + 4, ACID, 0.16)
            dl:AddRectFilled({ x - 4, y - 2 }, { x + 26, y + h + 2 }, col32(ACID))
        end)
    end
    imgui.Dummy({ 1, 1 })
    imgui.SameLine(0, 0)
    ctext(done and SOOT or (is_current and ON_ACID or ASH), string.format('%02d', i))
    imgui.SameLine(0, 14)
    local v = { done }
    local n = push_colors({ { 'ImGuiCol_FrameBg', alpha(BONE, 0.08) }, { 'ImGuiCol_FrameBgHovered', alpha(ACID, 0.25) },
                            { 'ImGuiCol_FrameBgActive', alpha(ACID, 0.40) }, { 'ImGuiCol_Border', alpha(BONE, done and 0.25 or 0.6) } })
    local rv = (ImGuiStyleVar_FrameRounding and pcall(imgui.PushStyleVar, ImGuiStyleVar_FrameRounding, 0)) and 1 or 0
    local clicked = imgui.Checkbox('##st_' .. key .. '_' .. i, v)
    if rv > 0 then imgui.PopStyleVar(1) end
    pop_colors(n)
    if clicked then set_mark(key, i, v[1] == true, all_done) end
    tip('Tick or untick this step yourself')
    imgui.SameLine(0, 6)
    local wrap = pcall(imgui.PushTextWrapPos, 0)       -- long steps wrap inside the panel
    local ok = pcall(ctext, color, step_text(st))
    if wrap then imgui.PopTextWrapPos() end
    if not ok then error('step text failed') end
    -- Clicking the step's text ticks it too (a bigger target than the box).
    if not clicked and imgui.IsItemClicked and imgui.IsItemClicked(0) then set_mark(key, i, not done, all_done) end
    if done then
        strike(SOOT)
    else
        if st.tip then
            imgui.Dummy({ 52, 1 })
            imgui.SameLine(0, 0)
            local w = pcall(imgui.PushTextWrapPos, 0)
            pcall(ctext, VERM, '* ' .. st.tip)
            if w then imgui.PopTextWrapPos() end
        end
        npc_rows(st.n, my_zone, px, pz, 52, is_current)
    end
    imgui.Spacing()
end

-- The top of the steps column, outside its scrolling area so it never scrolls
-- away: your position on the left, - and x on the right.
local function topbar(my_zone, px, pz)
    local w = avail_w()
    local x0 = cursor()
    if type(px) == 'number' and type(pz) == 'number' then
        ctext(SOOT, 'YOU')
        imgui.SameLine(0, 6)
        ctext(ACID, coords(px, pz, my_y))
        tip('Your position: x, y, z as Ashita shows them (z = height).\n' .. zone_label(my_zone))
        local zl = zone_label(my_zone)
        if text_w(zl) < w - 230 then
            imgui.SameLine(0, 8)
            ctext(SOOT, zl)
        end
    else
        imgui.Dummy({ 1, 1 })
    end
    -- The buttons sit at the column's right edge whatever is to their left.
    imgui.SameLine(0, 0)
    pcall(imgui.SetCursorScreenPos, { x0 + math.max(0, w - 46), select(2, cursor()) })
    if round_button('-##ql_min', '-') then minimize() end
    tip('Minimize to the crystal (/ql mini)')
    imgui.SameLine(0, 2)
    if round_button('x##ql_close', 'x', true) then ui.open[1] = false end
    tip('Close (type /ql to open again)')
end

-- The detailed walkthrough under a quest's steps: what you need, where it
-- starts, the reward, then numbered steps and the gotchas.
local function guide_for(kind, e)
    local set = kind == 'm' and mguides or (kind == 'q' and guides or nil)
    local area = set and set[e.l]
    return area and area[e.i] or nil
end
local function draw_guide(w)
    imgui.Spacing()
    rule(1)
    heading('Steps')
    local wrap = pcall(imgui.PushTextWrapPos, 0)
    local function field(label, value, color)
        if not value or value == '' then return end
        ctext(SOOT, track(label))
        imgui.SameLine(0, 8)
        ctext(color or CHALK, value)
    end
    field('Need', w.req)
    field('Start', w.start, ACID)
    field('Reward', w.reward, AMBER)
    if w.rep then ctext(SOOT, track('Repeatable')) end
    imgui.Spacing()
    for i, line in ipairs(w.steps or {}) do
        ctext(VERM, string.format('%02d', i))
        imgui.SameLine(0, 8)
        ctext(BONE, line)
    end
    if w.notes and #w.notes > 0 then
        imgui.Spacing()
        for _, n in ipairs(w.notes) do
            ctext(SUN, '!')
            imgui.SameLine(0, 8)
            ctext(ASH, n)
        end
    end
    if wrap then imgui.PopTextWrapPos() end
end

local function draw_detail(my_zone, px, pz)
    local e, kind = ui.sel_entry, ui.sel_kind
    if not e then
        imgui.Spacing()
        scaled(1.3, SOOT, 'NO ENTRY SELECTED')
        ctext(ASH, 'Pick a quest or mission on the left.')
        ctext(SOOT, 'Finished steps are struck out; the pale blue block marks where you are.')
        return
    end
    local status = status_of(kind, e)
    local areas = kind == 'm' and MISSION_AREAS or QUEST_AREAS
    ctext(ASH, track((kind == 'm' and 'Mission' or 'Quest') .. ' / ' .. (areas[e.l] or '')))
    local tw = pcall(imgui.PushTextWrapPos, 0)          -- a long name wraps instead of running off the panel
    scaled(1.45, BONE, e.t or '?')
    if tw then imgui.PopTextWrapPos() end
    if (e.s or '') ~= '' then ctext(ASH, e.s) end
    if status == 'active' then chip('IN PROGRESS', ACID, 'status', true)
    elseif status == 'done' then chip('COMPLETED', CHALK, 'status', false)
    else chip('NOT STARTED', ASH, 'status', false) end

    local key = entry_key(kind, e)
    local steps = e.st or {}
    if #steps == 0 then
        imgui.Spacing()
        local w = pcall(imgui.PushTextWrapPos, 0)
        if e.x then
            ctext(ASH, 'No step list for this one yet -- BG-Wiki below has the full walkthrough.')
        else
            ctext(ASH, 'The server\'s scripts don\'t spell out the steps for this one; the NPCs involved are below, and BG-Wiki has the full walkthrough.')
        end
        if w then imgui.PopTextWrapPos() end
        if e.n and #e.n > 0 then
            imgui.Spacing()
            heading('NPCs involved')
            npc_rows(e.n, my_zone, px, pz, 8, true)
        end
        local w = guide_for(kind, e)
        if w then draw_guide(w) end
        wiki_links(e)
        return
    end

    local marks = S.marks[key]
    local done, current = log.step_states(e, status, S.cache, has_item, marks)
    local n_done = 0
    for i = 1, #steps do if done[i] then n_done = n_done + 1 end end
    -- With a hand-written walkthrough, that is the step list (one set of steps, not two); the server's
    -- checklist folds away under it.
    local w = guide_for(kind, e)
    local guided = w ~= nil and w.steps ~= nil and #w.steps > 0
    imgui.SameLine(0, 14)
    ctext(n_done == #steps and CHALK or ACID, string.format('%02d', n_done))
    imgui.SameLine(0, 2)
    ctext(SOOT, string.format(guided and '/ %02d CHECKED' or '/ %02d STEPS', #steps))
    step_bar(done, current, #steps)
    if guided then draw_guide(w) imgui.Spacing() end
    rule(2)
    local open = true
    if guided then
        open = imgui.CollapsingHeader(string.format('CHECKLIST   %d/%d###ql_chk_%s', n_done, #steps, key), 0)
        tip('What the game tracks for this one; ticks itself as you go.')
    else
        heading('Steps')
    end
    if open then
        if not S.cache.q then
            local cw = pcall(imgui.PushTextWrapPos, 0)
            pcall(ctext, VERM, 'Your quest log hasn\'t arrived yet: zone once (or log out and back in) and FFXI Questlog fills in what you\'ve started and finished.')
            if cw then imgui.PopTextWrapPos() end
        end
        local aw = pcall(imgui.PushTextWrapPos, 0)
        if S.auto ~= false then
            ctext(SOOT, 'AUTO CHECKLIST ON: steps tick as you talk, trade, defeat and travel. Click a step to tick it yourself.')
        else
            ctext(SOOT, 'Auto checklist off (/ql auto). Click a step to tick it.')
        end
        if aw then imgui.PopTextWrapPos() end
        imgui.Spacing()
        for i, st in ipairs(steps) do
            step_card(i, st, done[i], i == current, key, my_zone, px, pz, done)
        end
        if marks and next(marks) then
            if imgui.SmallButton('CLEAR MY TICKS##clr_' .. key) then S.marks[key] = nil settings.save() end
        end
    end
    if w and not guided then draw_guide(w) end
    wiki_links(e)
end

-- Moving the window: drag anywhere on its background (handled here, since some
-- setups don't move ImGui windows by themselves).
local drag, place_at, first_frame = nil, nil, true
local function handle_drag()
    if not imgui.IsMouseDown(0) then
        if drag then drag = nil settings.save() end
        return
    end
    local mx, my = xy(imgui.GetMousePos())
    local wx, wy = xy(imgui.GetWindowPos())
    if not (mx and wx) then return end
    if not drag then
        if not imgui.IsWindowHovered() or not imgui.IsMouseClicked(0) then return end
        if imgui.IsAnyItemHovered and imgui.IsAnyItemHovered() then return end  -- a button, not the background
        local ww, wh = xy(imgui.GetWindowSize())
        if ww and mx > wx + ww - 22 and my > wy + wh - 22 then return end
        drag = { mx = mx, my = my, wx = wx, wy = wy }
        return
    end
    local tx, ty = drag.wx + (mx - drag.mx), drag.wy + (my - drag.my)
    if math.abs(tx - wx) >= 1 or math.abs(ty - wy) >= 1 then imgui.SetWindowPos({ tx, ty }) end
    S.pos = T{ math.floor(tx), math.floor(ty) }
end

local last_err = -60
local function render(now)
    if not ui.open[1] then
        if S.visible ~= false then S.visible = false settings.save() end
        return
    end
    if S.mini then
        imgui.SetNextWindowSizeConstraints({ 0, 0 }, { 900, 200 })
    else
        local fs = S.full_size
        if restore_size and fs and (fs[1] or -1) > 0 then
            imgui.SetNextWindowSize({ fs[1], fs[2] }, ImGuiCond_Always or 0)
        else
            imgui.SetNextWindowSize({ START_W, START_H }, ImGuiCond_FirstUseEver or 0)
        end
        restore_size = false
        imgui.SetNextWindowSizeConstraints({ MIN_W, MIN_H }, { 4000, 4000 })
    end
    if place_at then
        imgui.SetNextWindowPos(place_at, ImGuiCond_Always or 0)
        place_at = nil
    elseif first_frame and S.pos and (S.pos[1] or -1) >= 0 then
        imgui.SetNextWindowPos({ S.pos[1], S.pos[2] }, ImGuiCond_Always or 0)
    end
    first_frame = false
    local nc, nv = push_style()
    local font_on = ui.font ~= nil and pcall(imgui.PushFont, ui.font)
    local flags = bit.bor(ImGuiWindowFlags_NoTitleBar or 0, ImGuiWindowFlags_NoScrollbar or 0,
        S.mini and (ImGuiWindowFlags_AlwaysAutoResize or 0) or 0,
        S.locked and (ImGuiWindowFlags_NoMove or 0) or 0)
    if imgui.Begin('FFXI Questlog v' .. addon.version .. '##questlog', ui.open, flags) then
        if S.locked then drag = nil else pcall(handle_drag) end
        child_depth, pushed_colors = 0, 0
        local ok, e = pcall(function()
            refresh_held(now)
            refresh_counts(now)
            if S.mini then return mini_bar() end
            glass()
            local my_zone, px, pz = where_am_i()
            -- The sidebar: wordmark and counters, the filters, search, the list.
            if begin_child('##ql_side', LIST_W, 0) then
                header()
                imgui.Spacing()
                draw_list()
            end
            end_child()
            decorate(function(dl)
                local x2, _ = xy(imgui.GetItemRectMax())
                local _, y1 = xy(imgui.GetItemRectMin())
                local _, y2 = xy(imgui.GetItemRectMax())
                divider(dl, x2 + SIDE_GAP / 2, y1, y2)
            end)
            imgui.SameLine(0, SIDE_GAP)
            imgui.BeginGroup()
            group_open = true
            topbar(my_zone, px, pz)
            if begin_child('##ql_detail', 0, 0) then draw_detail(my_zone, px, pz) end
            end_child()
            imgui.EndGroup()
            group_open = false
        end)
        if not ok then
            if pushed_colors > 0 then pop_colors(pushed_colors) end
            while child_depth > 0 do end_child() end
            if group_open then imgui.EndGroup() group_open = false end
            if now - last_err > 30 then last_err = now err('Window error (FFXI Questlog kept running): %s', tostring(e)) end
        end
    end
    imgui.End()
    if font_on then imgui.PopFont() end
    pop_style(nc, nv)
end

-- ---------------------------------------------------------------------------
-- Auto checklist: when you have a cutscene or menu with an NPC (talking or
-- trading), defeat a monster, or enter a zone, the matching step of each quest
-- or mission you're on gets ticked (and the steps before it).
-- ---------------------------------------------------------------------------

local function entity_info(idx)
    local info = {}
    pcall(function()
        local mm = AshitaCore:GetMemoryManager()
        local em = mm:GetEntity()
        info.zone = mm:GetParty():GetMemberZone(0)
        if idx and idx > 0 then
            info.name = em:GetName(idx)
            info.x, info.z = em:GetLocalPositionX(idx), em:GetLocalPositionY(idx)
        end
    end)
    return info
end

local function auto_tick(what)
    if not S or not data or S.auto == false then return end
    for _, g in ipairs({ { 'm', data.missions }, { 'q', data.quests } }) do
        for _, e in ipairs(g[2]) do
            if e.st and #e.st > 0 then
                local status = status_of(g[1], e)
                local tracked = status == 'active' or (ui.sel_entry == e and status ~= 'done')
                if tracked then
                    local key = entry_key(g[1], e)
                    local done = log.step_states(e, status, S.cache, has_item, S.marks[key])
                    local i = log.auto_step(e, done, what, data.npcs)
                    if i then
                        set_mark(key, i, true, done)
                        say('%s: step %d of %d done -- %s', e.t, i, #e.st, step_text(e.st[i]))
                    end
                end
            end
        end
    end
end

local zone_check_at = nil

-- ---------------------------------------------------------------------------
-- Events
-- ---------------------------------------------------------------------------

ashita.events.register('load', 'ql_load', function()
    folded_once = {}
    pcall(function()                                    -- Aether's typeface (SIL Open Font License, fonts/OFL.txt)
        local f = (addon.path:gsub('[\\/]+$', '')) .. '\\fonts\\BarlowSemiCondensed-Medium.ttf'
        local h = io.open(f, 'rb')
        if h then h:close() ui.font = imgui.AddFontFromFileTTF(f, 16) end
    end)
    local ok, d = pcall(require, 'data.quests')
    if ok then data = d else err('Could not load data/quests.lua.') return end
    for _, set in ipairs({ data.quests, data.missions }) do for _, e in ipairs(set) do log.mark_repeats(e) end end
    local okr, r = pcall(require, 'data.routes')
    routes = (okr and type(r) == 'table') and r or nil
    local okg, g = pcall(require, 'data.guides')
    if okg and type(g) == 'table' then
        guides = g
        -- a walkthrough can carry the right name for a quest the generated list mislabels
        for _, e in ipairs(data.quests) do
            local w = guides[e.l] and guides[e.l][e.i]
            if w and w.t then e.t = w.t end
        end
    end
    local okm, mg = pcall(require, 'data.mission_guides')
    if okm and type(mg) == 'table' then
        mguides = mg
        -- and the right name and number for a mission the generated list mislabels
        for _, e in ipairs(data.missions) do
            local w = mguides[e.l] and mguides[e.l][e.i]
            if w and w.t then e.t = w.t end
            if w and w.s then e.s = w.s end
        end
    end
    S = settings.load(defaults)
    if S.filter ~= 'active' and S.filter ~= 'all' then S.filter = 'active' end   -- (the old Done view is gone)
    ui.open[1] = S.visible ~= false
    settings.register('settings', 'ql_settings_update', function(s) if s ~= nil then S = s end end)
    say('v%s loaded: %d quests, %d missions. /ql to show or hide.', addon.version, #data.quests, #data.missions)
end)

ashita.events.register('unload', 'ql_unload', function()
    if S then settings.save() end
end)

ashita.events.register('command', 'ql_command', function(e)
    local args = e.command:args()
    if #args == 0 or (args[1]:lower() ~= '/ql' and args[1]:lower() ~= '/questlog') then return end
    e.blocked = true
    if not S then return end
    local sub = args[2] and args[2]:lower() or nil
    if sub == nil then
        ui.open[1] = not ui.open[1]
        S.visible = ui.open[1]
        settings.save()
    elseif sub == 'mini' then
        ui.open[1], S.visible = true, true
        if S.mini then maximize() else S.mini = true settings.save() end
    elseif sub == 'find' then
        ui.search[1] = table.concat(args, ' ', 3)
        S.filter = 'all'
        ui.open[1], S.visible = true, true
        if S.mini then maximize() end
    elseif sub == 'pos' and tonumber(args[3]) and tonumber(args[4]) then
        place_at = { math.floor(tonumber(args[3])), math.floor(tonumber(args[4])) }
        S.pos = T{ place_at[1], place_at[2] }
        ui.open[1], S.visible = true, true
        settings.save()
    elseif sub == 'lock' or sub == 'unlock' then
        local w = (args[3] or ''):lower()
        if sub == 'unlock' or w == 'off' then set_locked(false)
        elseif w == 'on' then set_locked(true)
        else set_locked(not S.locked) end
    elseif sub == 'opacity' then
        local v = tonumber(args[3] or '')
        if not v or v < 30 or v > 100 then return err('Use /ql opacity 30-100 (100 = solid).') end
        S.opacity = math.floor(v)
        settings.save()
        say('Window opacity %d (100 = solid).', S.opacity)
    elseif sub == 'unscripted' then
        S.unscripted = not (S.unscripted ~= false)
        settings.save()
        say('Quests and missions without a step list are %s.', S.unscripted ~= false and 'listed' or 'hidden')
    elseif sub == 'auto' then
        S.auto = not (S.auto ~= false)
        settings.save()
        say('Auto checklist %s.', S.auto and 'ON: steps tick as you talk, trade, defeat and travel' or 'OFF: tick steps yourself')
    elseif sub == 'check' then
        local c = S.cache
        local nq = 0
        for _ in pairs((c.q or {}).cur or {}) do nq = nq + 1 end
        local nk = 0
        for _ in pairs(c.ki or {}) do nk = nk + 1 end
        say('Quest log from the game: %s. Mission log: %s. Key items: %s.',
            c.q and (nq .. ' of 11 areas') or 'NOT RECEIVED (zone once)',
            (c.m and c.m.nation ~= nil) and 'yes' or 'NOT RECEIVED (zone once)',
            nk > 0 and (nk .. ' tables') or 'NOT RECEIVED (zone once)')
        local entry, kind = ui.sel_entry, ui.sel_kind
        if not entry then return say('Pick a quest or mission in the window, then /ql check again for its steps.') end
        local status = status_of(kind, entry)
        say('%s: the game says %s.', entry.t, status == 'active' and 'in progress' or (status == 'done' and 'completed' or 'not started'))
        refresh_held(os.clock() + 10)
        local done = log.step_states(entry, status, c, has_item, S.marks[entry_key(kind, entry)])
        local marks = S.marks[entry_key(kind, entry)] or {}
        for i, st in ipairs(entry.st or {}) do
            local how = {}
            if marks[i] ~= nil then how[#how + 1] = marks[i] and 'ticked by you' or 'unticked by you' end
            if st.b then how[#how + 1] = 'starts the quest: ' .. (status ~= 'none' and 'yes' or 'no') end
            if st.c then how[#how + 1] = 'finishes it: ' .. (status == 'done' and 'yes' or 'no') end
            for _, k in ipairs(st.gk or {}) do how[#how + 1] = 'key item ' .. (data.kis[k] or k) .. ': ' .. (log.has_ki(c, k) and 'have it' or 'not yet') end
            for _, it in ipairs(st.gi or {}) do how[#how + 1] = item_name(it) .. ': ' .. (has_item(it) and 'carrying it' or 'not carrying') end
            if #how == 0 then how[1] = 'the game doesn\'t report this one - tick it yourself' end
            say('  %2d %s  %s', i, done[i] and '[x]' or '[ ]', table.concat(how, '; '))
        end
    elseif sub == 'help' then
        say('FFXI Questlog v%s by %s', addon.version, addon.author)
        say('/ql  show / hide  |  /ql mini  minimize / open  |  /ql find <text>  |  /ql pos <x> <y>  |  /ql lock  |  /ql opacity 30-100  |  /ql unscripted')
        say('Auto checklist: steps tick as you talk, trade, defeat and travel (/ql auto to turn off).')
        say('Click a step (or its box) to tick it yourself. /ql check explains what was ticked and why.')
        say('Your quest log, mission log and key items arrive when you zone or log in.')
    else
        err('Unknown command. /ql help')
    end
end)

ashita.events.register('d3d_present', 'ql_present', function()
    if not S or not data then return end
    if zone_check_at and os.clock() >= zone_check_at then
        zone_check_at = nil
        local what = entity_info(nil)
        what.kind = 'zone'
        pcall(auto_tick, what)
    end
    render(os.clock())
end)

local save_at = nil
ashita.events.register('packet_in', 'ql_packet_in', function(e)
    if not S or not e.data then return end
    local changed = false
    if e.id == 0x056 then
        changed = log.read_log(S.cache, e.data)
    elseif e.id == 0x055 then
        changed = log.read_kis(S.cache, e.data)
    elseif (e.id == 0x032 or e.id == 0x034) and #e.data >= (e.id == 0x032 and 0x0C or 0x2C) then
        -- A cutscene or menu with an NPC: you talked to it or traded to it.
        local at = e.id == 0x032 and 0x08 or 0x28
        local idx = e.data:byte(at + 1) + e.data:byte(at + 2) * 256
        local what = entity_info(idx)
        what.kind = 'event'
        pcall(auto_tick, what)
    elseif e.id == 0x029 and #e.data >= 0x1A then
        -- "X defeats Y" / "Y falls to the ground."
        local msg = e.data:byte(0x18 + 1) + e.data:byte(0x18 + 2) * 256
        if msg == 6 or msg == 20 then
            local idx = e.data:byte(0x16 + 1) + e.data:byte(0x16 + 2) * 256
            local what = entity_info(idx)
            what.kind = 'kill'
            pcall(auto_tick, what)
        end
    elseif e.id == 0x00A then
        zone_check_at = os.clock() + 4      -- check the new zone once it has loaded
    end
    if changed then save_at = os.clock() + 3 end
    if save_at and os.clock() >= save_at then save_at = nil settings.save() end
end)
