-- ForeverZones.lua
-- Two alert lines in the middle of the screen, for choosing what to wear:
--
--   the zone's type   Forest, Desert, Stronghold... Forever's items get
--                     bonuses by the type of place you are in. Shown when
--                     the type of place changes (a new zone, a town, a
--                     dungeon, passing over places on a flight path), and
--                     then for a few seconds every half minute while you're
--                     out of combat.
--   the mob's type    Beast, Undead, Elemental... Shown under it when you
--                     target a creature out of combat (with the zone's type
--                     above, so both are in front of you at once).
--
-- Never in combat. The lists of which places are which type are in Data.lua.
-- /fz opens the settings; /fz where says what this place is.

local _, ns = ...
local K = ns.K

K.title = "ForeverZones"

local DEFAULTS = { zone = true, again = true, mob = true, friendly = false, every = 30, seconds = 5, size = 24 }
local SPOT = { "CENTER", "CENTER", 0, 256 }
local FADE_IN, FADE_OUT = 0.2, 0.6

local db
local TYPES, MOBS = ns.TYPES, ns.MOBS
local TYPE = {}
for _, entry in ipairs(TYPES) do
    TYPE[entry.key] = entry
end

-- "The Barrens" and "Barrens" are one place; so are "Deadmines" and "The Deadmines".
local function Norm(name)
    name = name:lower():gsub("^%s+", ""):gsub("%s+$", "")
    name = name:gsub("^the ", "")
    return name
end

local byPlace = {}   -- normalized name -> { type key = true }
for key, list in pairs(ns.PLACES) do
    for _, name in ipairs(list) do
        local norm = Norm(name)
        byPlace[norm] = byPlace[norm] or {}
        byPlace[norm][key] = true
    end
end
for other, name in pairs(ns.ALSO) do
    byPlace[Norm(other)] = byPlace[Norm(name)]
end

local status = { shown = 0, mobs = 0 }

local function Seconds()
    return tonumber(db.seconds) or DEFAULTS.seconds
end

local function Every()
    return tonumber(db.every) or DEFAULTS.every
end

------------------------------------------------------------------------------
-- What type of place this is
------------------------------------------------------------------------------

local function Text(name)
    local fn = rawget(_G, name)
    if not fn then
        return nil
    end
    local ok, text = pcall(fn)
    text = ok and K.Str(text) or nil
    return (text and text ~= "") and text or nil
end

local function TypesOf(name, into, matched)
    if not name then
        return
    end
    local found = byPlace[Norm(name)]
    if not found then
        -- "Scarlet Monastery: Cathedral", "Dire Maul - East"
        local head = name:match("^(.-)%s*[:%-]%s")
        found = head and byPlace[Norm(head)]
    end
    if found then
        for key in pairs(found) do
            into[key] = true
        end
        matched[#matched + 1] = name
    end
end

-- The types of where you are, in order; the names they were found by; and
-- the zone's name.
local function Here()
    local set, matched = {}, {}
    local zone, real = Text("GetZoneText"), Text("GetRealZoneText")
    TypesOf(real, set, matched)
    if zone ~= real then
        TypesOf(zone, set, matched)
    end
    local sub, mini = Text("GetSubZoneText"), Text("GetMinimapZoneText")
    if sub ~= real and sub ~= zone then
        TypesOf(sub, set, matched)
    end
    if mini ~= sub and mini ~= real and mini ~= zone then
        TypesOf(mini, set, matched)
    end
    local info = rawget(_G, "GetInstanceInfo")
    if info then
        local ok, name, kind = pcall(info)
        name, kind = ok and K.Str(name) or nil, ok and K.Str(kind) or nil
        if name and kind and kind ~= "none" and name ~= real and name ~= zone then
            TypesOf(name, set, matched)
        end
    end
    local list = {}
    for _, entry in ipairs(TYPES) do
        if set[entry.key] then
            list[#list + 1] = entry
        end
    end
    return list, matched, real or zone
end

local function Hex(color)
    return string.format("|cff%02x%02x%02x", math.floor(color[1] * 255 + 0.5), math.floor(color[2] * 255 + 0.5),
        math.floor(color[3] * 255 + 0.5))
end

local function ZoneLine(list)
    local parts = {}
    for index, entry in ipairs(list) do
        parts[index] = Hex(entry.color) .. entry.label .. "|r"
    end
    return table.concat(parts, " |cff8a8a8a\194\183|r ")
end

------------------------------------------------------------------------------
-- The two lines
------------------------------------------------------------------------------

local frame, dragBox
local zoneText, zoneKey = "", ""   -- what the zone line says; which place and types it's for
local zoneFrom, zoneUntil = 0, 0
local mobFrom, mobUntil = 0, 0
local nextRepeat = 0
local pendingZone = false

local function Alpha(now, from, till)
    if now >= till then
        return 0
    end
    local alpha = 1
    if now - from < FADE_IN then
        alpha = (now - from) / FADE_IN
    end
    if till - now < FADE_OUT then
        alpha = math.min(alpha, (till - now) / FADE_OUT)
    end
    return alpha
end

local function ApplyFont()
    if not frame then
        return
    end
    local size = tonumber(db.size) or DEFAULTS.size
    for _, line in ipairs({ frame.zone, frame.mob }) do
        local font = line:GetFont()
        line:SetFont(font or "Fonts\\FRIZQT__.TTF", line == frame.zone and size or math.floor(size * 0.86 + 0.5), "OUTLINE")
    end
    frame:SetSize(420, size * 2 + 10)
    frame.mob:ClearAllPoints()
    frame.mob:SetPoint("TOP", frame.zone, "BOTTOM", 0, -4)
end

local function Build()
    frame = CreateFrame("Frame", "ForeverZonesAlert", UIParent)
    frame:SetFrameStrata("HIGH")
    K.Place(frame, db.pos, SPOT)
    frame.zone = frame:CreateFontString(nil, "OVERLAY", "GameFontNormalHuge")
    frame.zone:SetPoint("TOP", frame, "TOP", 0, 0)
    frame.mob = frame:CreateFontString(nil, "OVERLAY", "GameFontNormalHuge")
    for _, line in ipairs({ frame.zone, frame.mob }) do
        line:SetShadowColor(0, 0, 0, 1)
        line:SetShadowOffset(1, -1)
        line:SetAlpha(0)
    end
    ApplyFont()
    frame:SetScript("OnUpdate", function(self)
        local now = GetTime()
        self.zone:SetAlpha(Alpha(now, zoneFrom, zoneUntil))
        self.mob:SetAlpha(Alpha(now, mobFrom, mobUntil))
        if now >= zoneUntil and now >= mobUntil and not (dragBox and dragBox:IsShown()) then
            self:Hide()
        end
    end)
    frame:Hide()
end

local function ShowZone(now, seconds)
    if zoneText == "" or db.zone == false then
        return false
    end
    if not frame then
        Build()
    end
    frame.zone:SetText(zoneText)
    -- (Already up: it stays up, without fading in again.)
    if now >= zoneUntil then
        zoneFrom = now
    end
    zoneUntil = math.max(zoneUntil, now + seconds)
    frame:Show()
    status.shown = status.shown + 1
    return true
end

local function HideAll()
    zoneUntil, mobUntil = 0, 0
    if frame and not (dragBox and dragBox:IsShown()) then
        frame.zone:SetAlpha(0)
        frame.mob:SetAlpha(0)
        frame:Hide()
    end
end

-- Works out where you are. Somewhere of other types than a moment ago (or a
-- new zone): the line shows, and the half-minute count starts from here.
local function Where(force)
    local list, matched, name = Here()
    local text = ZoneLine(list)
    local key = (name or "") .. "|" .. text
    status.matched = matched
    if key == zoneKey and not force then
        return
    end
    zoneKey, zoneText = key, text
    if zoneText == "" then
        zoneUntil = 0
    end
    if K.inCombat then
        pendingZone = true
        return
    end
    local now = GetTime()
    ShowZone(now, Seconds())
    nextRepeat = now + Every()
end

local whereSoon = false
local function WhereNow()
    whereSoon = false
    if db then
        Where(false)
    end
end
local function WhereSoon()
    if whereSoon then
        return
    end
    whereSoon = true
    -- (The zone's names settle a moment after the event.)
    C_Timer.After(0.5, WhereNow)
end

-- Once a second: is it time for the half-minute showing?
local function Beat()
    C_Timer.After(1, Beat)
    if K.inCombat or not db or db.zone == false or db.again == false then
        return
    end
    local now = GetTime()
    if now >= nextRepeat then
        nextRepeat = now + Every()
        ShowZone(now, Seconds())
    end
end

------------------------------------------------------------------------------
-- The mob's type
------------------------------------------------------------------------------

local function MobType()
    if not K.Bool(UnitExists("target"), false) then
        return nil
    end
    -- Not players, and not their pets.
    if K.Bool(UnitIsPlayer("target"), true) or K.Bool(UnitPlayerControlled("target"), true) then
        return nil
    end
    if db.friendly ~= true and not K.Bool(UnitCanAttack("player", "target"), false) then
        return nil
    end
    local get = rawget(_G, "UnitCreatureType")
    if not get then
        return nil
    end
    local ok, kind = pcall(get, "target")
    kind = ok and K.Str(kind) or nil
    if not kind or ns.NOT_A_TYPE[kind] then
        return nil
    end
    return kind
end

local function Target()
    if K.inCombat or not db or db.mob == false then
        return
    end
    local kind = MobType()
    if not kind then
        mobUntil = 0
        return
    end
    if not frame then
        Build()
    end
    local now, seconds = GetTime(), Seconds()
    frame.mob:SetText(Hex(MOBS[kind] or ns.OTHER_MOB) .. kind .. "|r")
    if now >= mobUntil then
        mobFrom = now
    end
    mobUntil = now + seconds
    frame:Show()
    status.mobs = status.mobs + 1
    -- The zone's type above it, for as long.
    ShowZone(now, seconds)
end

------------------------------------------------------------------------------
-- Test, move, where
------------------------------------------------------------------------------

-- Both lines for a few seconds, wherever you are.
function ns.Test()
    if not frame then
        Build()
    end
    local now = GetTime()
    frame.zone:SetText(zoneText ~= "" and zoneText or ZoneLine({ TYPE.forest, TYPE.haunted }))
    zoneFrom, zoneUntil = now, now + Seconds()
    frame.mob:SetText(Hex(MOBS.Undead) .. "Undead|r")
    mobFrom, mobUntil = now, now + Seconds()
    frame:Show()
end

-- A blue box where the lines show: drag it. Again (or a fight) puts it away.
function ns.Move(on)
    if not frame then
        Build()
    end
    if not dragBox then
        dragBox = K.DragBox(frame, "ForeverZones  (drag me; /fz move when done)", function(x, y)
            db.pos = { x, y }
            K.Place(frame, db.pos, SPOT)
        end)
    end
    if on == nil then
        on = not dragBox:IsShown()
    end
    if on then
        frame:Show()
        dragBox:Show()
    else
        dragBox:Hide()
    end
    return on
end

function ns.Where()
    Where(true)
    local list, matched, name = Here()
    if #list == 0 then
        K.Print(string.format("%s isn't on any of the zone type lists.", tostring(name or "This place")))
    else
        K.Print(string.format("%s: %s (found by: %s).", tostring(name or "Here"), ZoneLine(list), table.concat(matched, ", ")))
    end
end

function ns.Refresh()
    ApplyFont()
    if db.zone == false then
        zoneUntil = 0
    end
    if db.mob == false then
        mobUntil = 0
    end
end

function ns.Reset()
    for key in pairs(db) do
        db[key] = nil
    end
    for key, value in pairs(DEFAULTS) do
        db[key] = value
    end
    if frame then
        K.Place(frame, db.pos, SPOT)
    end
    ns.Refresh()
end

------------------------------------------------------------------------------
-- Start-up
------------------------------------------------------------------------------

K.On("ADDON_LOADED", function(name)
    if name ~= "ForeverZones" or db then
        return
    end
    local first = rawget(_G, "ForeverZonesDB") == nil
    db = K.Settings("ForeverZonesDB", DEFAULTS)
    ns.db = db
    if first then
        K.Print("zone and mob types will show in the middle of the screen. /fz for settings.")
    end
    C_Timer.After(1, Beat)
end)

for _, event in ipairs({ "PLAYER_ENTERING_WORLD", "ZONE_CHANGED_NEW_AREA", "ZONE_CHANGED", "ZONE_CHANGED_INDOORS" }) do
    K.On(event, WhereSoon)
end
K.On("PLAYER_TARGET_CHANGED", Target)
K.On("PLAYER_REGEN_DISABLED", function()
    if dragBox then
        dragBox:Hide()
    end
    HideAll()
end)
K.On("PLAYER_REGEN_ENABLED", function()
    if pendingZone and db then
        -- Somewhere new, walked into mid-fight.
        pendingZone = false
        local now = GetTime()
        ShowZone(now, Seconds())
        nextRepeat = now + Every()
    end
end)

SLASH_FOREVERZONES1 = "/fz"
SLASH_FOREVERZONES2 = "/foreverzones"
SlashCmdList["FOREVERZONES"] = function(message)
    local command = (message or ""):lower():match("^%s*(%S*)")
    if not db then
        return
    end
    if command == "test" then
        ns.Test()
    elseif command == "move" then
        if K.inCombat then
            K.Print("not in combat.")
        elseif ns.Move() then
            K.Print("drag the blue box; /fz move again when it's where you want it.")
        else
            K.Print("locked in place.")
        end
    elseif command == "where" or command == "zone" then
        ns.Where()
    elseif command == "reset" then
        ns.Reset()
        K.Print("settings and position are back to how they came.")
    elseif command == "help" or command == "?" then
        K.Print("/fz: settings. /fz where: what type of place this is. /fz test: both lines. /fz move: move them. /fz reset: start over.")
    else
        ns.ToggleOptions()
    end
end

ns.internals = {
    Here = Here,
    Frame = function() return frame end,
    Times = function() return zoneUntil, mobUntil, nextRepeat end,
    DragBox = function() return dragBox end,
    status = status,
}
