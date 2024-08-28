---
title: "Minecraft Servers"
---

!!! info
    [itzg Minecraft Server docker docs](https://docker-minecraft-server.readthedocs.io/en/latest/) |
    [itzg Minecraft Server source](https://github.com/itzg/docker-minecraft-server/)

## Recommended mods

### Gameplay

- Distant Horizons: infinite render distance.
- Shaders
- Create: vanilla like tech mod with nice visuals and free-form  progression that fits right in.

### Server Admin

- Chunky: pregenerate chunks.
- WorldEdit: copy, paste, use schematics, reset chunks, etc.
- Sethome or waystones: teleport for players.

## Server admin tweaks and tips

### Useful gamerules

Set how many players have to be sleeping to skip a night: `/gamerule playersSleepingPercentage 30`

To keep inventory after dying: `/gamerule keepInventory true`

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
