# Door Reveal Audio Guide

## Overview

Added audio feedback when animatronics are first revealed at the doors using lights. Sounds play only the FIRST time you turn on the light and see them during each visit.

## How It Works

### Reveal System:
```
1. Animatronic arrives at door → Registered (no sound yet)
2. Player turns on light → First reveal → 🔊 Sound plays
3. Player turns light off and on again → No sound (already revealed)
4. Animatronic leaves door → Unregistered
5. Animatronic returns to door later → Registered again
6. Player turns on light → New reveal → 🔊 Sound plays again
```

**Key Point:** Sound plays only on the FIRST reveal per visit, not every time you toggle the light.

## Features

### Per-Character Sounds
- Each animatronic can have their own unique reveal sound
- Uses Dictionary system for character-specific sounds
- Fallback default sound for characters without specific sounds

### Smart Sound System
- Tracks which animatronics have been revealed during current visit
- Prevents sound spam from toggling lights
- Resets when animatronic leaves and returns
- Only plays when light turns ON (not off)

### Configurable
- Adjustable volume
- Character-specific or default sounds
- Easy to add new characters

## Setup Instructions

### Step 1: Find DoorAndLightManager

Open `Scenes/Nights/nights.tscn`:
1. Find the `DoorAndLightManager` node
2. Select it

### Step 2: Configure Audio Settings

In the Inspector, you'll see new exports:

#### **Door Reveal Sounds** (Dictionary)
This is where you assign character-specific sounds:
- Key: Character name (as String)
- Value: AudioStream file

**Example structure:**
```
door_reveal_sounds:
  "INST": inst_breathing.ogg
  "bonnie": bonnie_breath.ogg
  "chica": chica_moan.ogg
  "foxy": foxy_growl.ogg
  "freddy": freddy_laugh.ogg
```

#### **Default Reveal Sound** (AudioStream)
Fallback sound used if character has no specific sound assigned.

#### **Reveal Sound Volume** (float)
Volume in dB (default: -8.0)
- 0.0 = Full volume
- -8.0 = Moderate
- -15.0 = Quieter

### Step 3: Create/Find Audio Files

#### Recommended Sound Types:

**Breathing sounds:**
- Heavy breathing
- Panting
- Mechanical breathing
- Duration: 1-3 seconds

**Growl sounds:**
- Low growls
- Mechanical groans
- Threatening noises
- Duration: 1-3 seconds

**Ambient sounds:**
- Whispers
- Metal scraping
- Electrical hum
- Duration: 1-2 seconds

**Character-specific:**
- INST: Glitch/static breathing
- Bonnie: Guitar string scrape + breath
- Chica: Kitchen sounds + breath
- Foxy: Growl/snarl
- Freddy: Deep laugh/breath

### Step 4: Assign Sounds

#### Method 1: Using Dictionary in Inspector (Godot 4+)

1. In Inspector, find "Door Reveal Sounds"
2. Add entries to the dictionary:
   - Click the + button
   - Key: Enter character name (e.g., "INST")
   - Value: Drag audio file
3. Repeat for each character

#### Method 2: Set Default Sound Only

1. Leave "Door Reveal Sounds" empty
2. Assign "Default Reveal Sound"
3. All characters will use the same sound

#### Method 3: Mix Both

1. Assign specific sounds for some characters
2. Assign default sound for others
3. Characters with specific sounds use theirs, others use default

## Character Names

Make sure to use the correct character name strings:

| Character | String to Use |
|-----------|---------------|
| INST | "INST" |
| Bonnie | "bonnie" |
| Chica | "chica" |
| Foxy | "foxy" |
| Freddy | "freddy" |
| TKJ Roamer | "TKJ" or check AI script |
| TKR Sprinter | "TKR" or check AI script |
| Big Robot | "BigRobot" or check AI script |

**Tip:** Check the character's AI script to see what name they use when registering at the door.

## How Player Experiences It

### Scenario 1: First Reveal
```
1. Light is off, animatronic at door (player doesn't know)
2. Player turns on light
3. 🔊 Breathing sound plays
4. Player sees animatronic indicator
5. "Oh no! Someone's at the door!"
```

### Scenario 2: Checking Again
```
1. Light already on, or turn it on again
2. No sound plays (already revealed)
3. Player sees indicator is still there
4. "Still there, need to keep door closed"
```

### Scenario 3: Return Visit
```
1. Animatronic was at door, left, then returns
2. Player turns on light
3. 🔊 Sound plays again (new visit)
4. "They came back!"
```

## Testing

### Test Basic Reveal:
1. Set an animatronic AI to 20 (high activity)
2. Wait for them to reach door
3. Turn on the light
4. You should hear the reveal sound
5. Toggle light off and on
6. Sound should NOT play again

### Test Return Visit:
1. After animatronic leaves door
2. Wait for them to return
3. Turn on light again
4. Sound should play (new visit)

### Test Multiple Characters:
1. Have two animatronics at different doors
2. Turn on left light → hear left character's sound
3. Turn on right light → hear right character's sound

## Audio Design Tips

### Breathing Sounds:
- Should feel close and threatening
- Not too long (1-3 seconds)
- Clear enough to hear but not overwhelming
- Add slight reverb for hallway feel

### Character-Specific Sounds:
- Match character personality
- INST: Glitchy, digital
- Foxy: Aggressive, animalistic
- Freddy: Deep, menacing
- Bonnie/Chica: Creepy, unnatural

### Volume Balancing:
- Loud enough to startle slightly
- Not so loud it's jarring
- Should blend with ambient sounds
- Try -8.0 to -12.0 dB range

## Technical Details

### How It Tracks Reveals:

**Left Door:**
- `left_door_revealed` Dictionary stores: {"INST": true, "bonnie": true}
- When animatronic registered: Set to false
- When light reveals: Set to true
- When animatronic leaves: Removed from dict

**Right Door:**
- `right_door_revealed` Dictionary works the same way

### Sound Selection Priority:
1. Check `door_reveal_sounds` dictionary for character name
2. If found, use that sound
3. If not found, use `default_reveal_sound`
4. If no default, no sound plays

### Audio Player:
- Creates temporary AudioStreamPlayer
- Plays once (one-shot)
- Auto-deletes when finished
- No memory leaks

## Integration with Existing Systems

### Works with:
- ✅ Door indicator graphics (visual + audio together)
- ✅ Multiple animatronics at same door
- ✅ Camera system (sounds play in office view)
- ✅ Power system (no conflicts)
- ✅ Existing light toggle system

### Compatible with:
- Any number of characters
- Custom animatronics
- Different door sides
- Power out sequences

## Troubleshooting

**No sound playing?**
- Check if character name in dictionary matches AI script
- Check if default_reveal_sound is assigned
- Look for console message: "No reveal sound configured for [character]"
- Verify light is actually turning on

**Sound plays every time I toggle light?**
- Check console for "Revealed [character]" message
- Should only see it once per visit
- If it shows multiple times, the reveal tracking might have an issue

**Wrong sound playing?**
- Verify character name spelling in dictionary
- Check AI script for exact name used when registering at door
- Console shows which sound is playing

**Sound too loud/quiet?**
- Adjust `reveal_sound_volume` in Inspector
- Try values between -5.0 and -15.0
- Test with different audio files

## Example Setup

### Basic Setup (One Sound for All):
```
Door Reveal Sounds: [empty]
Default Reveal Sound: breathing.ogg
Reveal Sound Volume: -8.0
```

### Advanced Setup (Character-Specific):
```
Door Reveal Sounds:
  "INST": inst_static_breath.ogg
  "bonnie": bonnie_breathing.ogg
  "chica": chica_kitchen_breath.ogg
  "foxy": foxy_growl.ogg
  "freddy": freddy_laugh.ogg

Default Reveal Sound: generic_breath.ogg
Reveal Sound Volume: -10.0
```

## Benefits

### Without Door Reveal Sounds:
- Player only gets visual feedback
- Easier to miss animatronics at doors
- Less tension and atmosphere

### With Door Reveal Sounds:
- Audio + visual feedback
- More immersive and scary
- Instant tension when sound plays
- Player knows immediately someone is there
- Authentic FNAF experience
- Adds jumpcare factor to reveals

## Summary

✅ Plays sound when animatronic first revealed at door
✅ Only plays once per visit (no spam)
✅ Resets when animatronic leaves and returns
✅ Character-specific or default sounds
✅ Adjustable volume
✅ Easy dictionary-based setup
✅ Works with multiple animatronics
✅ Creates FNAF-like tension
✅ Smart tracking system prevents sound spam
