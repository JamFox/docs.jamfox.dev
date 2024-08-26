---
title: "Minecraft Servers"
---

## Recommended mods

### Gameplay

Distant Horizons

Shaders

Create

### Server Admin

Chunky

WorldEdit

Sethome

## Server admin tweaks and tips

### Set how many people need to be sleeping

In chat: `/gamerule playersSleepingPercentage 30`

## Change level type on existing world

1. Get NBT Studio (or other NBT editor): https://github.com/tryashtar/nbt-studio
2. Generate world with desired world gen algorithm
3. Stop server
4. Open your world and new worlds level.dat in NBT editor
5. Copy 'level-desired.dat > Data > WorldGenSettings > dimensions' to your level.dat
6. Save and reboot 

## Reset chunks

1. Get MCA Selector: https://github.com/Querz/mcaselector
2. Select (manually or with filters) chunks
3. Delete selected chunks
