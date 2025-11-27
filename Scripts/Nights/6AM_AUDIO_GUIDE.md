# 6 AM Audio Guide

## Overview

Added the iconic FNAF 6 AM bell chime and cheering sounds that play when the night is complete (06:00 WIB reached).

## How It Works

```
Night timer reaches 06:00 WIB
    ↓
⏸️ GAME FREEZES (everything stops)
    ↓
🔔 Bell chime plays (0.0 dB - loud and clear)
    ↓
Wait 1.0 second (configurable)
    ↓
🎊 Children cheering plays (-5.0 dB)
    ↓
Wait 1.5 seconds after sounds
    ↓
🌑 Smooth fade to black (2.0 seconds)
    ↓
Transition to Night Complete screen
```

## Features

### Bell Chime
- Plays immediately when 6 AM is reached
- Should be loud and satisfying (0.0 dB default)
- Classic FNAF bell sound

### Children Cheering (Optional)
- Plays after bell chime (1 second delay default)
- Represents school starting/kids arriving
- Slightly quieter than bell (-5.0 dB default)
- Optional - can leave unassigned

### Smooth Victory Transition
- **Game freezes** when 6 AM hits (everything stops moving)
- Sounds play during freeze
- **Smooth fade to black** (configurable duration)
- Clean, cinematic transition
- Player can savor the victory moment

### Configurable Timing
- Cheer delay adjustable (how long after bell)
- Wait time after sounds (before fade starts)
- Fade duration (how long fade takes)
- Volume control for both sounds

## Setup Instructions

### Step 1: Find NightTimer Node

Open `Scenes/Nights/nights.tscn`:
1. Find the `NightTimer` node
2. Select it

### Step 2: Assign Audio Files

In the Inspector, find **6 AM Audio** group:

#### **Bell Chime Sound** (Required)
- Drag your bell/clock chime audio file
- This is the main 6 AM sound
- Should be 2-3 seconds long
- Classic bell ring sound

#### **Cheer Sound** (Optional)
- Drag your children cheering audio file
- Plays after the bell
- Should be 1-2 seconds long
- Optional - leave empty if you don't want it

### Step 3: Adjust Settings

#### **Bell Volume** (default: 0.0)
- 0.0 = Full volume (recommended)
- -3.0 = Slightly quieter
- Should be loud and clear

#### **Cheer Volume** (default: -5.0)
- -5.0 = Moderate volume (recommended)
- -8.0 = Quieter
- Should be noticeable but not overwhelming

#### **Cheer Delay** (default: 1.0)
- 1.0 = 1 second delay between bell and cheer
- 0.5 = Quick transition
- 1.5 = Longer pause

#### **Freeze On Victory** (default: true)
- true = Game freezes, creating victory moment
- false = Game continues during sounds (less dramatic)

#### **Fade Out Duration** (default: 2.0)
- 2.0 = 2 second fade to black
- 1.5 = Faster fade
- 3.0 = Slower, more dramatic fade

#### **Wait After Sounds** (default: 1.5)
- 1.5 = 1.5 seconds after sounds before fade starts
- 1.0 = Quicker transition
- 2.0 = More time to enjoy victory

## Audio File Recommendations

### Bell Chime Sound

**Type:** School bell, clock chime, or alarm bell

**Characteristics:**
- Duration: 2-3 seconds
- Clear and distinct
- Should feel satisfying and relieving
- Not too harsh or jarring

**Examples:**
- School bell ringing
- Church bell single chime
- Clock tower chime
- Alarm bell (not fire alarm, more pleasant)

**Where to find:**
- Freesound.org: Search "school bell" or "clock chime"
- OpenGameArt.org
- Record your own bell sound
- Use FNAF-style bell recreation

### Cheer Sound

**Type:** Children cheering, crowd cheer, celebration

**Characteristics:**
- Duration: 1-2 seconds
- Multiple voices
- Sounds distant/muffled (like kids outside)
- Happy, relieved feeling

**Examples:**
- School playground sounds
- Children cheering
- Crowd of kids celebrating
- Distant playground noise

**Where to find:**
- Freesound.org: Search "children cheering" or "playground"
- OpenGameArt.org
- Create from multiple voice clips

## How Player Experiences It

### Successful Night:
```
Player: *Checking cameras nervously as timer ticks*
Timer: 05:59 WIB...
Player: "Almost there... almost there..."
Timer: 06:00 WIB

⏸️ *Everything freezes - animatronics stop, doors locked in place*
🔔 DING DING DING! (Bell chime)
Player: "YES! I SURVIVED!"
🎊 *Children cheering*
Player: "Made it through the night!"
🌑 *Screen smoothly fades to black*
[Clean transition to Night Complete screen]
```

### Without This System:
- Timer just hits 6 AM
- Instant jarring scene change
- No freeze or fade
- Less satisfying victory
- Missing iconic FNAF moment

### With This System:
- Timer hits 6 AM
- ⏸️ Game freezes (dramatic pause)
- 🔔 Bell rings → instant relief
- 🎊 Cheer confirms success
- 🌑 Smooth fade to black
- **MUCH MORE SATISFYING!**
- Classic FNAF cinematic experience

## Technical Details

### Audio Players:
- Creates temporary AudioStreamPlayer for each sound
- Plays once (one-shot)
- Auto-deletes when finished
- No memory leaks

### Timing:
- Bell plays immediately at 6 AM
- Cheer waits `cheer_delay` seconds (default: 1.0)
- Total wait is 3.5 seconds before scene change
- Gives player time to enjoy the victory

### Signal Flow:
```
NightTimer._process() detects 6 AM
    ↓
Emits "night_won" signal
    ↓
Calls _handle_night_complete()
    ↓
Freezes game (get_tree().paused = true)
    ↓
Calls _play_6am_sounds()
    ↓
Plays bell → waits → plays cheer
    ↓
Waits for cheer_delay + wait_after_sounds
    ↓
Calls _fade_to_black()
    ↓
Smooth tween fade (fade_out_duration)
    ↓
Unpauses game
    ↓
Changes to night_complete.tscn
```

## Customization Options

### Only Bell (No Cheer):
- Assign **Bell Chime Sound**
- Leave **Cheer Sound** empty
- Simple, clean 6 AM sound

### Bell + Cheer (Classic FNAF):
- Assign both sounds
- Default settings work well
- Most authentic experience

### Custom Timing:
- Adjust **Cheer Delay** for different pacing
- Quick: 0.5 seconds
- Standard: 1.0 seconds
- Dramatic: 1.5-2.0 seconds

### Volume Mix:
- Bell loud, cheer quiet (default)
- Both loud: Bell 0.0, Cheer 0.0
- Both moderate: Bell -3.0, Cheer -5.0

## Testing

1. Start a night
2. Set `seconds_per_hour` very low (like 5.0) for quick testing
3. Wait for timer to reach 06:00 WIB
4. Listen for:
   - Bell chime plays
   - Pause (1 second)
   - Cheer plays
   - Screen transitions after ~3.5 seconds

## Integration with Night Complete Screen

The 6 AM sounds play BEFORE transitioning to the Night Complete screen:

```
Timeline:
0.0s - Bell chime starts
1.0s - Cheer starts
3.5s - Transition to night_complete.tscn
```

This gives player a moment to enjoy the victory before seeing the completion screen with paycheck/stats.

## Audio Design Tips

### Bell Chime:
- Should be instantly recognizable
- Create sense of relief
- Not too long (2-3 seconds max)
- Clear, distinct sound
- Volume: Full or nearly full

### Cheer Sound:
- Should feel distant (like kids outside)
- Add slight reverb for distance
- Not overwhelming
- Complements the bell
- Volume: Moderate

### Overall Mix:
- Bell is the star → full volume
- Cheer is supporting → quieter
- Should feel rewarding and satisfying
- Player earned this moment!

## Troubleshooting

**No sound playing?**
- Check if bell_chime_sound is assigned
- Look for console message: "No bell chime sound configured"
- Verify audio file is imported correctly

**Only bell plays, no cheer?**
- Cheer is optional, this is normal if not assigned
- Check if cheer_sound is assigned
- Look for console message: "No cheer sound configured"

**Sounds too loud/quiet?**
- Adjust bell_volume and cheer_volume
- Try different values
- Test in actual gameplay (not just editor)

**Transition too fast?**
- Sounds play but screen changes immediately
- Check that await statements are working
- Total wait is 3.5 seconds by default

**Cheer plays at wrong time?**
- Adjust cheer_delay
- Default is 1.0 second after bell
- Try 0.5 or 1.5 for different timing

## Summary

✅ Bell chime plays at 6 AM (06:00 WIB)
✅ Optional cheer sound after bell
✅ Configurable volumes and timing
✅ Creates satisfying victory moment
✅ Classic FNAF experience
✅ Easy to set up with exports
✅ Works automatically when night is won
✅ Smooth transition to completion screen

The iconic "I survived!" moment is now complete! 🎉
