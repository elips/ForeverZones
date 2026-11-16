# ForeverZones

A small addon for **WoW: Forever** that tells you two things, in the middle of the screen, when they matter for what you wear:

- **The type of place you're in**: Forest, Swamp, Wasteland, Desert, Mountain, Snowy, Haunted, Stronghold, Underground. Many of Forever's items get a bonus by the type of place. A place can be several types at once (Tirisfal Glades is Forest, Wasteland and Haunted), and each is shown in its own color.
- **The type of creature you target**: Beast, Humanoid, Undead, Elemental, Demon, Dragonkin, Giant, Mechanical and so on, each in its own color.

Works for every class. Out of combat only: nothing shows during a fight.

## What it does

- The zone's type shows for 5 seconds whenever the type of place changes: a new zone, walking into a town or a dungeon, or passing over places on a flight path.
- While you stay there, it shows again for 5 seconds every 30 seconds.
- Target a creature you can attack and its type shows under the zone's type for 5 seconds, so both are in front of you at once. Not for players or their pets.
- Walk into somewhere new during a fight and it shows when the fight ends.

## Commands

| Command | What it does |
| --- | --- |
| `/fz` | Opens the settings |
| `/fz where` | Says in chat what type of place this is, and which names it was found by |
| `/fz test` | Shows both lines for a few seconds |
| `/fz move` | A blue box where the lines show: drag it, then `/fz move` again |
| `/fz reset` | Settings and position back to how they came |

## Settings

- Zone type: on or off; whether it comes back while you're there, and how often (15 to 300 seconds).
- Creature type: on or off; whether friendly creatures (vendors, guards) count too.
- How long the lines stay (2 to 15 seconds) and the text size.

## Where the zone types come from

The game has no way for an addon to ask "what type of place is this". Each type is a fixed list of zones, towns, dungeons and raids in the game's files, and those lists (from build 1.60.1) are copied into `Data.lua`. A town or a dungeon adds its own types to its zone's: Booty Bay is a Stronghold in a Forest.

That means the lists can be wrong or go out of date when a patch changes them. If the line doesn't match what your items say, stand there, type `/fz where`, and report what it prints. The game's Volcanic type has no list yet, so it never shows.

Creature types are read from the game each time, so they are always right.

## Install

Put the `ForeverZones` folder in `World of Warcraft\_forever_\Interface\AddOns\` and restart the game.
