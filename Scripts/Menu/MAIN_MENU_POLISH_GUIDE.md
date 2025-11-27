# Main Menu Polish Guide

## Features Added

### 1. **Floating Title Animation**
- Title logo floats up and down subtly
- 20 pixels total movement (10 up, 10 down)
- 2 second duration per direction
- Smooth sine easing
- Loops forever

### 2. **Button Hover Effects** (CSS-like)
- Scale: Grows to 105% on hover
- Brightness: Increases to 120% on hover
- Smooth animations (0.2 seconds)
- Back easing for "bouncy" feel
- Plays hover sound when mouse enters
- Works on all buttons automatically

### 3. **Settings Button** (Ready to implement)
- Placeholder function `_on_settings_pressed()`
- Ready for settings menu/popup
- Audio plays on click

### 4. **Reset Progress Button**
- Shows confirmation dialog
- Warns user about permanent deletion
- Resets GlobalData progress
- Updates continue button state
- Prevents accidental resets

## Setup Instructions

### Add Buttons to Scene

Open `Scenes/Menu/main_menu.tscn` and add:

#### Settings Button:
```
Position: Top right area (e.g., 1450, 45)
Size: ~100x50
Type: Button or TextureButton
Name: "SettingsButton"
Text: "Settings" or gear icon
```

#### Reset Button:
```
Position: Near settings button (e.g., 1450, 100)
Size: ~100x50
Type: Button or TextureButton
Name: "ResetButton"
Text: "Reset Progress"
```

### Connect Signals

In the scene editor:
1. Select SettingsButton
2. Connect "pressed" signal → main_menu.gd → `_on_settings_pressed`
3. Select ResetButton
4. Connect "pressed" signal → main_menu.gd → `_on_reset_pressed`

OR manually add in scene file:
```
[connection signal="pressed" from="SettingsButton" to="." method="_on_settings_pressed"]
[connection signal="pressed" from="ResetButton" to="." method="_on_reset_pressed"]
```

## How It Works

### Title Float:
```gdscript
# Original Y position
var original_y = title_logo.position.y

# Up 10 pixels over 2 seconds
tween to original_y - 10

# Down 10 pixels over 2 seconds  
tween to original_y + 10

# Loop forever
```

### Button Hover:
```gdscript
Mouse enters button:
- Scale: 1.0 → 1.05
- Brightness: 1.0 → 1.2
- Play hover sound

Mouse exits button:
- Scale: 1.05 → 1.0
- Brightness: 1.2 → 1.0
```

### Reset Flow:
```
Player clicks Reset
    ↓
Confirmation dialog appears
    ↓
"Are you sure? This cannot be undone!"
    ↓
Player clicks "Yes, Reset"
    ↓
GlobalData.reset_progress() called
    ↓
nights_completed = 0
max_night_unlocked = 1
    ↓
Continue button disabled
    ↓
"Game progress reset!" printed
```

## Customization

### Adjust Float Animation:
```gdscript
# In _setup_title_float():
var float_distance = 10  # Change this (pixels)
var float_duration = 2.0  # Change this (seconds)
```

### Adjust Hover Effect:
```gdscript
# In _on_button_hover():
var target_scale = Vector2(1.05, 1.05)  # Change scale
var target_modulate = Color(1.2, 1.2, 1.2)  # Change brightness
var tween_duration = 0.2  # Change speed
```

### Customize Confirmation Dialog:
```gdscript
# In _show_reset_confirmation():
dialog.dialog_text = "Your custom message"
dialog.ok_button_text = "Your confirm text"
```

## Testing

### Title Float:
1. Run main menu
2. Watch title logo
3. Should float up and down smoothly

### Button Hover:
1. Move mouse over any button
2. Should grow slightly and brighten
3. Should hear hover sound
4. Should return to normal when mouse leaves

### Reset Progress:
1. Play some nights to create progress
2. Click Reset button
3. Confirmation dialog should appear
4. Click "Yes, Reset"
5. Progress should be gone
6. Continue button should be disabled

## Current Buttons

All these buttons have hover effects:
- ✅ NewGameButton
- ✅ ContinueButton
- ✅ SelectNightButton
- ✅ CustomNightButton
- 📝 SettingsButton (add to scene)
- 📝 ResetButton (add to scene)

## Next Steps

1. **Add buttons to scene** (Settings, Reset)
2. **Connect button signals**
3. **Test hover effects**
4. **Implement settings menu** (future)
5. **Add button textures** (optional)

## Additional Ideas

### More Polish:
- Fade in menu on load
- Particle effects in background
- Button press animation (scale down)
- Sound effects for different actions
- Glow effect on hover
- Animated menu transitions

### Settings Menu Options:
- Master volume slider
- Music volume slider
- SFX volume slider
- Camera sensitivity
- Fullscreen toggle
- Resolution options
- Control remapping

## Summary

✅ Title floats smoothly
✅ Buttons have hover effects (scale + brightness)
✅ Hover sound plays
✅ Reset progress with confirmation
✅ All code is ready
📝 Just need to add Settings/Reset buttons to scene
