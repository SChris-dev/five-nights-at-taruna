# Five Nights at Taruna - Quick Reference Card

## 📋 Your 6 Anomalies

| # | Name | Start Room | Behavior | Door | AI Level |
|---|------|-----------|----------|------|----------|
| 0 | **INST Anomaly** | ROOM_01 | Roams → Left Door | Left | 5 |
| 1 | **TKJ Roamer** | ROOM_07 | Roams → Right Door | Right | 5 |
| 2 | **TKR Sprinter** | ROOM_08 | Foxy Sprint → Right | Right | 8 |
| 3 | **Big Robot** | ROOM_09 | Slow → Right Door | Right | 3 |
| 4 | **RPL Disruptor** | ROOM_06 | Static (Camera Breaker) | - | - |
| 5 | **TKJ Drainer** | ROOM_07 | Static (Power Drainer) | - | - |

## 🗺️ Room Map (13 Cameras)

```
01: INST Room ────────────┐
02: Upper Hallway         │
03: Outer Auditorium      ├─ Main Areas
04: School Yard           │
05: The Stairs ───────────┘

06: RPL Room ─────────────── Camera Disruptor
07: TKJ Room ─────────────── Power Drainer + Roamer

08: TKR Hallway ──────────── Sprinter
09: TPM/LAS Hallway ──────── Big Robot

10: South Hallway ────────── Near LEFT door
11: North Hallway ────────── Near RIGHT door
12: Lower Hallway ────────── See Sprinter running

13: OSIS Room ────────────── Audio only
```

## 🎯 Movement Paths

```
INST:       01 → 02 → 10 → LEFT DOOR
TKJ Roamer: 07 → 11 → RIGHT DOOR
TKR Sprint: 08 → 12 → RIGHT DOOR (fast!)
Big Robot:  09 → 11 → RIGHT DOOR (slow)
```

## 🛠️ Scene Setup - Copy & Paste Node Names

```
CharacterAI/
├─ INSTAnomaly (inst_anomaly.gd, character=0)
├─ TKJRoamer (tkj_roamer.gd, character=1)
├─ TKRSprinter (tkr_sprinter.gd, character=2)
├─ BigRobot (big_robot.gd, character=3)
├─ RPLDisruptor (rpl_disruptor.gd, character=4)
└─ TKJDrainer (tkj_drainer.gd, character=5)
```

## 🔢 rooms Array Format

```gdscript
# Each room: [INST, TKJ_R, TKR_S, BigR, RPL_D, TKJ_D]
rooms = [
    [1, 0, 0, 0, 0, 0],  # 01: INST starts here
    [0, 0, 0, 0, 0, 0],  # 02
    [0, 0, 0, 0, 0, 0],  # 03
    [0, 0, 0, 0, 0, 0],  # 04
    [0, 0, 0, 0, 0, 0],  # 05
    [0, 0, 0, 0, 1, 0],  # 06: RPL Disruptor always
    [0, 1, 0, 0, 0, 1],  # 07: TKJ Roamer + Drainer
    [0, 0, 1, 0, 0, 0],  # 08: TKR Sprinter
    [0, 0, 0, 1, 0, 0],  # 09: Big Robot
    [0, 0, 0, 0, 0, 0],  # 10
    [0, 0, 0, 0, 0, 0],  # 11
    [0, 0, 0, 0, 0, 0],  # 12
    [0, 0, 0, 0, 0, 0]   # 13
]
```

## 🎨 Graphics Needed (24 Frames)

| Room | Frames | What to Show |
|------|--------|--------------|
| 01 | 2 | INST present, empty |
| 02 | 2 | INST passing, empty |
| 03-05 | 1 each | Static rooms |
| 06 | 1+effect | RPL always there + glitch when active |
| 07 | 2 | Both anomalies, just drainer |
| 08 | 4 | Idle, preparing, sprinting, empty |
| 09 | 2 | Robot, empty |
| 10 | 2 | INST at door, empty |
| 11 | 3 | TKJ at door, Robot at door, empty |
| 12 | 2 | Sprinter running, empty |
| 13 | 1 | Audio indicator |

## ⚡ Export Paths Cheat Sheet

For each anomaly node:
```
camera: ../../CameraElements
office_manager: ../../OfficeElements
jumpscare_manager: ../../JumpscareManager
```

For fix buttons:
```
ai_manager: ../../../CharacterAI
```

For RPLDisruptor:
```
camera_manager: ../../CameraElements
```

For TKJDrainer:
```
power_manager: ../../PowerManager
```

## 🐛 Quick Debug Commands

```gdscript
# See all anomaly positions
print(get_node("/root/Nights/CameraElements").rooms)

# Force anomaly to move
$CharacterAI/INSTAnomaly.move_options()

# Check AI levels
print($CharacterAI/INSTAnomaly.ai_level)

# Force fix activation
$CharacterAI/RPLDisruptor._disrupt_camera()
$CharacterAI/TKJDrainer._start_draining()
```

## 🎚️ Difficulty Tuning

```gdscript
# Timer wait_time values:
Easy: 6-8 seconds
Normal: 4-5 seconds
Hard: 2-3 seconds
Very Hard: 1-2 seconds

# AI Levels:
Easy: 0-5
Normal: 5-10
Hard: 10-15
Very Hard: 15-20
```

## 📝 Testing Checklist

```
[ ] All 6 nodes added
[ ] All timers connected
[ ] rooms array = [6] × 13
[ ] Fix buttons added (ROOM_06, ROOM_07)
[ ] Exports set correctly
[ ] Console shows movement
[ ] Cameras update
[ ] Doors work
[ ] Fix buttons work
```

## 🚨 Common Error Messages

| Error | Cause | Fix |
|-------|-------|-----|
| "Invalid index" | rooms array wrong size | Make it [6] × 13 |
| "Timeout not connected" | Timer signal missing | Connect to move_check() |
| "Invalid call" | Export path wrong | Check ../../ paths |
| "Cannot index" | Character enum mismatch | Check 0-5 indices |

## 💾 File Locations

```
Scripts/Nights/AI/Characters/
├─ inst_anomaly.gd
├─ tkj_roamer.gd
├─ tkr_sprinter.gd
├─ big_robot.gd
├─ rpl_disruptor.gd
└─ tkj_drainer.gd

Scripts/Nights/Camera/
├─ camera.gd (base class)
├─ camera_fix_button.gd (fix buttons)
└─ Setups/tjp_setup.gd (your setup)

Documentation/
├─ TARUNA_SETUP_GUIDE.md (full setup)
├─ TARUNA_SUMMARY.md (overview)
├─ QUICK_DEBUG.md (debugging)
└─ QUICK_REFERENCE.md (this file)
```

## 🎯 1-Minute Test

```bash
1. F6 (run nights.tscn)
2. Check Output: "[INSTAnomaly] Moving!"
3. Open camera
4. Switch to ROOM_02
5. See INST anomaly on screen
✅ System working!
```

## 📞 Help

- **Read:** `QUICK_DEBUG.md` for solutions
- **Full Guide:** `TARUNA_SETUP_GUIDE.md`
- **Discord:** https://discord.gg/CHgH8KJyqE

---

**Print this page and keep it next to your keyboard!** 📄✨
