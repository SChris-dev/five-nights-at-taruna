extends Node

## Audio Integration Examples
## Copy these code snippets to integrate AudioManager with your existing systems

# ============================================
# EXAMPLE 1: Door and Light Manager Integration
# ============================================
# Add this to Scripts/Nights/Office/door_and_light_manager.gd

"""
# Add at top of script:
@onready var audio_manager = get_node("/root/Nights/AudioManager") # Adjust path as needed

# In toggle_door() function:
func toggle_door(side: String) -> void:
	if side == "left":
		left_door_closed = !left_door_closed
		if audio_manager:
			audio_manager.play_door_sound()  # ADD THIS LINE
		# ... rest of your code
	elif side == "right":
		right_door_closed = !right_door_closed
		if audio_manager:
			audio_manager.play_door_sound()  # ADD THIS LINE
		# ... rest of your code

# In toggle_light() function:
func toggle_light(side: String) -> void:
	if side == "left":
		left_light_on = !left_light_on
		if audio_manager:
			if left_light_on:
				audio_manager.play_light_on_sound()  # ADD THIS - Start looping
			else:
				audio_manager.play_light_off_sound()  # ADD THIS - Stop looping
		# ... rest of your code
	elif side == "right":
		right_light_on = !right_light_on
		if audio_manager:
			if right_light_on:
				audio_manager.play_light_on_sound()  # ADD THIS - Start looping
			else:
				audio_manager.play_light_off_sound()  # ADD THIS - Stop looping
		# ... rest of your code
"""

# ============================================
# EXAMPLE 2: Camera Manager Integration
# ============================================
# Add this to Scripts/Nights/Camera/camera.gd

"""
# Add at top of script:
@onready var audio_manager = get_node("../../AudioManager") # Adjust path as needed

# When camera opens:
func open_camera() -> void:
	# ... your existing code ...
	if audio_manager:
		audio_manager.play_camera_open_sound()  # ADD THIS LINE

# When camera closes:
func close_camera() -> void:
	# ... your existing code ...
	if audio_manager:
		audio_manager.play_camera_close_sound()  # ADD THIS LINE

# When switching camera feeds:
func switch_feed(feed_id: int) -> void:
	# ... your existing code ...
	if audio_manager:
		audio_manager.play_camera_switch_sound()  # ADD THIS LINE
"""

# ============================================
# EXAMPLE 3: Tablet Manager Integration
# ============================================
# Add this to Scripts/Nights/tablet_manager.gd

"""
# Add at top of script:
@onready var audio_manager = get_node("../AudioManager") # Adjust path as needed

# When tablet opens:
func open_tablet() -> void:
	is_tablet_up = true
	# ... your existing code ...
	if audio_manager:
		audio_manager.play_camera_open_sound()  # ADD THIS LINE

# When tablet closes:
func close_tablet() -> void:
	is_tablet_up = false
	# ... your existing code ...
	if audio_manager:
		audio_manager.play_camera_close_sound()  # ADD THIS LINE
"""

# ============================================
# EXAMPLE 4: Power Manager Integration
# ============================================
# Add this to Scripts/Nights/power_manager.gd

"""
# Add at top of script:
@onready var audio_manager = get_node("../AudioManager") # Adjust path as needed

# When power runs out:
func _on_power_depleted() -> void:
	# ... your existing code ...
	if audio_manager:
		audio_manager.play_power_out_sequence()  # ADD THIS LINE
	# ... rest of your code ...
"""

# ============================================
# EXAMPLE 5: Character AI Integration
# ============================================
# Add this to individual character scripts (e.g., freddy_ai.gd)

"""
# Add at top of script:
@onready var audio_manager = get_tree().get_first_node_in_group("audio_manager")

# When character moves or does something scary:
func move_to_next_room() -> void:
	# ... your existing code ...
	if audio_manager:
		audio_manager.play_character_sound("freddy")  # ADD THIS LINE
		# Or play specific sound: audio_manager.play_character_sound("freddy", 0)
"""

# ============================================
# EXAMPLE 6: Camera Fix Button Integration
# ============================================
# Add this to Scripts/Nights/Camera/camera_fix_button.gd

"""
# Add at top of script:
@onready var audio_manager = get_tree().get_first_node_in_group("audio_manager")

# When button is pressed:
func _on_pressed() -> void:
	if audio_manager:
		audio_manager.play_button_click_sound()  # ADD THIS LINE
	# ... your existing code ...
"""

# ============================================
# EXAMPLE 7: RPL Disruptor Integration
# ============================================
# Add this to Scripts/Nights/AI/Characters/rpl_disruptor.gd

"""
# Add at top of script:
@onready var audio_manager = get_tree().get_first_node_in_group("audio_manager")

# When disrupting cameras:
func _disrupt_camera() -> void:
	# ... your existing code ...
	if audio_manager:
		audio_manager.play_static_sound()  # ADD THIS LINE
	# ... rest of your code ...
"""

# ============================================
# EXAMPLE 8: Button Hover Sound
# ============================================
# Add to any button that needs hover sound

"""
# Connect the mouse_entered signal:
func _ready():
	mouse_entered.connect(_on_mouse_entered)

func _on_mouse_entered():
	if audio_manager:
		audio_manager.play_button_hover_sound()
"""

# ============================================
# EXAMPLE 9: Custom Phone Call Trigger
# ============================================
# If you need to manually trigger a phone call

"""
# Play a specific phone call:
audio_manager.play_phone_call(my_custom_audio_stream)

# Stop current phone call:
audio_manager.stop_phone_call()

# Check if phone call is playing:
if audio_manager.is_phone_call_playing():
	print("Phone call in progress")
"""

# ============================================
# EXAMPLE 10: Controlling Ambient Sounds
# ============================================
# Disable ambient during cutscenes or important moments

"""
# Disable ambient sounds:
audio_manager.set_ambient_enabled(false)

# Re-enable after cutscene:
audio_manager.set_ambient_enabled(true)
"""

# ============================================
# QUICK SETUP CHECKLIST
# ============================================

"""
1. Add AudioManager node to nights.tscn scene
2. Assign audio files in Inspector:
   - Phone calls (1-7)
   - Ambient sounds array (10-15 sounds)
   - UI sounds (door, light, camera, button, static)
   - Power out sounds
3. Add character sounds to dictionary (optional)
4. Add audio_manager references to your scripts (see examples above)
5. Test in game!
"""
