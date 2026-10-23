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
  /ql mini          minimize to the pink eye / open the full window
  /ql pos <x> <y>   put the window at this screen position
  /ql help
]]--

addon.name    = 'FFXI Questlog'
addon.author  = 'Guabancex'
addon.version = '1.7.9'
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
local RADIUS           = 0          -- the panel's corners (flat: square)

local defaults = T{
    visible = true,
    mini    = false,        -- minimized to the pink eye
    full_size = T{ -1, -1 },    -- the full window's size, restored when you open it again
    filter  = 'active',     -- 'active' | 'all' | 'done'
    marks   = T{},          -- ['q:0:11'] = { [step] = true/false }  ticks (yours and auto)
    opacity = 82,           -- window opacity, 30-100
    auto    = true,         -- auto checklist: tick talk/trade/kill/zone steps as they happen
    unscripted = true,      -- list quests/missions that have no step list (false hides them)
    cache   = T{},          -- last quest/mission/key item data from the game
    pos     = T{ -1, -1 },
}

local S, data = nil, nil
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
        x, z = em:GetLocalPositionX(idx), em:GetLocalPositionY(idx)
        local ok, h = pcall(em.GetLocalPositionZ, em, idx)
        if ok and type(h) == 'number' then my_y = h end
    end)
    return zone, x, z
end

-- Coordinates as x, y, z (y = height), whole numbers: the server's !pos order.
local function coords(x, y, z)
    local function r(v) return type(v) == 'number' and math.floor(v + 0.5) or 0 end
    return string.format('(%d, %d, %d)', r(x), r(y), r(z))
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

local function step_text(st)
    local names = {}
    for _, n in ipairs(st.n or {}) do names[#names + 1] = npc_label(n[2], n[1]) end
    local t
    if st.x then t = st.x                      -- hand-checked wording
    elseif st.k == 'talk' then t = 'Talk to ' .. join_or(names)
    elseif st.k == 'trade' then
        local items = {}
        for _, id in ipairs(st.need or {}) do items[#items + 1] = item_name(id) end
        t = 'Trade ' .. join_or(items) .. ' to ' .. join_or(names)
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
local function npc_lines(npcs, my_zone, px, pz)
    local out = {}
    for _, n in ipairs(npcs or {}) do
        if n[2] then
            local pos = data.npcs[n[1] .. ':' .. n[2]]
            local line = string.format('%s - %s', npc_label(n[2], n[1]), zone_label(n[1]))
            local here = nil
            if pos then
                line = line .. ' ' .. coords(pos[1], pos[2], pos[3])
                if my_zone == n[1] and px and pz then
                    local dist, dir = log.bearing(px, pz, pos[1], pos[3])
                    here = dir == 'here' and 'here' or string.format('%dy %s', math.floor(dist + 0.5), dir)
                end
            end
            out[#out + 1] = { line, here }
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

-- FFXI Questlog's look: a rounded, glowing control panel in 80s Miami colors.
-- A see-through midnight-violet panel (its opacity is a setting) with a hot
-- pink neon edge; a sidebar on the left with the QUESTLOG wordmark (its letters
-- drift from pink through sunset orange to electric cyan), the filters and the
-- list; the steps on the right. Electric cyan = "you are here", hot pink = the
-- brand and tips. Done steps fade to dusk and get struck out.
local INK, INK2      = rgb('120a24', 0.82), rgb('1b0f38')
local BONE, CHALK    = rgb('f4ecff'), rgb('d9cdf5')
local ASH, SOOT      = rgb('a497c9'), rgb('6a5c94')
local ACID, ON_ACID  = rgb('2de2e6'), rgb('120a24')     -- electric cyan
local VERM           = rgb('ff2e88')                    -- hot pink
local SUN, AMBER     = rgb('ff6f3c'), rgb('ffb443')     -- sunset orange, amber
local RULE           = { 1, 0.18, 0.53, 0.28 }          -- pink hairline

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

local STYLE_COLORS = {
    { 'ImGuiCol_WindowBg', INK }, { 'ImGuiCol_ChildBg', alpha(INK, 0) }, { 'ImGuiCol_PopupBg', alpha(INK2, 0.97) },
    { 'ImGuiCol_Border', alpha(BONE, 0.10) }, { 'ImGuiCol_Text', BONE }, { 'ImGuiCol_TextDisabled', ASH },
    { 'ImGuiCol_FrameBg', alpha(BONE, 0.04) }, { 'ImGuiCol_FrameBgHovered', alpha(BONE, 0.08) }, { 'ImGuiCol_FrameBgActive', alpha(ACID, 0.10) },
    { 'ImGuiCol_Button', alpha(BONE, 0.07) }, { 'ImGuiCol_ButtonHovered', alpha(VERM, 0.30) }, { 'ImGuiCol_ButtonActive', alpha(VERM, 0.50) },
    { 'ImGuiCol_Header', alpha(VERM, 0.16) }, { 'ImGuiCol_HeaderHovered', alpha(BONE, 0.07) }, { 'ImGuiCol_HeaderActive', alpha(VERM, 0.26) },
    { 'ImGuiCol_CheckMark', ACID }, { 'ImGuiCol_Separator', RULE },
    { 'ImGuiCol_PlotHistogram', ACID }, { 'ImGuiCol_ScrollbarBg', alpha(INK, 0) },
    { 'ImGuiCol_ScrollbarGrab', alpha(VERM, 0.35) }, { 'ImGuiCol_ScrollbarGrabHovered', alpha(VERM, 0.60) },
    { 'ImGuiCol_ScrollbarGrabActive', ACID }, { 'ImGuiCol_TextSelectedBg', alpha(ACID, 0.30) },
    { 'ImGuiCol_ResizeGrip', alpha(BONE, 0.10) }, { 'ImGuiCol_ResizeGripHovered', alpha(ACID, 0.6) }, { 'ImGuiCol_ResizeGripActive', ACID },
}
local STYLE_VARS = {
    { 'ImGuiStyleVar_WindowRounding', RADIUS }, { 'ImGuiStyleVar_ChildRounding', 0 }, { 'ImGuiStyleVar_FrameRounding', 0 },
    { 'ImGuiStyleVar_GrabRounding', 0 }, { 'ImGuiStyleVar_ScrollbarRounding', 0 }, { 'ImGuiStyleVar_PopupRounding', 0 },
    { 'ImGuiStyleVar_WindowBorderSize', 0 }, { 'ImGuiStyleVar_ChildBorderSize', 0 }, { 'ImGuiStyleVar_FrameBorderSize', 1 },
    { 'ImGuiStyleVar_WindowPadding', { 16, 14 } }, { 'ImGuiStyleVar_FramePadding', { 8, 3 } },
    { 'ImGuiStyleVar_ItemSpacing', { 8, 6 } }, { 'ImGuiStyleVar_ScrollbarSize', 6 },
}
local function push_style()
    local nc, nv = 0, 0
    -- The panel's see-through-ness comes from the opacity setting (30-100).
    local o = math.max(30, math.min(100, (S and S.opacity) or 82)) / 100
    for _, c in ipairs(STYLE_COLORS) do
        local id = _G[c[1]]
        local col = c[2]
        if c[1] == 'ImGuiCol_WindowBg' then col = { col[1], col[2], col[3], o } end
        if c[1] == 'ImGuiCol_WindowBg' and S and S.mini then col = { 0, 0, 0, 0 } end  -- folded: just the eye
        if type(id) == 'number' and pcall(imgui.PushStyleColor, id, col) then nc = nc + 1 end
    end
    for _, v in ipairs(STYLE_VARS) do
        local id = _G[v[1]]
        local val = v[2]
        if v[1] == 'ImGuiStyleVar_WindowPadding' and S and S.mini then val = { 2, 2 } end  -- the folded eye
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
-- A left-to-right gradient bar (flat if this build can't do gradients).
local function gradient(dl, x1, y1, x2, y2, a, b)
    dl:AddRectFilled({ x1, y1 }, { x2, y2 }, col32(a))
end

-- Tooltips: a dark violet card with round corners, a thin pink edge and a
-- pink-to-cyan line along the top; the first line bright, the rest softer.
show_tip = function(t)
    if imgui.BeginTooltip == nil then return imgui.SetTooltip(t) end
    local nv, nc = 0, 0
    for _, v in ipairs({ { 'ImGuiStyleVar_WindowRounding', 0 }, { 'ImGuiStyleVar_WindowPadding', { 9, 5 } },
                         { 'ImGuiStyleVar_WindowBorderSize', 1 } }) do
        local id = _G[v[1]]
        if type(id) == 'number' and pcall(imgui.PushStyleVar, id, v[2]) then nv = nv + 1 end
    end
    for _, c in ipairs({ { 'ImGuiCol_PopupBg', rgb('0e0720', 0.96) }, { 'ImGuiCol_Border', alpha(VERM, 0.55) } }) do
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
                gradient(dl, wx + 8, wy + 1, wx + ww - 8, wy + 2, VERM, ACID)
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

-- A round status mark: cyan dot with a halo = in progress, open ring = done, dash = not started.
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

-- A sidebar row (the filters): the open one glows pink, fading to the right,
-- with a cyan line under it and a bright bar on its left edge; a count on the right.
local NAV_H = 26
local function nav_row(label, name, count, active)
    local x, y = cursor()
    local w = avail_w()
    local clicked = imgui.InvisibleButton(label, { w, NAV_H })
    local hov = imgui.IsItemHovered() == true
    decorate(function(dl)
        if active then
            gradient(dl, x, y, x + w, y + NAV_H, alpha(VERM, 0.38), alpha(VERM, 0))
            gradient(dl, x, y + NAV_H - 2, x + w, y + NAV_H, ACID, alpha(ACID, 0))
            dl:AddRectFilled({ x, y }, { x + 3, y + NAV_H }, col32(BONE))
        elseif hov then
            dl:AddRectFilled({ x, y }, { x + w, y + NAV_H }, col32(alpha(BONE, 0.05)))
        end
        local ty = y + (NAV_H - line_h()) / 2
        dl:AddText({ x + 14, ty }, col32((active or hov) and BONE or CHALK), name)
        local c = string.format('%d', count)
        dl:AddText({ x + w - 10 - text_w(c), ty }, col32(active and ACID or SOOT), c)
    end)
    return clicked
end

-- A small round icon button (- and x in the corner).
local function round_button(label, glyph, danger)
    local x, y = cursor()
    local s = 22
    local clicked = imgui.InvisibleButton(label, { s, s })
    local hov = imgui.IsItemHovered() == true
    decorate(function(dl)
        local cx, cy, r = x + s / 2, y + s / 2, s * 0.2
        if hov then dl:AddCircleFilled({ cx, cy }, s / 2, col32(danger and alpha(VERM, 0.35) or alpha(ACID, 0.22)), 20) end
        local c = col32(hov and BONE or alpha(CHALK, 0.85))
        if glyph == 'x' then
            dl:AddLine({ cx - r, cy - r }, { cx + r, cy + r }, c, 1.6)
            dl:AddLine({ cx - r, cy + r }, { cx + r, cy - r }, c, 1.6)
        else
            dl:AddLine({ cx - r, cy }, { cx + r, cy }, c, 1.6)
        end
    end)
    return clicked
end

-- A rounded button: a pink neon edge (primary) or the quiet one.
local function pill(label, primary)
    local n = primary and push_colors({ { 'ImGuiCol_Button', alpha(VERM, 0.10) }, { 'ImGuiCol_ButtonHovered', alpha(VERM, 0.30) },
                                        { 'ImGuiCol_ButtonActive', alpha(VERM, 0.45) }, { 'ImGuiCol_Border', alpha(VERM, 0.85) } }) or 0
    local clicked = imgui.SmallButton(label)
    pop_colors(n)
    return clicked
end

-- A square tag that does nothing: inverted (filled) or quiet.
local function chip(label, color, id, filled)
    local bg = filled and color or alpha(color, 0.12)
    local n = push_colors({ { 'ImGuiCol_Button', bg }, { 'ImGuiCol_ButtonHovered', bg },
                            { 'ImGuiCol_ButtonActive', bg }, { 'ImGuiCol_Text', filled and ON_ACID or color } })
    imgui.SmallButton(clean(label) .. '##chip_' .. id)
    pop_colors(n)
end

-- Section heading: the name in spaced capitals, a faint line on to the edge.
local function heading(label, index)
    local x, y = cursor()
    local w = avail_w()
    if index then ctext(SOOT, string.format('%02d', index)) imgui.SameLine(0, 8) end
    local lx = cursor()
    ctext(CHALK, track(label))
    decorate(function(dl)
        local ex = lx + text_w(track(label)) + 14
        local cy = y + line_h() / 2
        if ex < x + w then dl:AddLine({ ex, cy }, { x + w, cy }, col32(alpha(BONE, 0.08)), 1) end
    end)
end

-- A full-width rule: a faint hairline, or a pink-to-cyan neon one (weight 2+).
local function rule(weight, color)
    decorate(function(dl)
        local x, y = cursor()
        local w = avail_w()
        if (weight or 1) >= 2 then
            gradient(dl, x, y, x + w, y + weight, VERM, alpha(ACID, 0.15))
        else
            dl:AddRectFilled({ x, y }, { x + w, y + 1 }, col32(color or alpha(BONE, 0.08)))
        end
    end)
    imgui.Dummy({ 1, (weight or 1) + 2 })
end

-- One rounded segment per step: pink-to-cyan = done, a bright cyan pill with a
-- glow = current, a faint one = still to do.
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
                dl:AddRectFilled({ x1, y }, { x1 + bw, y + 6 }, col32(VERM), r)
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

local function shown(status)
    if S.filter == 'active' then return status == 'active' end
    if S.filter == 'done' then return status == 'done' end
    return true
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
            if playable(e, st) then c.all = c.all + 1 end
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

-- FFXI Questlog's folded icon: the CatsEyeXI cat's eye in hot pink, drawn with
-- shapes (no image files needed): an almond eye, a pink iris, a slit pupil and
-- a glint. It blinks every few seconds (every third time, twice), the lids
-- sweeping shut and open again.
local function blink_open(t)
    local cycle = 4.2
    local ph = t % cycle
    local n = math.floor(t / cycle)
    local function shut(p0) local d = (ph - p0) / 0.24 if d >= 0 and d <= 1 then return math.sin(math.pi * d) end return 0 end
    local c = shut(0)
    if n % 3 == 2 then c = math.max(c, shut(0.34)) end
    return 1 - c
end
local function cat_eye(dl, cx, cy, s, dim)
    local hh = s * 0.62
    local function c(r, g, b, a) if dim then local v = (r + g + b) / 3 return col32({ v, v, v, a or 1 }) end return col32({ r, g, b, a or 1 }) end
    local open = blink_open(os.clock())
    local N = 24
    local up, dn, lu, ld = {}, {}, {}, {}
    for i = 0, N do
        local u = -1 + 2 * i / N
        local h = hh * (1 - u * u) ^ 0.85
        up[i], dn[i] = { cx + s * u, cy - h }, { cx + s * u, cy + h }
        -- where the lids are now: the top lid does most of the closing
        lu[i] = { cx + s * u, cy - h + h * 1.15 * (1 - open) }
        ld[i] = { cx + s * u, cy + h - h * 0.85 * (1 - open) }
    end
    local white = c(0.08, 0.02, 0.05)
    for i = 0, N - 1 do
        dl:AddTriangleFilled({ cx, cy }, up[i], up[i + 1], white)
        dl:AddTriangleFilled({ cx, cy }, dn[i + 1], dn[i], white)
    end
    -- Every blink swaps the eye between its calm pink look and its "awake"
    -- look: a molten gold iris with light rippling out from a wide diamond pupil.
    local tt = os.clock() - 0.12                    -- the swap happens with the lids shut
    local awake = math.floor(tt / 4.2) % 2 == 1
    if awake then
        dl:AddCircleFilled({ cx, cy }, hh * 0.92, c(0.55, 0.30, 0.02), 28)
        dl:AddCircleFilled({ cx, cy }, hh * 0.76, c(1.00, 0.72, 0.15), 28)
        dl:AddCircleFilled({ cx, cy }, hh * 0.44, c(1.00, 0.90, 0.55), 24)
        for k = 0, 1 do                              -- two rings of light rippling outward
            local f = ((os.clock() * 0.9) + k * 0.5) % 1
            pcall(function() dl:AddCircle({ cx, cy }, hh * (0.25 + 0.65 * f), c(1, 0.95, 0.7, 0.8 * (1 - f)), 24, 1.5) end)
        end
        local dw, dh = hh * 0.30, hh * 0.70        -- a wide diamond pupil
        dl:AddQuadFilled({ cx, cy - dh }, { cx + dw, cy }, { cx, cy + dh }, { cx - dw, cy }, c(0.06, 0.03, 0.01))
    else
        dl:AddCircleFilled({ cx, cy }, hh * 0.92, c(0.55, 0.06, 0.30), 28)
        dl:AddCircleFilled({ cx, cy }, hh * 0.74, c(1.00, 0.18, 0.53), 28)
        dl:AddCircleFilled({ cx, cy }, hh * 0.40, c(1.00, 0.55, 0.78), 24)
        local pw, ph, M = hh * 0.17, hh * 0.86, 12
        local black = c(0.03, 0.01, 0.02)
        for i = 0, M - 1 do
            local v1, v2 = -1 + 2 * i / M, -1 + 2 * (i + 1) / M
            local w1, w2 = pw * (1 - v1 * v1), pw * (1 - v2 * v2)
            local y1, y2 = cy + ph * v1, cy + ph * v2
            dl:AddQuadFilled({ cx - w1, y1 }, { cx + w1, y1 }, { cx + w2, y2 }, { cx - w2, y2 }, black)
        end
    end
    if open > 0.6 then dl:AddCircleFilled({ cx - hh * 0.32, cy - hh * 0.36 }, hh * 0.13, c(1, 1, 1, 0.9), 12) end
    local edge = c(1.00, 0.35, 0.65)
    if open < 0.999 then
        -- the lids: deep violet skin from the eye's rim to where each lid is now
        local skin = c(0.24, 0.05, 0.20)
        for i = 0, N - 1 do
            dl:AddQuadFilled(up[i], up[i + 1], lu[i + 1], lu[i], skin)
            dl:AddQuadFilled(ld[i], ld[i + 1], dn[i + 1], dn[i], skin)
        end
        for i = 0, N - 1 do
            dl:AddLine(lu[i], lu[i + 1], edge, 2)
            dl:AddLine(ld[i], ld[i + 1], edge, 2)
        end
    end
    for i = 0, N - 1 do
        dl:AddLine(up[i], up[i + 1], edge, 2)
        dl:AddLine(dn[i], dn[i + 1], edge, 2)
    end
end

-- Folded: just the pink eye. Click it to open the window; drag it to move it.
local ICON = 46
local function mouse() local x, y = xy(imgui.GetMousePos()) return num(x, -1), num(y, -1) end
local eye_press = nil
local function eye_icon(dim, tooltip, on_click, on_right)
    local x, y = cursor()
    imgui.Dummy({ ICON, ICON })
    local hov = imgui.IsItemHovered() == true
    decorate(function(dl)
        cat_eye(dl, x + ICON / 2, y + ICON / 2, ICON * 0.47, dim)
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
    lines[#lines + 1] = 'Click: open  |  Drag: move'
    eye_icon(false, table.concat(lines, '\n'), maximize)
end

-- Border glow, animated: a solid hot pink neon glow round the window's edge
-- that pulses, with two bright comets racing round the border trailing light.
-- The halo sits behind the window; the comets ride on the edge line itself.
local function breath(t) return 0.5 + 0.5 * math.sin(t * 2.2) end
local function glow_col() return VERM end
-- The point at distance s along a rounded rectangle's edge (clockwise from top left).
local function edge_point(x, y, w, h, r, s)
    r = math.max(0, math.min(r, w / 2, h / 2))
    local sw, sh, q = w - 2 * r, h - 2 * r, math.pi * r / 2
    local len = 2 * (sw + sh) + 4 * q
    s = s % len
    local function arc(cx, cy, a0, d) local a = a0 + (d / q) * (math.pi / 2); return cx + math.cos(a) * r, cy + math.sin(a) * r end
    if s < sw then return x + r + s, y end; s = s - sw
    if s < q then return arc(x + w - r, y + r, -math.pi / 2, s) end; s = s - q
    if s < sh then return x + w, y + r + s end; s = s - sh
    if s < q then return arc(x + w - r, y + h - r, 0, s) end; s = s - q
    if s < sw then return x + w - r - s, y + h end; s = s - sw
    if s < q then return arc(x + r, y + h - r, math.pi / 2, s) end; s = s - q
    if s < sh then return x, y + h - r - s end; s = s - sh
    return arc(x + r, y + r, math.pi, s)
end
local function edge_length(w, h, r)
    r = math.max(0, math.min(r, w / 2, h / 2))
    return 2 * (w - 2 * r) + 2 * (h - 2 * r) + 2 * math.pi * r
end
local function border_glow(wx, wy, ww, wh, rad)
    local ok, bg = pcall(imgui.GetBackgroundDrawList)
    if not ok or bg == nil then return end
    local okf, fg = pcall(imgui.GetForegroundDrawList)
    if not okf or fg == nil then fg = bg end
    local t = os.clock()
    local p = 0.45 + 0.55 * breath(t)
    local col = glow_col()
    pcall(function()
        -- the halo spreading out from the border, pulsing and shifting color
        for i = 1, 10 do
            local o = i * 1.8
            bg:AddRect({ wx - o, wy - o }, { wx + ww + o, wy + wh + o },
                col32(alpha(col, 0.42 * (1 - i / 11) * p)), rad + o, RALL, 3.6)
        end
        -- the edge line itself, in the same shifting color
        fg:AddRect({ wx + 0.5, wy + 0.5 }, { wx + ww - 0.5, wy + wh - 0.5 },
            col32(alpha(col, 0.55 + 0.35 * p)), rad, RALL, 1.8)
        -- two comets chasing each other round the border
        local len = edge_length(ww, wh, rad)
        local speed = 140
        for c = 0, 1 do
            local head = t * speed + c * len / 2
            local cc = glow_col()
            for k = 0, 22 do
                local px, py = edge_point(wx, wy, ww, wh, rad, head - k * 4)
                local f = 1 - k / 23
                if k == 0 then
                    bg:AddCircleFilled({ px, py }, 14, col32(alpha(cc, 0.22)), 20)
                    bg:AddCircleFilled({ px, py }, 8, col32(alpha(cc, 0.35)), 16)
                end
                fg:AddCircleFilled({ px, py }, 1 + 2.6 * f, col32(alpha(k == 0 and BONE or cc, 0.9 * f)), 12)
            end
        end
    end)
end

-- The QUESTLOG wordmark: big letters that drift slowly from hot pink through
-- sunset orange to electric cyan, FFXI above it, three sunset stripes under it.
local function wordmark()
    local x, y = cursor()
    local size = 28
    local h = size + 30
    decorate(function(dl)
        local font = imgui.GetFont()
        local k = size / num(imgui.GetFontSize(), 13)
        dl:AddText({ x + 1, y }, col32(SOOT), 'F F X I')
        local ty = y + line_h() + 1
        local cx = x
        local word = 'QUESTLOG'
        local t = os.clock()
        for i = 1, #word do
            local ch = word:sub(i, i)
            local u = 0.5 + 0.5 * math.sin(t * 1.1 - i * 0.55)
            local col = u < 0.5 and mix(VERM, SUN, u * 2) or mix(SUN, ACID, (u - 0.5) * 2)
            dl:AddText(font, size, { cx, ty }, col32(col), ch)
            cx = cx + text_w(ch) * k + 1
        end
        local w = cx - x
        local by = ty + size + 3
        dl:AddRectFilled({ x, by }, { x + w, by + 3 }, col32(VERM))
        dl:AddRectFilled({ x, by + 5 }, { x + w * 0.8, by + 7 }, col32(SUN))
        dl:AddRectFilled({ x, by + 9 }, { x + w * 0.6, by + 10 }, col32(AMBER))
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

-- The line between the sidebar and the steps: faint all the way down and
-- slanted, with its top part lit in neon pink.
local function divider(dl, x, y1, y2)
    local tx, bx = x + 10, x - 14
    dl:AddLine({ tx, y1 }, { bx, y2 }, col32(alpha(BONE, 0.08)), 1)
    local k = 0.28
    local mx, my = tx + (bx - tx) * k, y1 + (y2 - y1) * k
    dl:AddLine({ tx, y1 }, { mx, my }, col32(alpha(VERM, 0.9)), 1.6)
end

-- The neon edge round the whole panel: a glow outside the border, a bright line on it.
local function panel_edge()
    local wx, wy = xy(imgui.GetWindowPos())
    local ww, wh = xy(imgui.GetWindowSize())
    if type(wx) ~= 'number' or type(ww) ~= 'number' then return end
    local rad = 0
    border_glow(wx, wy, ww, wh, rad)
    decorate(function(dl)
        dl:PushClipRect({ wx, wy }, { wx + ww, wy + wh }, false)
        pcall(function()
            dl:AddRect({ wx + 1, wy + 1 }, { wx + ww - 1, wy + wh - 1 }, col32(alpha(VERM, 0.85)), math.max(0, rad - 1), RALL, 1.6)
        end)
        dl:PopClipRect()
    end)
end

local function draw_list()
    for _, f in ipairs({ { 'active', 'Active' }, { 'all', 'All' }, { 'done', 'Done' } }) do
        if nav_row(string.format('%s %d##flt_%s', f[2]:upper(), counts[f[1]], f[1]), f[2]:upper(), counts[f[1]], S.filter == f[1]) then
            S.filter = f[1]
            settings.save()
        end
    end
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
                local open = imgui.CollapsingHeader(string.format('%s   %d###hdr_%s_%d', areas[area]:upper(), #rows, kind, area),
                    (S.filter == 'active' and (ImGuiTreeNodeFlags_DefaultOpen or 0)) or 0)
                if open then
                    for _, r in ipairs(rows) do
                        local key = entry_key(kind, r.e)
                        mark(r.st)
                        local name = (r.e.s ~= '' and r.e.s .. '  ' or '') .. r.e.t
                        if imgui.Selectable(clean(name) .. '##sel_' .. key, ui.selected == key) then
                            ui.selected = key
                            ui.sel_kind, ui.sel_entry = kind, r.e
                        end
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

local function npc_rows(npcs, my_zone, px, pz, indent)
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
            dl:AddRectFilled({ x - 6, y - 4 }, { x + 28, y + h + 4 }, col32(alpha(ACID, 0.22)), (h + 8) / 2)
            dl:AddRectFilled({ x - 4, y - 2 }, { x + 26, y + h + 2 }, col32(ACID), (h + 4) / 2)
        end)
    end
    imgui.Dummy({ 1, 1 })
    imgui.SameLine(0, 0)
    ctext(done and SOOT or (is_current and ON_ACID or ASH), string.format('%02d', i))
    imgui.SameLine(0, 14)
    local v = { done }
    local n = push_colors({ { 'ImGuiCol_FrameBg', alpha(BONE, 0.08) }, { 'ImGuiCol_FrameBgHovered', alpha(VERM, 0.30) },
                            { 'ImGuiCol_FrameBgActive', alpha(VERM, 0.45) }, { 'ImGuiCol_Border', alpha(VERM, done and 0.35 or 0.7) } })
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
        npc_rows(st.n, my_zone, px, pz, 52)
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
        ctext(ACID, coords(px, my_y, pz))
        tip('Your position: x, y, z (y = height), the server\'s !pos order.\n' .. zone_label(my_zone))
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
    tip('Minimize to the pink eye (/ql mini)')
    imgui.SameLine(0, 2)
    if round_button('x##ql_close', 'x', true) then ui.open[1] = false end
    tip('Close (type /ql to open again)')
end

local function draw_detail(my_zone, px, pz)
    local e, kind = ui.sel_entry, ui.sel_kind
    if not e then
        imgui.Spacing()
        scaled(1.3, SOOT, 'NO ENTRY SELECTED')
        ctext(ASH, 'Pick a quest or mission on the left.')
        ctext(SOOT, 'Finished steps are struck out; the cyan pill marks where you are.')
        return
    end
    local status = status_of(kind, e)
    local areas = kind == 'm' and MISSION_AREAS or QUEST_AREAS
    ctext(ASH, track((kind == 'm' and 'Mission' or 'Quest') .. ' / ' .. (areas[e.l] or '')))
    scaled(1.45, BONE, e.t)
    if e.s ~= '' then ctext(ASH, e.s) end
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
            npc_rows(e.n, my_zone, px, pz, 8)
        end
        wiki_links(e)
        return
    end

    local marks = S.marks[key]
    local done, current = log.step_states(e, status, S.cache, has_item, marks)
    local n_done = 0
    for i = 1, #steps do if done[i] then n_done = n_done + 1 end end
    imgui.SameLine(0, 14)
    ctext(n_done == #steps and CHALK or ACID, string.format('%02d', n_done))
    imgui.SameLine(0, 2)
    ctext(SOOT, string.format('/ %02d STEPS', #steps))
    step_bar(done, current, #steps)
    rule(2)
    heading('Steps')
    if not S.cache.q then
        local w = pcall(imgui.PushTextWrapPos, 0)
        pcall(ctext, VERM, 'Your quest log hasn\'t arrived yet: zone once (or log out and back in) and FFXI Questlog fills in what you\'ve started and finished.')
        if w then imgui.PopTextWrapPos() end
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
    local flags = bit.bor(ImGuiWindowFlags_NoTitleBar or 0, ImGuiWindowFlags_NoScrollbar or 0,
        S.mini and (ImGuiWindowFlags_AlwaysAutoResize or 0) or 0)
    if imgui.Begin('FFXI Questlog v' .. addon.version .. '##questlog', ui.open, flags) then
        pcall(handle_drag)
        child_depth, pushed_colors = 0, 0
        local ok, e = pcall(function()
            refresh_held(now)
            refresh_counts(now)
            if S.mini then return mini_bar() end
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
        if not S.mini then pcall(panel_edge) end   -- folded: no border, no glow
    end
    imgui.End()
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
    local ok, d = pcall(require, 'data.quests')
    if ok then data = d else err('Could not load data/quests.lua.') return end
    S = settings.load(defaults)
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
        say('/ql  show / hide  |  /ql mini  minimize / open  |  /ql find <text>  |  /ql pos <x> <y>  |  /ql opacity 30-100  |  /ql unscripted')
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
