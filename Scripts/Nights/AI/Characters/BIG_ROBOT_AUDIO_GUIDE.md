# Big Robot Audio Guide

## Overview

Added random movement sounds for Big Robot (Freddy-like character) that play whenever he moves between rooms.

## Features Added

### Random Movement Sounds
- **Multiple sounds**: Uses an array to store different sounds (laughs, growls, mechanical noises)
- **Random selection**: Picks one sound randomly from the array each time he moves
- **Configurable chance**: Can set probability of sound playing (0.0 = never, 1.0 = always)
- **Adjustable volume**: Set volume in dB

## How It Works

Just like Freddy in FNAF 1:
1. Big Robot moves to a new room
2. Random sound plays from the array
3. Player hears the laugh/growl
4. Player knows Big Robot has moved (even without checking cameras)

## Setup Instructions

### Step 1: Find Big Robot in Scene

Open `Scenes/Nights/nights.tscn`:
1. Find the `BigRobot` node (should be in CharacterAI)
2. Select it

### Step 2: Configure Audio Settings

In the Inspector, you'll see new exports:

- **Movement Sounds**: Array of AudioStream files
  - Click to expand the array
  - Add multiple sound files (recommended: 3-5 different sounds)
  - Each sound should be different (laugh1, laugh2, growl, etc.)

- **Movement Sound Volume**: Volume in dB (default: -8.0)
  - Adjust to make sounds louder or quieter
  - -8.0 = moderate volume
  - -15.0 = quieter, distant
  - -5.0 = louder, more noticeable

- **Play Sound Chance**: Probability of sound playing (default: 1.0)
  - 1.0 = Always plays (100% chance)
  - 0.8 = 80% chance
  - 0.5 = 50% chance
  - 0.0 = Never plays

### Step 3: Create/Find Audio Files

#### Movement Sound Types:

**Recommended sounds (create 3-5 variations):**

1. **Laugh sounds**:
   - Deep mechanical laugh
   - Creepy giggle
   - Distorted chuckle
   - Evil laugh

2. **Growl sounds**:
   - Low rumbling growl
   - Robotic growl
   - Mechanical groan

3. **Other sounds**:
   - Mechanical whir
   - Metal scraping
   - Distorted voice
   - Electrical buzz

**Audio specs:**
- Duration: 1-3 seconds
- Format: .ogg or .wav
- Style: Creepy, threatening, mechanical
- Volume: Consistent across all files

### Step 4: Add Sounds to Array

1. In Inspector, find **Movement Sounds** array
2. Click the array to expand it
3. Set the size (e.g., 5 for 5 different sounds)
4. Drag each sound file to an array slot
5. Result: [laugh1.ogg, laugh2.ogg, growl1.ogg, growl2.ogg, laugh3.ogg]

## Examples

### Basic Setup (3 sounds):
```
Movement Sounds:
  [0]: freddy_laugh1.ogg
  [1]: freddy_laugh2.ogg
  [2]: freddy_growl.ogg

Movement Sound Volume: -8.0
Play Sound Chance: 1.0
```

### Advanced Setup (5 sounds, 80% chance):
```
Movement Sounds:
  [0]: robot_laugh1.ogg
  [1]: robot_laugh2.ogg
  [2]: robot_growl.ogg
  [3]: robot_mechanical.ogg
  [4]: robot_laugh3.ogg

Movement Sound Volume: -10.0
Play Sound Chance: 0.8
```

## Movement Path & Sounds

Big Robot moves through these rooms in order:
1. **TPM/LAS Hallway (9)** → 🔊 Sound plays
2. **Yard (4)** → 🔊 Sound plays
3. **Upper Hallway (2)** → 🔊 Sound plays
4. **Outer Auditorium (3)** → 🔊 Sound plays
5. **Stairs (5)** → 🔊 Sound plays
6. **South Hallway (10)** → 🔊 Sound plays (CRITICAL - next move is attack!)

Each movement picks a random sound from your array.

## Gameplay Impact

**Without Sounds:**
- Player must constantly check cameras
- Easy to miss Big Robot's movement
- Harder to track his position

**With Sounds:**
- Player hears laugh → "Big Robot moved!"
- Can estimate position based on number of laughs
- Creates tension and atmosphere
- Authentic FNAF experience

**With Multiple Random Sounds:**
- More variety and less repetitive
- Each playthrough feels different
- Harder to predict patterns
- More immersive

## Volume Guide

| dB Value | Effect | When to Use |
|----------|--------|-------------|
| -5.0 | Loud and clear | Close-range, very noticeable |
| -8.0 | Moderate (default) | Good balance |
| -10.0 | Quieter | Distant, subtle warning |
| -12.0 | Subtle | Background threat |
| -15.0 | Very quiet | Barely noticeable |

## Play Sound Chance Guide

| Chance | Effect | Strategy |
|--------|--------|----------|
| 1.0 | Always plays | Player always knows when he moves |
| 0.8 | Usually plays | Occasional silent moves add uncertainty |
| 0.5 | 50/50 | High unpredictability |
| 0.3 | Rarely plays | Very sneaky Big Robot |

**Recommended:** 1.0 (always) for fairness, or 0.8 for added challenge

## Testing

1. Set Big Robot AI level to 20 (high activity)
2. Put camera down to allow movement
3. Wait for movement check timer
4. You should hear a random sound from your array
5. Check cameras to confirm Big Robot moved
6. Repeat - each sound should be random

## Tips for Audio Creation

### Finding/Making Sounds:

1. **Free sound libraries**: Freesound.org, OpenGameArt.org
2. **Record and edit**: Use Audacity to modify/distort sounds
3. **Mix sounds**: Combine laugh + mechanical noise
4. **Add effects**: Reverb, distortion, pitch shift

### Making Them Loop-Friendly:

- These sounds are one-shot (don't loop)
- Make sure they end cleanly (no cut-off)
- Consistent volume across all files
- Similar style but varied enough to be distinct

### Character-Specific Style:

- **Big Robot**: Mechanical, robotic, deep
- **Freddy-like**: Laugh-based, creepy, threatening
- **School setting**: Add echo/reverb for hallway feel

## Troubleshooting

**No sound playing?**
- Check if movement_sounds array has files
- Check console for "No movement sounds configured"
- Verify AI level allows movement

**Same sound every time?**
- Make sure array has multiple different sounds
- Check that all array slots have different files

**Sound too loud/quiet?**
- Adjust movement_sound_volume in Inspector
- Test different values until it feels right

**Sound playing too often/rarely?**
- Adjust play_sound_chance (0.0 to 1.0)
- 1.0 = every move, 0.5 = half the time

## Integration with Gameplay

Big Robot only moves when:
- Camera is DOWN (player not viewing his room)
- AI check passes
- Timer interval completes

This means:
- Keeping camera on Big Robot = no movement = no sounds
- Putting camera down = movement possible = sounds can play
- More sounds heard = Big Robot getting closer to door!

## Summary

✅ Multiple random sounds for variety
✅ Configurable volume and play chance
✅ Plays automatically on movement
✅ Creates FNAF 1 Freddy atmosphere
✅ Helps player track Big Robot
✅ Easy to set up with array system
✅ One-shot sounds (no looping issues)
✅ Auto-manages audio players (no memory leaks)
