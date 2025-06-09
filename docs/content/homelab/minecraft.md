---
title: "Minecraft Servers"
---

!!! info
    [itzg Minecraft Server docker docs](https://docker-minecraft-server.readthedocs.io/en/latest/) |
    [itzg Minecraft Server source](https://github.com/itzg/docker-minecraft-server/)

## Recommended mods

### Gameplay

- Distant Horizons: "infinite" render distance.
- Shaders
- Create: vanilla like tech mod with nice visuals and free-form  progression that fits right in
- Animation mods: add more/better animations
- Physics mod: add interactivity and make physics objects out of a lot of blocks and entities

### Engagement

- DynMap: Live map webserver
- Minecraft to Discord bot: chat with players in the server from Discord

### Surprises

- Backrooms dimension: suffocation can teleport to backroom dimension
- From the Fog: Adds Herobrine 
- Jesus Roulette: chance to save player from death
- Pickpocket: stealing from other players
- Bartering/Trading stations: trade between players
- Mystical Oak Tree
- Little Joys

### Server Admin

- Chunky: pregenerate chunks.
- WorldEdit: copy, paste, use schematics, reset chunks, etc.
- Sethome or waystones: teleport for players.

## Server admin tweaks and tips

### Useful gamerules

Set how many players have to be sleeping to skip a night: `/gamerule playersSleepingPercentage 30`

To keep inventory after dying: `/gamerule keepInventory true`

To keep XP after death: `/gamerule keepXPAfterDeath true`

Add a stat to scoreboard (seen on TAB press), for example number of deaths:

```
/scoreboard objectives add Death_Counter deathCount
/scoreboard objectives setdisplay list Death_Counter
```

## Change level type on existing world

1. Get [NBT Studio](https://github.com/tryashtar/nbt-studio) (or other NBT editor)
2. Generate world with desired world gen algorithm
3. Stop server
4. Open your world and new worlds level.dat in NBT editor
5. Copy 'level-desired.dat > Data > WorldGenSettings > dimensions' to your level.dat
6. Save and reboot 

## Reset chunks

1. Get [MCA Selector](https://github.com/Querz/mcaselector)
2. Select chunks (manually or with filters)
3. Delete selected chunks
4. Save world and play
