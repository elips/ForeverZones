-- Options.lua
-- The settings window (/fz).

local _, ns = ...
local K = ns.K

local window

local function Build()
    local db = ns.db
    window = K.Window("ForeverZonesOptions", "ForeverZones", 430, 388)
    local x, y = 16, -42
    y = K.Para(window, "The type of place you're in (Forest, Desert, Stronghold...) and the type of creature you target (Beast, Undead, Elemental...), in the middle of the screen, for choosing what to wear. Out of combat only.", x, y, 396)
    K.Header(window, "Zone type", x, y)
    y = y - 22
    K.Check(window, "Show it when the type of place changes", x, y,
        function() return db.zone ~= false end,
        function(checked) db.zone = checked ns.Refresh() end,
        "A new zone, a town, a dungeon, or passing over places on a flight path.")
    y = y - 24
    K.Check(window, "And again while I'm there", x, y,
        function() return db.again ~= false end,
        function(checked) db.again = checked end,
        "Off: only when the type of place changes (and when you target a creature).")
    y = y - 28
    K.Stepper(window, "Again every", x, y,
        function() return tonumber(db.every) or 30 end,
        function(value) db.every = value end, 5, 15, 300,
        function(value) return value .. " seconds" end)
    y = y - 34
    K.Header(window, "Creature type", x, y)
    y = y - 22
    K.Check(window, "Show it when I target a creature", x, y,
        function() return db.mob ~= false end,
        function(checked) db.mob = checked ns.Refresh() end,
        "Not for players or their pets. The zone's type shows above it.")
    y = y - 24
    K.Check(window, "Friendly creatures too", x, y,
        function() return db.friendly == true end,
        function(checked) db.friendly = checked end,
        "Off: only creatures you can attack. On: vendors, guards and quest givers as well.")
    y = y - 34
    K.Header(window, "Both", x, y)
    y = y - 22
    K.Stepper(window, "Shown for", x, y,
        function() return tonumber(db.seconds) or 5 end,
        function(value) db.seconds = value end, 1, 2, 15,
        function(value) return value .. " seconds" end)
    y = y - 26
    K.Stepper(window, "Text size", x, y,
        function() return tonumber(db.size) or 24 end,
        function(value) db.size = value ns.Refresh() end, 2, 14, 44)
    y = y - 36
    K.Button(window, "Test", 80, x, y, function() ns.Test() end, "Both lines for a few seconds.")
    K.Button(window, "Move", 80, x + 90, y, function()
        if K.inCombat then
            K.Print("not in combat.")
            return
        end
        ns.Move()
    end, "A blue box where the lines show: drag it, then click Move again.")
    K.Button(window, "What is this place?", 150, x + 180, y, function() ns.Where() end,
        "Says in chat what type of place this is and which names it was found by.")
end

function ns.ToggleOptions()
    if not window then
        Build()
    end
    if window:IsShown() then
        window:Hide()
    else
        window:Show()
    end
    return window
end
