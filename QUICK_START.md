# Quick Start Guide - Testing Your New FNAF System

## 🚀 Immediate Testing (Without Any Assets)

You can test the basic systems right now using placeholder graphics:

### Step 1: Create a Simple Main Menu (5 minutes)

1. Open Godot and create a new scene: `Scenes/Menu/main_menu.tscn`
2. Add this node structure:
   ```
   Control (root)
   ├─ ColorRect (Background) - Make it dark gray
   ├─ Label (Title) - Text: "Five Nights at Taruna"
   ├─ Button (NewGameButton) - Text: "New Game"
   └─ Button (QuitButton) - Text: "Quit"
   ```
3. Attach `Scripts/Menu/main_menu.gd` to the root Control node
4. Connect button signals:
   - NewGameButton.pressed → `_on_new_game_pressed()`
   - QuitButton.pressed → `_on_quit_pressed()`
5. Save the scene

### Step 2: Create Night Intro (3 minutes)

1. Create scene: `Scenes/Menu/night_intro.tscn`
2. Add structure:
   ```
   Control (root)
   ├─ ColorRect (Background) - Black
   └─ Label (NightLabel) - Center aligned, large font
   ```
3. Attach `Scripts/Menu/night_intro.gd` to root
4. Save the scene

### Step 3: Create Night Complete (3 minutes)

1. Create scene: `Scenes/Menu/night_complete.tscn`
2. Add structure:
   ```
   Control (root)
   ├─ ColorRect (Background) - Black
   ├─ Label (SixAMLabel) - Text: "6 AM"
   └─ Control (PaycheckPanel)
       ├─ Label (NightLabel)
       └─ Label (AmountLabel)
   ```
3. Attach `Scripts/Menu/night_complete.gd` to root
4. Save the scene

### Step 4: Create Game Over (2 minutes)

1. Create scene: `Scenes/Menu/game_over.tscn`
2. Add structure:
   ```
   Control (root)
   ├─ ColorRect (Background) - Black
   └─ Label - Text: "GAME OVER"
   ```
3. Attach `Scripts/Menu/game_over.gd` to root
4. Save the scene

### Step 5: Update nights.tscn (10 minutes)

1. Open `Scenes/Nights/nights.tscn`
2. Add **JumpscareManager** node under root:
   - Add node: Node
   - Rename to: JumpscareManager
   - Attach script: `Scripts/Nights/jumpscare_manager.gd`
   - Set exports:
     - office_manager: `../OfficeElements`
     - camera_manager: `../CameraElements`
     - tablet_manager: `../TabletElements`

3. Add **Bonnie** AI under CharacterAI:
   - Add node: Node
   - Rename to: Bonnie
   - Attach script: `Scripts/Nights/AI/Characters/bonnie_ai.gd`
   - Set character export: 1 (Bonnie)
   - Set exports:
     - camera: `../../CameraElements`
     - office_manager: `../../OfficeElements`
     - jumpscare_manager: `../../JumpscareManager`
   - Add child Timer node, rename to BonnieTimer
   - Timer settings: wait_time = 4.97, autostart = true
   - Connect Timer.timeout() to Bonnie.move_check()

4. Repeat for **Chica**, **Foxy**, **Freddy** (similar structure)
   - Chica: character = 2, timer = 4.98
   - Foxy: character = 3, timer = 5.01
   - Freddy: character = 0, timer = 3.02

5. Update **AI Manager** exports:
   - Select CharacterAI node
   - Check "use_manual_levels" = true
   - Set bonnie_level = 5
   - Set chica_level = 5
   - Set foxy_level = 5
   - Set freddy_level = 5

6. Update **PowerManager** exports:
   - ai_manager: `../CharacterAI`
   - office_manager: `../OfficeElements`

7. Update **OfficeElements** exports:
   - door_manager: `Office/DoorAndLight`
   - tablet_manager: `../TabletElements`

8. Update **DoorAndLight** exports:
   - ai_manager: `../../../CharacterAI`

### Step 6: Change Main Scene

1. Open `Project → Project Settings → Application → Run`
2. Change Main Scene from `res://Scenes/Nights/nights.tscn` to `res://Scenes/Menu/main_menu.tscn`
3. Close project settings

### Step 7: Test!

Press F5 to run. You should see:
- ✅ Main menu
- ✅ Click "New Game" → Night intro appears
- ✅ After 3 seconds → Gameplay starts
- ✅ AI is active (check console for move_check calls)
- ✅ Wait until 6 AM → Night complete screen
- ✅ After delay → Back to main menu

## 🧪 Testing Individual Systems

### Test AI Movement (Currently Working)
1. Open nights.tscn directly (F6)
2. Watch the Output panel
3. AI should move through rooms every ~5 seconds
4. Check camera feeds to see characters appear/disappear

### Test Doors (Currently Working)
1. Run nights.tscn
2. Click left/right door buttons on edges of screen
3. Check debug labels at bottom show door states
4. Power should drain faster with doors closed

### Test Camera (Currently Working)
1. Run nights.tscn
2. Click bottom center to open tablet
3. Click room buttons to switch cameras
4. See animatronics on different cameras
5. Power drains when camera is up

### Test Power System (Currently Working)
1. Run nights.tscn
2. Close both doors and turn on both lights
3. Open camera
4. Watch power drain in HUD (top right)
5. Wait for power to hit 0%
6. Power out should trigger (needs Freddy AI added to fully work)

### Test Night Timer (Currently Working)
1. Run nights.tscn
2. Watch hour label in top right
3. Every 45 seconds = 1 hour
4. At 6 AM, night should complete (will work after night_complete.tscn exists)

## 🐛 Common Issues & Fixes

### "Scene file not found" error
- You forgot to create one of the menu scenes
- Check file names match exactly (case-sensitive)

### AI doesn't move
- Make sure use_manual_levels = true in ai_manager
- Make sure AI level is > 0
- Make sure Timer nodes have autostart = true
- Check Timer.timeout() is connected to move_check()

### Jumpscare doesn't work
- JumpscareManager node must exist in nights.tscn
- office_manager, jumpscare_manager exports must be set on AI nodes
- For now, jumpscare will show black screen (no animations yet)

### Door buttons don't work
- Make sure Area2D input signals are connected in scene
- Check door_and_light_manager exports are set

### Can't open camera
- Make sure Tablet_Button exists and is not disabled
- Check tablet_manager exports are set

## 📊 Current Working Features

✅ **Fully Functional:**
- Night progression tracking (saves between sessions)
- Power system with proper drain rates
- Door & light mechanics
- Office scrolling
- Camera system (4 rooms, expandable to 11)
- Night timer (12 AM to 6 AM)
- HUD display (power, time, debug info)

✅ **Code Complete (Needs Scene Setup):**
- Menu system (all scripts done)
- 4 animatronic AI behaviors (Freddy, Bonnie, Chica, Foxy)
- Jumpscare system (needs animations)
- Power outage handler
- Custom Night system
- Night select system

⏳ **Needs Assets:**
- Menu graphics (use placeholders for now)
- Jumpscare animations (single frame placeholders work)
- Camera room graphics for 11 cameras (duplicate existing)
- Sound effects (optional for testing)
- Character sprites at doors (optional for testing)

## 🎯 Next Steps After Testing

1. **If everything works:**
   - Start gathering/creating graphics
   - Expand cameras to 11 rooms
   - Add jumpscare placeholder animations
   - Create remaining menu scenes

2. **If something breaks:**
   - Check Output console for errors
   - Verify node paths in exports
   - Check signal connections
   - Make sure scene files exist

3. **When ready for polish:**
   - Replace placeholder graphics
   - Add sound effects
   - Add animations
   - Balance AI difficulty
   - Add camera detection for Freddy/Foxy

## 💬 Understanding the System

### How AI Works
- Each character has a Timer node that fires every ~5 seconds
- On timeout, `move_check()` is called
- AI level (0-20) determines chance to move
- Higher level = moves more often
- Characters move through predefined paths
- When they reach office door, they attack if door is open

### How Doors Work
- Closing door = animatronic can't enter
- Door closed while animatronic at door = they're blocked
- Foxy special: Bangs on door if blocked, drains extra power
- Freddy special: Can enter through camera + door interaction

### How Power Works
- Starts at 100%
- Drains passively (always)
- Drains faster with doors/lights/camera
- At 0%, power out sequence triggers
- Freddy appears in office during power out

### How Nights Work
- GlobalData tracks current night (1-6, or 7 for custom)
- Each night has preset AI levels
- Completing night unlocks next night
- Progress saves automatically
- Custom Night unlocked after Night 6

## 🔍 Debug Tips

### See AI Debug Info
Add this to any AI script's `move_check()`:
```gdscript
print("%s at step %d, room %d, level %d" % [_get_character_name(), step, current_room, ai_level])
```

### Force Jumpscare (Testing)
In nights.tscn, select JumpscareManager, go to Script tab, and run:
```gdscript
trigger_jumpscare("Freddy")
```

### Force Power Out
Select PowerManager node and run:
```gdscript
current_power = 0.1
```

### Skip to 6 AM
Select NightTimer node and run:
```gdscript
current_hour_index = 5
elapsed = seconds_per_hour - 1
```

### View Current Night Data
In any script, print:
```gdscript
print("Night: ", GlobalData.current_night)
print("AI Levels: ", GlobalData.get_night_ai_levels())
print("Custom: ", GlobalData.is_custom_night)
```

---

**You're ready to start testing!** The hard part (coding) is done. Now it's just about adding the visuals and audio. Good luck! 🎮
