# Quick Debug Guide for Five Nights at Taruna

## 🐛 Fast Debugging Methods

### Method 1: Console Logging (Fastest)

Add these to your AI scripts to see what's happening:

#### In any anomaly script (inst_anomaly.gd, etc.):
```gdscript
func move_check() -> void:
	if has_passed_check():
		print("[%s] Moving! Step: %d, Room: %d" % [name, step, current_room])
		move_options()
```

#### In move_to() function (ai.gd):
```gdscript
func move_to(target_room: int, new_state: int = State.PRESENT, move_step: int = 1) -> void:
	print("[%s] move_to: %d → %d" % [_get_character_name(), current_room, target_room])
	# ... rest of function
```

### Method 2: Visual Debug Overlay

1. Add a **CanvasLayer** node to your nights.tscn root
2. Rename it to **DebugOverlay**
3. Attach script: `Scripts/Debug/camera_debug.gd`
4. Set export: `camera_manager = ../CameraElements`
5. Set `enabled = true`

This shows all anomaly positions in real-time on screen!

### Method 3: Remote Inspector

1. Run your game (F5)
2. In Godot Editor, click **Remote** tab in Scene panel
3. Navigate to **CharacterAI** node
4. Click each anomaly to watch their properties live:
   - `current_room`
   - `step`
   - `ai_level`
   - `is_at_door`

---

## 🔍 Common Debug Checks

### Check 1: Is Camera System Working?

Add to `tjp_setup.gd` in `set_feed()`:
```gdscript
func set_feed(feed_to_update: int) -> void:
	var room_state: Array = rooms[feed_to_update]
	var room_feed: Sprite2D = all_feeds[feed_to_update]
	
	print("Feed %d: state=%s, frame=%d" % [feed_to_update, room_state, room_feed.frame])
	# ... rest of function
```

Expected output when INST moves:
```
Feed 0: state=[1, 0, 0, 0, 0, 0], frame=0  # INST in ROOM_01
Feed 1: state=[1, 0, 0, 0, 0, 0], frame=0  # INST in ROOM_02
Feed 0: state=[0, 0, 0, 0, 0, 0], frame=1  # INST left ROOM_01
```

### Check 2: Are Timers Working?

Add to each Timer's timeout in scene:
```gdscript
# Connect to a test function first
func _on_timer_timeout() -> void:
	print("[Timer] %s move_check called" % name)
	move_check()
```

Expected output:
```
[Timer] INSTAnomaly move_check called
[Timer] TKJRoamer move_check called
[Timer] TKRSprinter move_check called
```

### Check 3: Is rooms Array Correct Size?

Add to `CameraElements` _ready():
```gdscript
func _ready() -> void:
	print("Rooms count: %d (should be 13)" % rooms.size())
	print("Characters per room: %d (should be 6)" % rooms[0].size())
	print("Starting state: %s" % str(rooms))
	# ... rest
```

Expected output:
```
Rooms count: 13 (should be 13)
Characters per room: 6 (should be 6)
Starting state: [[1, 0, 0, 0, 0, 0], [0, 0, 0, 0, 0, 0], ...]
```

### Check 4: Are Fix Buttons Working?

Add to `camera_fix_button.gd`:
```gdscript
func _on_pressed() -> void:
	print("[FIX BUTTON] Pressed! Type: %d" % button_type)
	# ... rest
```

---

## 🎯 Step-by-Step Testing

### Test 1: Single Anomaly Movement (2 minutes)

1. Disable all anomalies except INST:
   - In CharacterAI, remove or disable other child nodes
2. Set `inst_level = 20` (always moves)
3. Run game (F6)
4. Watch console:
   ```
   [INSTAnomaly] Moving! Step: 0, Room: 0
   [INSTAnomaly] move_to: 0 → 1
   Feed 0: state=[0, 0, 0, 0, 0, 0], frame=1
   Feed 1: state=[1, 0, 0, 0, 0, 0], frame=0
   ```
5. Open camera and switch to ROOM_02
6. Should see INST anomaly on camera

**✅ Pass:** INST moves between rooms and appears on correct cameras

### Test 2: Door Attack (2 minutes)

1. Keep only INST enabled with level 20
2. Wait for INST to reach ROOM_10 (South Hallway)
3. Don't close left door
4. Watch console for jumpscare trigger
5. Should transition to game over scene

**✅ Pass:** Door attack triggers jumpscare

### Test 3: TKR Sprinter (3 minutes)

1. Enable only TKRSprinter
2. Set `tkr_sprinter_level = 20`
3. Run game
4. Watch console for:
   ```
   [TKRSprinter] Moving! Step: 0, Room: 7
   [TKRSprinter] Moving! Step: 1, Room: 7
   TKR Sprinter is running!
   [TKRSprinter] move_to: 7 → 11
   ```
5. After "is running!" message, close right door quickly
6. Should hear door bang and see power drain

**✅ Pass:** Sprinter runs and door blocks correctly

### Test 4: RPL Disruptor (1 minute)

1. Enable only RPLDisruptor
2. Run game
3. Wait 30 seconds
4. Watch console: `RPL Disruptor has broken the cameras!`
5. Go to ROOM_06 camera
6. Should see "FIX CAMERA" button
7. Click it
8. Console: `Cameras fixed!`

**✅ Pass:** Disruptor activates and fix button works

### Test 5: TKJ Drainer (1 minute)

1. Enable only TKJDrainer
2. Run game
3. Wait 25 seconds
4. Watch power drain increase
5. Console: `TKJ Drainer is draining power! Fix it quickly!`
6. Go to ROOM_07 camera
7. Should see "STOP DRAIN" button
8. Click it
9. Console: `Power drain fixed!`

**✅ Pass:** Power drain activates and fix button works

### Test 6: All Anomalies Together (5 minutes)

1. Enable all anomalies with moderate levels (5-10)
2. Run game for full night
3. Monitor camera feeds
4. Test door mechanics
5. Fix disruptions and drains as they occur

**✅ Pass:** All systems work together without conflicts

---

## 🚨 Common Problems & Solutions

### Problem: "Anomaly not moving"

**Check:**
```gdscript
print("AI Level: ", ai_level)  # Should be > 0
print("Has passed check: ", has_passed_check())  # Should return true sometimes
print("Timer autostart: ", $Timer.autostart)  # Should be true
```

**Solutions:**
- Set `ai_level` higher (15-20 for testing)
- Verify timer is connected
- Check `use_manual_levels = true` in ai_manager

---

### Problem: "Camera doesn't update"

**Check:**
```gdscript
# In camera.gd update_feeds():
print("Updating feeds: ", feeds_to_update)
```

**Solutions:**
- Verify `rooms` array has 6 elements per room
- Check tjp_setup.gd is attached to CameraElements
- Ensure AI scripts call `camera.update_feeds([room_index])`

---

### Problem: "Fix button doesn't appear"

**Check:**
```gdscript
# In camera_fix_button.gd:
print("Button visible: ", visible)
print("AI Manager exists: ", ai_manager != null)
print("Anomaly node exists: ", ai_manager.has_node("RPLDisruptor"))
```

**Solutions:**
- Check `ai_manager` path is correct
- Verify anomaly node names match exactly
- Make sure button is child of correct room sprite

---

### Problem: "Wrong sprite frame showing"

**Check:**
```gdscript
# In tjp_setup.gd set_feed():
print("Room %d state: %s" % [feed_to_update, room_state])
print("Setting frame to: %d" % room_feed.frame)
print("Inst here: %s, TKJ here: %s" % [inst_here, tkj_roamer_here])
```

**Solutions:**
- Verify sprite has enough frames
- Check character enum indices match (0-5)
- Ensure starting room positions are correct

---

## 📊 Performance Monitoring

Add to nights.tscn root node:
```gdscript
func _process(_delta: float) -> void:
	# Show FPS
	print("FPS: ", Engine.get_frames_per_second())
```

If FPS drops below 30:
- Reduce number of print() statements
- Optimize camera feed updates
- Check for memory leaks in timers

---

## 💡 Pro Tips

1. **Use Remote Inspector** - Best way to debug in real-time
2. **Print sparingly** - Too many prints lag the game
3. **Test one at a time** - Easier to find bugs
4. **Set high AI levels** for testing (15-20)
5. **Use breakpoints** in Godot debugger
6. **Check Output filter** - Set to "Errors" only when needed

---

## 🎮 Keyboard Shortcuts While Testing

- **F5** - Run project
- **F6** - Run current scene
- **F7** - Step into (debugging)
- **F8** - Step over (debugging)
- **F9** - Continue (debugging)
- **Ctrl+F5** - Stop

Happy debugging! 🐛→✨
