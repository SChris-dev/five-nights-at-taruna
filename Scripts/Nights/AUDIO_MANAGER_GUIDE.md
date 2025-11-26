# Audio Manager Guide

## Overview

The Audio Manager is a centralized system for managing all game audio except jumpscares (which are handled by the Jumpscare Manager).

## Features

### 1. **Phone Call System**
- Automatic phone calls at the start of each night
- Different audio for each night (1-7)
- Configurable delay before call starts
- Phone calls prevent ambient sounds from playing during playback

### 2. **Ambient Sound System**
- Random ambient sounds (like FNAF 1: whispers, footsteps, distant sounds)
- Configurable interval range between sounds
- Automatically disabled during phone calls
- Can be toggled on/off dynamically

### 3. **UI Sounds**
- Door toggle (open/close)
- Light toggle (on/off)
- Camera open/close
- Camera feed switching
- Button clicks and hovers
- Static/glitch effects

### 4. **Character Audio Cues**
- Character-specific sounds (breathing, footsteps, giggles, etc.)
- Can store multiple sounds per character
- Random or specific sound selection

### 5. **Power Out Sequence**
- Power out sound effect
- Freddy's music box during power out
- Timed sequence support

## Setup Instructions

### Step 1: Add AudioManager to Scene

1. Open `Scenes/Nights/nights.tscn`
2. Add a new Node and attach the `audio_manager.gd` script
3. Name it "AudioManager"

### Step 2: Configure Phone Calls

1. Select the AudioManager node
2. In the Inspector, find "Phone Call System"
3. Drag your audio files for each night:
   - Night 1: Tutorial/welcome call
   - Night 2: More warnings
   - Night 3: Getting serious
   - Night 4: Critical warnings
   - Night 5: Shorter/desperate
   - Night 6: Cryptic/disturbing
   - Night 7: (Optional) Custom night message

### Step 3: Add Ambient Sounds

1. In "Ambient Sound System", expand "Ambient Sounds" array
2. Add multiple AudioStream files:
   - Whispers
   - Distant footsteps
   - Metal clanging
   - Wind/air vents
   - Random bumps
   - Electrical buzzing
3. Set your preferred interval range (default: 10-30 seconds)

### Step 4: Configure UI Sounds

1. In "UI Sounds", assign audio for:
   - Door toggle
   - Light toggle
   - Camera open/close
   - Camera switch
   - Button interactions
   - Static effect

### Step 5: Add Character Sounds

Character sounds use a Dictionary structure. You'll need to set this up in code or the inspector:

**Example Dictionary structure:**
```
{
  "freddy": [breathing_sound1, laugh_sound1, footstep_sound1],
  "bonnie": [guitar_sound1, footstep_sound1],
  "chica": [kitchen_sound1, pots_sound1],
  "foxy": [run_sound1, banging_sound1]
}
```

## Usage Examples

### In Your Scripts

#### Playing UI Sounds:
```gdscript
# Get reference to AudioManager
@onready var audio_manager = get_node("/root/Nights/AudioManager")

# Play door sound
audio_manager.play_door_sound()

# Play camera open
audio_manager.play_camera_open_sound()
```

#### Playing Character Sounds:
```gdscript
# Play random sound for Freddy
audio_manager.play_character_sound("freddy")

# Play specific sound (index 0)
audio_manager.play_character_sound("freddy", 0)
```

#### Power Out:
```gdscript
# When power runs out
audio_manager.play_power_out_sequence()

# Stop music box when jumpscare happens
audio_manager.stop_music_box()
```

#### Control Ambient:
```gdscript
# Disable ambient during specific moments
audio_manager.set_ambient_enabled(false)

# Re-enable
audio_manager.set_ambient_enabled(true)
```

## Integration Points

### Door & Light Manager
Add to `door_and_light_manager.gd`:
```gdscript
func toggle_door(side: String):
	# ... existing code ...
	audio_manager.play_door_sound()

func toggle_light(side: String):
	# ... existing code ...
	audio_manager.play_light_sound()
```

### Camera Manager
Add to `camera.gd`:
```gdscript
func open_camera():
	# ... existing code ...
	audio_manager.play_camera_open_sound()

func close_camera():
	# ... existing code ...
	audio_manager.play_camera_close_sound()

func switch_feed(feed_id: int):
	# ... existing code ...
	audio_manager.play_camera_switch_sound()
```

### Character AI
Add to individual character scripts:
```gdscript
# When character moves or does something
audio_manager.play_character_sound("freddy")
```

### Power Manager
Add to `power_manager.gd`:
```gdscript
func on_power_depleted():
	# ... existing code ...
	audio_manager.play_power_out_sequence()
```

## Signals

The AudioManager emits signals you can connect to:

```gdscript
audio_manager.phone_call_started.connect(_on_phone_call_started)
audio_manager.phone_call_ended.connect(_on_phone_call_ended)
audio_manager.ambient_sound_played.connect(_on_ambient_played)
```

## Tips

1. **Audio File Format**: Use `.ogg` for better compression and looping
2. **Volume Levels**: Adjust the exported volume variables to balance your audio
3. **Phone Calls**: Keep them under 60 seconds for better pacing
4. **Ambient Sounds**: Use 10-15 different sounds for variety
5. **Character Sounds**: Coordinate with character AI movement patterns

## Audio Bus Setup (Optional)

For better control, you can create audio buses in Godot:
1. Project → Project Settings → Audio
2. Add buses: "Music", "SFX", "Ambience", "Voice"
3. Update the audio_manager.gd bus assignments

## Troubleshooting

**Phone call not playing?**
- Check if audio file is assigned for current night
- Verify GlobalData.current_night is set correctly

**Ambient sounds too frequent/rare?**
- Adjust `ambient_min_interval` and `ambient_max_interval`

**Sounds overlapping?**
- UI sounds can overlap (intentional)
- Ambient sounds won't overlap with themselves
- Character sounds can overlap (adjust if needed)

**Volume issues?**
- Adjust the volume_db exports (negative values = quieter)
- 0 dB = full volume
- -10 dB = roughly half volume
- -20 dB = roughly quarter volume
