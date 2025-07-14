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
- Mouse Tweaks: dragging mechanics and inventory moving
- Any inventory sorting mod
- Stack to Nearby Chests
- Stack Refill: Automatically refills the player's hand when using the final item if a replacement exists
- InvMove: move with inventory open
- FallingTree or other to cut down full trees instead of block by block
- Any mini- and/or worldmap mod

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

## Better Adventures Modpack

Stripped down version of flowstatevideo's [Better Adventures+]([Better Adventures+](https://www.curseforge.com/minecraft/modpacks/better-adventures-plus/)) since it was a little overblown and included some mods that are unreasonably heavy on CPU (particle mods) or caused specific lag problems.

### QoL0

- Stack refill
- You're in grave danger (graves)
- Horseman
- Easy Anvils
- Easy Magic
- Easy Shulker Boxes
- Jump Over Fences
- Blur+
- InvMove
- Nemo's Inventory Sorting
- Indypets
- Lootr
- Briding mod
- Mouse Tweaks
- Mouse Wheelie
- Formidable Farmland
- RightClickHarvest
- Tree Harvester
- Polymorph
- (extra) Amendments
- VanillaTweaks
- Friendly Phantoms
- Memory Settings
- Better Third Person
- Aileron
- Cubes Without Borders
- Better F3 Plus
- Dynamic Crosshair
- Better Combat

### Deco/building

- Clutter
- Supplementaries

### Visual/atmosphere

- Distant Horizons
- Photon Shaders
- Ambient sounds
- Spawn animations
- Terrain slabs
- (extra) Nature's Spirit
- Not Enough Animations
- (extra) Lithostitched
- (extra) Cool Rain (rain sounds on different materials)
- Camera Overhaul
- Presence Footsteps
- Cull Less Leaves
- SuperBetterGrass
- (very heavy on low end) Particle Rain
- Sound Physics Remastered
- More Mob Variants
- Adaptive Tooltips
- Chirpy's Wildlife
- Mooshroom Spawn

### Social

- Mighty Mail
- What are they up to
- Chat Image
- Shoppy
- Mc2Discord

### Gameplay

- Tide (fishing)
- LevelZ (level up) or Pufferfish skills
- Exposure
- Applied Energistics 2 (for better storage)
- Traveler's backpack
- Farmer's Delight
- Little Joys
- Waystones
- Nyf's Spiders
- Xaero's map and minimap
- Create
- Majrusz's Enchantments + Universal Enchants
- Majrusz's Accessories
- Extra Alchemy
- Trinkets
- Randomium Ore
- Craftable Experience Bottle + Uhm..Did i just get experience ? + Exp Ore + Experienced Crops + Tax Free Levels
- Artifacts (rare loot)
- The Aether
- Better Archeology
- Dis-Enchanting Table
- Critters and Companions
- Only Hammers and Excavators
- Effortless Structure
- Naturalist

### World Generation

- Regions Unexplored
- Biomes O' Plenty
- Tectonic (especially with dh)
- Dungeon now loading
- Bosses of Mass Destruction
- YUNG's better collection
- William Wythers' Expanded Ecosphere + William Wythers' Overhauled Overworld
- ChoiceTheorem's Overhauled Village
- Incendium (nether biomes overhaul)
- BetterNether
- BetterEnd
- Aquamirae

### Resource Packs

- Fresh Animations
- Fresh Moves
- (Bee's) Fancy Crops
- Enchant Icons
- Fresh Compats
- More Mob Variants x Fresh Animations
- Overlay’s
- F.M.R.P

### Optimizations

- Fast Item Frames
- ModernFix
- BadOptimizations
- Entity Culling
- More Culling
- Clumps
- C2me
- noisium
- Memory Leak Fix
- Sodium + Indium + Enhanced Block Entities
- Enhanced Block Entities
- ImmediatelyFast

### Server

- Server Performance - Smooth Chunk Save
- Chunky + Chunky Border
- Worldedit
- Ready player fun (pause without alert spam)
- Enchanting Commands
- ServerCore
- BetterDays
- Krypton
- Starlight

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
