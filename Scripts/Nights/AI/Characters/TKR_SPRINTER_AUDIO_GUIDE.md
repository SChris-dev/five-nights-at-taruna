# TKR Sprinter Audio Guide

## Overview

Added audio feedback for TKR Sprinter (Foxy-like character) to help players respond to sprint attacks.

## Features Added

### 1. Sprint Sound (Running Footsteps)
**When it plays:**
- Starts when TKR begins sprinting from Room 8 to Room 12
- Loops continuously while sprinting
- Stops when player closes door OR when jumpscare happens

**Purpose:**
- Alerts player that TKR is sprinting
- Creates urgency to check cameras and close door
- Player can hear even without looking at cameras

### 2. Door Bang Sound
**When it plays:**
- Plays when TKR reaches door but it's closed
- One-shot sound (doesn't loop)

**Purpose:**
- Confirms player successfully blocked TKR
- Audio feedback for successful defense

## Setup Instructions

### Step 1: Find TKRSprinter in Scene

Open `Scenes/Nights/nights.tscn`:
1. Find the `TKRSprinter` node (should be in CharacterAI)
2. Select it

### Step 2: Assign Audio

In the Inspector, you'll see new exports:
- **Audio Manager**: (Optional, not currently used)
- **Sprint Sound**: Assign your running footsteps audio
- **Door Bang Sound**: Assign your door bang audio

### Step 3: Create/Find Audio Files

#### Sprint Sound (Running Footsteps)
**Recommended specs:**
- Type: Fast running footsteps
- Duration: 1-3 seconds (will loop)
- Style: Urgent, heavy footsteps
- Examples: 
  - Metal footsteps on floor
  - Fast running sounds
  - Heavy stomping
- Volume: Should be noticeable but not overwhelming

**Tips:**
- Make it loop seamlessly
- Should feel urgent and threatening
- Different from normal walking sounds

#### Door Bang Sound
**Recommended specs:**
- Type: Impact/bang sound
- Duration: 0.5-1 second (one-shot)
- Style: Heavy door hit
- Examples:
  - Metal door bang
  - Heavy knock
  - Impact sound
- Volume: Should be loud and startling

### Step 4: Import and Assign

1. Place your audio files in `Audio/Characters/TKR/` or similar folder
2. Import them in Godot
3. Drag to the respective fields in TKRSprinter node

## How It Works

### Sprint Sequence:
```
1. TKR reaches Phase 3 (READY)
2. TKR disappears from Camera 8
3. TKR appears in Camera 12 (running)
4. 🔊 Sprint sound starts looping (footsteps)
5. Player hears footsteps → checks cameras → sees TKR running
6. Player has 3 seconds after viewing to close right door
```

### If Door Closed:
```
1. Sprint sound stops
2. 🔊 Door bang sound plays (one-shot)
3. 5% power drained as penalty
4. TKR resets to starting position
```

### If Door Open:
```
1. Sprint sound stops
2. Jumpscare triggers
3. Game over
```

## Audio Timing

- **Sprint sound plays**: When TKR starts running (appears in cam 12)
- **Sprint sound stops**: When blocked by door OR jumpscare happens
- **Door bang plays**: Only when blocked by closed door

## Testing

1. Set TKR AI level to 20 for quick testing
2. Let camera down to advance phases
3. When TKR reaches phase 3 (READY):
   - You should hear running footsteps start
   - Check cam 12 to see TKR running
   - Close right door
4. Sound should stop + door bang should play
5. TKR resets after 25 second cooldown

## Audio Design Tips

### Sprint Sound:
- Should be clearly audible over ambient sounds
- Create tension and urgency
- Loop seamlessly
- Match the character's speed (fast!)
- Metal/mechanical sound fits robotic character

### Door Bang Sound:
- Satisfying impact sound
- Confirms player's successful action
- Can be startling (adds intensity)
- Short and punchy

## Technical Details

### Sprint Sound:
- Loops using AudioStreamPlayer
- Volume: -3.0 dB (slightly louder for urgency)
- Automatically sets loop mode for .wav and .ogg
- Stops when sprint ends (any reason)

### Door Bang Sound:
- One-shot using temporary AudioStreamPlayer
- Volume: 0.0 dB (full volume)
- Auto-deletes after playing

## Integration with Gameplay

**Player Experience:**
1. Hears footsteps → "Oh no, TKR is running!"
2. Opens camera → Sees TKR in cam 12 or missing from cam 8
3. Closes right door quickly
4. Hears bang → "Phew, I blocked him!"
5. OR no bang + jumpscare → "I was too late!"

**Without Audio:**
- Player might not notice TKR sprinting
- Harder to react in time
- Less warning of danger

**With Audio:**
- Clear audio cue to check cameras
- Creates urgency
- Better gameplay experience
- More like FNAF 1 Foxy

## Troubleshooting

**No sound playing?**
- Check if sprint_sound is assigned
- Verify audio file is imported correctly
- Check console for "[TKRSprinter] No sprint sound configured"

**Sound not stopping?**
- Should auto-stop when door closed or jumpscare
- Check console for "[TKRSprinter] Sprint sound stopped"

**Sound not looping?**
- Check audio file import settings
- For .wav: Set "Loop Mode" to "Forward" in import
- For .ogg: Loop is set automatically by script

**Door bang not playing?**
- Check if door_bang_sound is assigned
- Check console for "[TKRSprinter] Playing door bang sound"

## Summary

✅ Sprint sound plays when TKR runs (loops)
✅ Sprint sound stops when blocked or jumpscare
✅ Door bang sound plays when successfully blocked
✅ Helps player react quickly to sprinting threat
✅ Creates FNAF-like tension and urgency
✅ Audio cue works even without looking at cameras
