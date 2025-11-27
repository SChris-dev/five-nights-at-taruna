# AI Balance Recommendations

## Current Issues

### Night 1: TOO EASY
- Everything at 0 = no threats at all
- Player has nothing to do
- No tutorial value

### Night 2: Decent intro
- Good gentle start with roamers
- TKR at 1 is fair

### Night 3: UNBALANCED
- TKJ Roamer drops to 0 (why?)
- TKR jumps to 5 (too fast)
- Anomalies suddenly active (jarring)

### Night 4: OK
- Better progression
- Multiple threats

### Night 5: Good
- All active, challenging

### Night 6: VERY HARD
- Big Robot at 16 is EXTREMELY aggressive
- TKR at 12 is almost constant sprinting
- May be too difficult

## Recommended Balanced Progression

```gdscript
var ai_presets: Dictionary = {
	# NIGHT 1 - Tutorial (Learn basics)
	1: {
		"inst": 0,              # Not active (learn without pressure)
		"tkj_roamer": 2,        # Gentle movement (teaches camera use)
		"tkr_sprinter": 0,      # Not active yet (too stressful for tutorial)
		"big_robot": 1,         # Very slow (teaches watching specific threats)
		"rpl_disruptor": 0,     # Not active (don't overwhelm)
		"tkj_drainer": 0        # Not active (power is fine)
	},
	
	# NIGHT 2 - Introduction (Add door mechanics)
	2: {
		"inst": 2,              # Now active (teaches door checking)
		"tkj_roamer": 3,        # Slightly more active
		"tkr_sprinter": 2,      # Introduce sprinter (low threat)
		"big_robot": 2,         # Slightly faster
		"rpl_disruptor": 0,     # Still not active
		"tkj_drainer": 0        # Still not active
	},
	
	# NIGHT 3 - Complexity (Add camera mechanics)
	3: {
		"inst": 3,              # More frequent
		"tkj_roamer": 4,        # Active threat
		"tkr_sprinter": 4,      # Real threat now
		"big_robot": 4,         # Must watch regularly
		"rpl_disruptor": 3,     # Introduce camera disruption
		"tkj_drainer": 2        # Introduce power drain (low)
	},
	
	# NIGHT 4 - Multi-tasking (Everything matters)
	4: {
		"inst": 4,              # Frequent door checks needed
		"tkj_roamer": 5,        # Consistent pressure
		"tkr_sprinter": 6,      # Sprint often
		"big_robot": 6,         # Fast movement
		"rpl_disruptor": 5,     # Regular disruptions
		"tkj_drainer": 4        # Notable power drain
	},
	
	# NIGHT 5 - High Pressure (True challenge)
	5: {
		"inst": 5,              # Very frequent
		"tkj_roamer": 7,        # High activity
		"tkr_sprinter": 8,      # Frequent sprints
		"big_robot": 8,         # Must watch constantly
		"rpl_disruptor": 7,     # Frequent disruptions
		"tkj_drainer": 6        # Significant power drain
	},
	
	# NIGHT 6 - Expert (Maximum challenge)
	6: {
		"inst": 6,              # Constant threat
		"tkj_roamer": 10,       # Maximum reasonable
		"tkr_sprinter": 10,     # Very frequent sprints
		"big_robot": 12,        # Fast but beatable (not 16!)
		"rpl_disruptor": 10,    # Constant disruptions
		"tkj_drainer": 8        # Heavy power drain
	},
	
	# NIGHT 7 - Custom Night
	7: {
		"inst": 0,
		"tkj_roamer": 0,
		"tkr_sprinter": 0,
		"big_robot": 0,
		"rpl_disruptor": 0,
		"tkj_drainer": 0
	}
}
```

## Balancing Philosophy

### Progression Curve:
```
Night 1: Learn cameras and basic watching
Night 2: Learn door mechanics with INST
Night 3: Learn camera fixes with anomalies
Night 4: Manage multiple threats simultaneously
Night 5: High skill requirement, all systems active
Night 6: Expert level, tight execution needed
```

### Character-Specific Notes:

**INST (Door Anomaly):**
- Start Night 2 at level 2
- Increase steadily
- Cap at 6 (higher = too random)

**TKJ Roamer:**
- Start Night 1 at level 2 (tutorial)
- Steady increase
- Cap at 10

**TKR Sprinter:**
- Start Night 2 at level 2
- Increase faster (main threat)
- Cap at 10 (higher = unfair)

**Big Robot:**
- Start Night 1 at level 1
- Slower increase (predictable threat)
- Cap at 12 (16 is too aggressive!)

**RPL Disruptor:**
- Start Night 3 at level 3
- Players need time to learn fix mechanic
- Cap at 10

**TKJ Drainer:**
- Start Night 3 at level 2
- Lower than disruptor (power is critical)
- Cap at 8 (higher = impossible to manage)

## Difficulty Curve Graph

```
20 |                                          
   |                                    
15 |                            Night 6 (old)
   |                               ★
10 |                    ●━━━━●     
   |              ●━━━●
 5 |        ●━━●              Night 6 (new)
   |  ●━━●                        ●
 0 |●                              
   └────────────────────────────────
    N1  N2  N3  N4  N5  N6

● = Recommended (smooth curve)
★ = Old Night 6 (spike!)
```

## Testing Recommendations

### Night 1:
- Player should survive easily
- Learn camera system without pressure
- Maybe 1-2 close calls

### Night 2:
- First real challenge
- INST teaches door importance
- TKR introduces sprint mechanic
- Should be passable with focus

### Night 3:
- Noticeable difficulty increase
- Camera fixes become important
- Multiple threats active
- First night some players might fail

### Night 4:
- Clear multi-tasking required
- Power management matters
- All mechanics in play
- Moderate difficulty

### Night 5:
- High skill requirement
- Tight execution needed
- Few mistakes allowed
- Classic "Night 5" difficulty

### Night 6:
- Expert level
- Maximum reasonable difficulty
- Possible but very hard
- NOT impossible (old 16 was too much)

## Quick Comparison

### Your Original:
```
N1: All 0 → TOO EASY (nothing happens)
N3: Roamer 0 → Why drop to zero?
N6: Big Robot 16 → TOO HARD (unfair)
```

### Recommended:
```
N1: Gentle start with tutorial threats
N3: All threats active, smooth progression
N6: Maximum challenge but fair (12 not 16)
```

## Implementation

Replace your ai_presets dictionary with the recommended one above.

Test each night and adjust individual values by ±1 or ±2 based on:
- Is it beatable?
- Is it fun?
- Does it teach the right lessons?
- Is progression smooth?

## Advanced Balancing

If you want more granular control:

### Easy Mode:
Multiply all values by 0.7

### Hard Mode:
Multiply all values by 1.3

### Custom Night:
Let players set each character 0-20
(But warn them 20 is INSANE)
