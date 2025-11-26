# Audio Manager Updates

## Changes Made to Fix Sound Issues

### Problem 1: Door sound delayed
**Solution**: Door sounds now play immediately as one-shot sounds that can overlap with other sounds.

### Problem 2: Light sound should loop but stop when turned off
**Solution**: 
- Split light sound into separate player
- Added `play_light_on_sound()` - starts looping the light sound
- Added `play_light_off_sound()` - stops the light sound
- Automatically sets loop mode based on audio format

### Problem 3: Sounds can't overlap (light stops when door closes)
**Solution**: 
- UI sounds now use dedicated player that allows overlapping
- Light sound uses separate player so it doesn't interfere with other UI sounds
- Door, camera, button sounds can all play simultaneously

## Updated API

### Light Sounds (NEW)
```gdscript
# When turning light ON
audio_manager.play_light_on_sound()  # Starts looping

# When turning light OFF
audio_manager.play_light_off_sound()  # Stops looping
```

### Door Sounds (unchanged)
```gdscript
audio_manager.play_door_sound()  # One-shot, can overlap
```

### Other UI Sounds (unchanged)
```gdscript
audio_manager.play_camera_open_sound()
audio_manager.play_camera_close_sound()
audio_manager.play_camera_switch_sound()
audio_manager.play_button_click_sound()
audio_manager.play_button_hover_sound()
audio_manager.play_static_sound()
```

## Integration Example

### Door and Light Manager
```gdscript
@onready var audio_manager = get_node("/root/Nights/AudioManager")

func toggle_door(side: String) -> void:
	if side == "left":
		left_door_closed = !left_door_closed
		audio_manager.play_door_sound()  # One-shot
		# ... rest of code
	
func toggle_light(side: String) -> void:
	if side == "left":
		left_light_on = !left_light_on
		if left_light_on:
			audio_manager.play_light_on_sound()  # Start loop
		else:
			audio_manager.play_light_off_sound()  # Stop loop
		# ... rest of code
```

## Audio File Setup

### For Light Sound
**Important**: Your light sound file must be configured for looping:

#### For .wav files:
1. Import the file in Godot
2. Click on the file in FileSystem
3. In Import tab, set "Loop Mode" to "Forward"
4. Click "Reimport"

#### For .ogg files:
1. The script will automatically set loop = true
2. Make sure your .ogg file is prepared for seamless looping

### For Door/Button/Camera Sounds
- These should be one-shot sounds (no looping)
- Keep them short (under 1 second) for best responsiveness

## Technical Details

### Audio Players Created:
- `phone_player` - Phone calls
- `ambient_player` - Ambient sounds
- `ui_player` - Door, camera, buttons (one-shot, can overlap)
- `light_player` - Light sound (looping, separate from UI)
- `character_player` - Character audio cues
- `power_out_player` - Power out sound
- `music_box_player` - Freddy's music box

### Why Separate Players?
- **ui_player**: Allows multiple UI sounds to overlap (door + camera + button)
- **light_player**: Loops continuously, won't interfere with other sounds
- **Each sound type independent**: No more audio cutting each other off!

## Testing Checklist

✓ Door sound plays immediately when clicked
✓ Light sound loops while on
✓ Light sound stops when turned off
✓ Door and light sounds can play at same time
✓ Multiple UI sounds can overlap
✓ No audio cuts off other audio unexpectedly
