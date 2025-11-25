# Cupcakes Framework

<p align="center">
<img src=".github/cupcake_logo.svg" width="577" alt="Cupcakes Framework logo">
</p>

A Five Nights at Freddy's (or FNAF) framework made for Godot 4, with a [Godot 3 version also available](https://github.com/Oplexitie/Cupcakes-Framework/tree/godot3).

>[!IMPORTANT]
>This framework only contains the very basic necessities to build your FNAF inspired game.
>As such, I will not be adding any features that :
>  - A - Are very easy to make on your own
>  - B - Are not necessary for a FNAF like game
>  - C - Make the project a convoluted mess

## Features

- Office
  - A simple scrolling system where the speed is based on how close your mouse is to the screens edge
  - An equirectangular perspective shader (an alternative version with pitch can be found [here](https://gist.github.com/Oplexitie/a856b013fd9190414cbbdb829420a94c))
- Camera System
  - A simple camera system that can be easily expanded to include more rooms
  - Camera movement (like in FNAF 1)

## Documentation

- **`TARUNA_SETUP_GUIDE.md`** - Complete setup instructions for adding anomalies
- **`TARUNA_SUMMARY.md`** - Full implementation summary and next steps
- **`QUICK_DEBUG.md`** - Debugging guide with solutions
- **`IMPLEMENTATION_GUIDE.md`** - Original FNAF 1 framework documentation
- **`ASSET_TODO_LIST.md`** - Asset requirements checklist

## Quick Start

1. Open `Scenes/Nights/nights.tscn` in Godot 4
2. Follow **`TARUNA_SETUP_GUIDE.md`** to add anomaly nodes
3. Set `use_manual_levels = true` in CharacterAI for testing
4. Run scene (F6) and check Output console for anomaly movement
5. Add graphics gradually using placeholders

## Current Status

**Fully Implemented:**
- Complete AI system for all 6 anomalies
- Camera detection across 13 rooms
- Interactive fix mechanics
- Menu system with save/load
- Door and power mechanics
- Jumpscare system framework

**Needs Assets:**
- Camera room graphics (24 sprite frames total)
- Anomaly sprites and animations
- Jumpscare animations
- Sound effects and audio

## Development

This is a work in progress. The code is complete, but assets are being added gradually.

For help, join the [discord server](https://discord.gg/CHgH8KJyqE).

Feel free to leave feedback!
# five-nights-at-taruna
