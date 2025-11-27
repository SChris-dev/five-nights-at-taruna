# Anomaly Audio & Visual Feedback Guide

## Overview

Added audio cues and visual feedback for RPL Disruptor and TKJ Drainer to help players respond to threats.

## Features Added

### 1. RPL Disruptor (Camera Disruption)
**Audio Feedback:**
- Plays static sound from AudioManager when disruption happens
- Optional custom alert sound (beep, warning, etc.) that **loops**
- **Sound stops automatically when you fix the cameras**

**How it works:**
- When cameras get disrupted, audio plays automatically and loops
- Helps player realize cameras are broken even if not looking
- When you click the fix button, the alert sound stops immediately

### 2. TKJ Drainer (Power Drain)
**Audio Feedback:**
- Plays alert sound when drain starts (loops continuously)
- **Sound stops automatically when you fix the drain**

**Visual Feedback:**
- Power label flickers between WHITE and RED
- Flickers every 0.3 seconds
- Stops when drain is fixed

**How it works:**
- When drain starts: Alert sound loops + Power label starts flickering red/white
- While draining: Sound keeps looping, power label continues to flicker
- When fixed: Sound stops immediately, flickering stops, label returns to white

## Setup Instructions

### Step 1: Add References in Scene

Open `Scenes/Nights/nights.tscn`:

#### For RPL Disruptor (RPLDisruptor node):
1. Select the `RPLDisruptor` node
2. In Inspector, find the exports:
   - **Audio Manager**: Drag the AudioManager node
   - **Camera Manager**: Should already be set
   - **Alert Sound** (optional): Drag an audio file for custom alert

#### For TKJ Drainer (TKJDrainer node):
1. Select the `TKJDrainer` node
2. In Inspector, find the exports:
   - **Audio Manager**: Drag the AudioManager node
   - **Power Manager**: Should already be set
   - **Hud Labels**: Drag the HUDLabels node (usually in root)
   - **Drain Alert Sound**: Drag an audio file for the alert

### Step 2: Create Alert Sound Files

#### Recommended Sounds:

**RPL Disruptor Alert:**
- Type: Short beep or electronic glitch
- Duration: 0.5-2 seconds (will loop)
- Style: Warning/error sound
- Example: "beep-beep-beep" or static burst
- **Note**: Sound will loop continuously until fixed

**TKJ Drainer Alert:**
- Type: Alarm or warning tone
- Duration: 1-3 seconds (will loop)
- Style: Urgent warning
- Example: "beep...beep...beep" or siren
- **Note**: Sound will loop continuously until fixed

Place these in `Audio/Alerts/` or `Audio/SFX/` folder.

### Step 3: Assign Audio Files

1. Import your alert sounds into Godot
2. In the scene, select RPLDisruptor node
3. Drag your RPL alert sound to "Alert Sound"
4. Select TKJDrainer node
5. Drag your TKJ alert sound to "Drain Alert Sound"

## How It Works Technically

### RPL Disruptor:
```gdscript
# When disruption happens:
1. Play static sound (from AudioManager)
2. Play custom alert sound (if provided) - LOOPS
3. Apply camera disruption effects
4. Player hears audio cue → knows to check cameras → finds fix button

# When player fixes cameras:
1. Alert sound stops immediately
2. Static effects removed
3. Normal camera feeds restored
```

### TKJ Drainer:
```gdscript
# When drain starts:
1. Play alert sound (LOOPS)
2. Start power label flickering (red/white)
3. Extra power drain begins
4. Player sees flickering + hears alert → knows power is draining → finds fix button

# When drain fixed:
1. Alert sound stops immediately
2. Stop flickering
3. Reset label to white
4. Player sees normal label + silence → knows drain stopped
```

## Flicker Settings

You can adjust the flicker speed in `hud_labels.gd`:

```gdscript
var flicker_interval: float = 0.3  # Change this value
# 0.3 = default (fast warning)
# 0.5 = slower flicker
# 0.2 = faster flicker
```

You can also change the colors:
```gdscript
var flicker_color_white: Color = Color(1, 1, 1, 1)  # White
var flicker_color_red: Color = Color(1, 0, 0, 1)    # Red
# Change red to orange: Color(1, 0.5, 0, 1)
```

## Testing

### Test RPL Disruptor:
1. Set RPL AI level to 20 (high chance)
2. Wait for disruption to trigger
3. You should hear: Static sound + Alert sound (if configured)
4. Cameras should have heavy static

### Test TKJ Drainer:
1. Set TKJ Drainer AI level to 20
2. Wait for drain to trigger
3. You should:
   - Hear alert sound
   - See power label flickering red/white
   - See power draining faster
4. Fix it by clicking button on camera
5. Flickering should stop

## Integration with Existing Systems

### AudioManager Integration:
- RPL uses `audio_manager.play_static_sound()`
- Both create temporary audio players for custom alerts
- Doesn't interfere with other audio systems

### HUD Integration:
- TKJ calls `hud_labels.start_power_flicker()`
- TKJ calls `hud_labels.stop_power_flicker()`
- Flicker runs in `_process()` loop

### No Conflicts:
- Audio players are temporary (auto-deleted after playing)
- Flicker is independent of power updates
- Can have multiple alerts at same time

## Optional Enhancements

### Add Looping Sound While Draining:
```gdscript
# In tkj_drainer.gd _start_draining():
if drain_loop_sound:
    # Create looping player
    var loop_player = AudioStreamPlayer.new()
    loop_player.stream = drain_loop_sound
    loop_player.volume_db = -8.0
    # Set loop mode based on audio type
    add_child(loop_player)
    loop_player.play()
    # Store reference to stop later
```

### Add Visual Effect for RPL:
- Flash screen red when disruption happens
- Show warning icon
- Shake camera feeds

### Add Distance-Based Audio:
- Louder when closer to camera feed
- Quieter when in office

## Troubleshooting

**No audio playing?**
- Check if AudioManager node is assigned
- Check if alert sound is assigned
- Check audio import settings in Godot

**Flicker not working?**
- Check if HUDLabels node is assigned to TKJ Drainer
- Check console for "[HUDLabels] Power flicker started"
- Verify power_label is properly referenced

**Audio keeps playing?**
- Temporary players auto-delete after finishing
- Check console for errors

**Flicker doesn't stop?**
- Fix button should call `fix_power_drain()`
- Check if signal connections are correct

## Summary

✅ RPL Disruptor: Audio alert when cameras break
✅ TKJ Drainer: Audio alert + flickering power label
✅ Both help player respond quickly
✅ Easy to configure with export variables
✅ No interference with existing systems
