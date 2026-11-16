-- Data.lua
-- The lists ForeverZones works from. This is the file to edit when a patch
-- changes them.
--
-- Zone types: the game has no way for an addon to ask "what type of place
-- is this". Each type is a fixed list of zones, towns, dungeons and raids in
-- the game's files, and those lists are copied here (from build 1.60.1).
-- A place can be on several lists (Tirisfal Glades is Forest, Wasteland and
-- Haunted). A town or a dungeon adds its own types to its zone's.
-- Names are matched without a leading "The", in any letter case.
--
-- To add a place: put its name, as the game writes it, on each list it
-- belongs to. To add a type: add a line to TYPES (its place in TYPES is
-- its place on screen) and a list of the same key to PLACES.

local _, ns = ...

-- In the order they're shown.
ns.TYPES = {
    { key = "forest", label = "Forest", color = { 0.38, 0.86, 0.32 } },
    { key = "swamp", label = "Swamp", color = { 0.36, 0.74, 0.60 } },
    { key = "wasteland", label = "Wasteland", color = { 0.76, 0.64, 0.46 } },
    { key = "desert", label = "Desert", color = { 0.98, 0.88, 0.52 } },
    { key = "mountain", label = "Mountain", color = { 0.62, 0.72, 0.88 } },
    { key = "snowy", label = "Snowy", color = { 0.84, 0.95, 1.00 } },
    { key = "haunted", label = "Haunted", color = { 0.72, 0.54, 0.96 } },
    { key = "stronghold", label = "Stronghold", color = { 0.90, 0.50, 0.38 } },
    { key = "underground", label = "Underground", color = { 1.00, 0.64, 0.18 } },
    { key = "volcanic", label = "Volcanic", color = { 1.00, 0.36, 0.20 } },
}

-- The game's lists. (In its words: Forest and Grassland, Swamp, Wasteland,
-- Desert, Mountainous, Snowy, Haunted, Strongholds and Cities, Cavernous or
-- Underground. Volcanic has no list yet.)
ns.PLACES = {
    forest = { "Arathi Highlands", "Ashenvale", "Azshara", "Darkshore", "Darkspear Islands", "Dun Morogh", "Duskwood",
        "Dustwallow Marsh", "Eastern Plaguelands", "Elwynn Forest", "Felwood", "Feralas", "Hillsbrad Foothills",
        "Loch Modan", "Moonglade", "Mount Hyjal", "Mulgore", "Redridge Mountains", "Riverglades", "Shen'dralas",
        "Silverpine Forest", "Stonetalon Mountains", "Stranglethorn Vale", "Swamp of Sorrows", "Teldrassil", "Thalanaar",
        "The Hinterlands", "Tirisfal Glades", "Un'Goro Crater", "Western Plaguelands", "Westfall", "Wetlands",
        "Winterspring", "Zephras Isle",
        "Alterac Valley", "Arathi Basin", "Blackmaw Hold", "Booty Bay", "Darnassus", "Dire Maul",
        "Excavation Site: Wetlands", "Gilneas", "Krol'dok Stronghold", "Ruins of Gilneas", "Shadowfang Keep",
        "Stormwind City", "The Shaper's Terrace", "Valanaar", "Warsong Gulch", "Zul'Gurub" },
    swamp = { "Darkshore", "Dustwallow Marsh", "Feralas", "Riverglades", "Swamp of Sorrows", "Un'Goro Crater", "Wetlands",
        "Excavation Site: Wetlands", "Maraudon", "The Drowned City", "The Shaper's Terrace", "The Temple of Atal'Hakkar",
        "Wailing Caverns" },
    wasteland = { "Badlands", "Blasted Lands", "Burning Steppes", "Deadwind Pass", "Desolace", "Durotar",
        "Eastern Plaguelands", "Felwood", "Searing Gorge", "Shen'dralas", "Silithus", "Silverpine Forest", "Tanaris",
        "The Barrens", "Tirisfal Glades", "Western Plaguelands", "Westfall",
        "Orgrimmar", "Razorfen Downs", "Razorfen Kraul", "Ruins of Lordaeron", "Stratholme", "Undercity", "Zul'Farrak" },
    desert = { "Badlands", "Blasted Lands", "Desolace", "Durotar", "Silithus", "Tanaris", "The Barrens", "Thousand Needles",
        "Ahn'Qiraj", "Gates of Ahn'Qiraj", "Orgrimmar", "Ruins of Ahn'Qiraj", "Temple of Ahn'Qiraj", "Uldaman",
        "Zul'Farrak" },
    mountain = { "Alterac Mountains", "Arathi Highlands", "Azshara", "Badlands", "Burning Steppes", "Deadwind Pass",
        "Dun Morogh", "Hillsbrad Foothills", "Loch Modan", "Mount Hyjal", "Mulgore", "Redridge Mountains", "Searing Gorge",
        "Stonetalon Mountains", "Stranglethorn Vale", "The Barrens", "The Hinterlands", "Thousand Needles", "Winterspring",
        "Zephras Isle",
        "Alterac Valley", "Arathi Basin", "Blackmaw Hold", "Blackrock Mountain", "Krol'dok Stronghold", "Thunder Bluff" },
    snowy = { "Alterac Mountains", "Dun Morogh", "Winterspring", "Alterac Valley" },
    haunted = { "Deadwind Pass", "Duskwood", "Eastern Plaguelands", "Felwood", "Shen'dralas", "Silverpine Forest",
        "Swamp of Sorrows", "Tirisfal Glades", "Western Plaguelands",
        "Dire Maul", "Gilneas", "Maraudon", "Naxxramas", "Razorfen Downs", "Ruins of Gilneas", "Ruins of Lordaeron",
        "Scarlet Monastery", "Scholomance", "Shadowfang Keep", "Stratholme", "The Drowned City", "The Hall of Thanes",
        "The Temple of Atal'Hakkar", "Undercity", "Zul'Farrak", "Zul'Gurub" },
    stronghold = { "Ahn'Qiraj", "Alcaz Prison", "Blackfathom Deeps", "Blackmaw Hold", "Blackrock Depths",
        "Blackrock Mountain", "Blackrock Spire", "Blackwing Lair", "Booty Bay", "City of Dalaran", "Darnassus", "Dire Maul",
        "Everlook", "Gadgetzan", "Gates of Ahn'Qiraj", "Gilneas", "Gnomeregan", "Ironforge", "Krol'dok Stronghold",
        "Naxxramas", "Orgrimmar", "Razorfen Downs", "Razorfen Kraul", "Ruins of Ahn'Qiraj", "Ruins of Gilneas",
        "Ruins of Lordaeron", "Scarlet Monastery", "Scholomance", "Shadowfang Keep", "Stormwind City", "Stratholme",
        "Temple of Ahn'Qiraj", "The Deadmines", "The Drowned City", "The Hall of Thanes", "The Stockade",
        "The Temple of Atal'Hakkar", "Thunder Bluff", "Uldaman", "Undercity", "Valanaar", "Warsong Gulch", "Zul'Farrak",
        "Zul'Gurub" },
    underground = { "Alcaz Prison", "Blackmaw Hold", "Blackrock Depths", "Blackrock Spire", "Blackwing Lair", "Gnomeregan",
        "Ironforge", "Maraudon", "Molten Core", "Onyxia's Lair", "Ragefire Chasm", "The Deadmines", "The Hall of Thanes",
        "The Stockade", "Uldaman", "Undercity", "Wailing Caverns" },
    volcanic = {},
}
-- Other names the same places go by.
ns.ALSO = {
    ["Sunken Temple"] = "The Temple of Atal'Hakkar",
    ["Stormwind Stockade"] = "The Stockade",
    ["Stormwind Stockades"] = "The Stockade",
    ["The Stockades"] = "The Stockade",
    ["Alcaz Island Prison"] = "Alcaz Prison",
    ["Dalaran"] = "City of Dalaran",
    ["Stormwind"] = "Stormwind City",
    ["Echo Isles"] = "Darkspear Islands",
}

-- Creature types, in the game's English names.
ns.MOBS = {
    Beast = { 0.84, 0.62, 0.36 },
    Humanoid = { 0.98, 0.87, 0.72 },
    Undead = { 0.74, 0.58, 0.96 },
    Elemental = { 0.38, 0.86, 1.00 },
    Demon = { 0.58, 0.96, 0.22 },
    Dragonkin = { 1.00, 0.46, 0.26 },
    Giant = { 0.78, 0.74, 0.66 },
    Mechanical = { 0.72, 0.82, 0.92 },
    Critter = { 0.76, 0.76, 0.76 },
    Aberration = { 0.96, 0.46, 0.80 },
}
ns.NOT_A_TYPE = { ["Not specified"] = true, ["Non-combat Pet"] = true, ["Gas Cloud"] = true, ["Totem"] = true,
    ["Wild Pet"] = true, [""] = true }
ns.OTHER_MOB = { 1.00, 0.82, 0.30 }

