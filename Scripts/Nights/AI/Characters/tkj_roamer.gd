extends AI

# TKJ Roaming Anomaly - Roams around school to right door
# Path: TKJ Room (7) -> Stairs (5) -> Outer Auditorium (3) -> TKR Room (8) -> North Hallway (11) -> Right Door

#enum {
	#ROOM_07,  # TKJ Room (starting position)
	#ROOM_05, # STAIRS
	#ROOM_03, # Outer Audiotorium (yes this is right.)
	#ROOM_08, # TKR Room
	#ROOM_11,  # North Hallway (near right door)
	#RIGHT_DOOR # At office (virtual room for attack)
#}

enum {
	ROOM_01,  # INST Room - Roaming anomaly starts here
	ROOM_02,  # Upper Hallway
	ROOM_03,  # Outer Auditorium (static)
	ROOM_04,  # School Yard (static)
	ROOM_05,  # The Stairs - INST can pass through here
	ROOM_06,  # RPL Room - Camera disruptor (static)
	ROOM_07,  # TKJ Room - Power drainer + Roaming anomaly
	ROOM_08,  # TKR Hallway - Sprinter (Foxy-like)
	ROOM_09,  # TPM/LAS Hallway - Big robot
	ROOM_10,  # South Hallway (near left door)
	ROOM_11,  # North Hallway (near right door)
	ROOM_12,  # Lower Hallway (sprinter visible)
	ROOM_13,   # OSIS Room (audio only)
	RIGHT_DOOR
}

var door_wait_timer: float = 0.0
var max_door_wait: float = 30.0  # Base wait time
var is_retreating: bool = false
var retreat_steps: int = 0
var waiting_at_door: bool = false
var door_wait_grace_period: float = 0.0  # Time to wait before attacking

func _ready() -> void:
	current_room = ROOM_07
	door_side = "right"
	# Calculate grace period based on AI level (lower AI = longer wait)
	# AI 20 = 3 seconds, AI 10 = 6 seconds, AI 5 = 9 seconds, AI 0 = 12 seconds
	door_wait_grace_period = 12.0 - (ai_level * 0.45)

func _process(delta: float) -> void:
	if waiting_at_door:
		door_wait_timer += delta

		# Check if player turned on light
		if office_manager and office_manager.door_manager:
			var door_manager = office_manager.door_manager
			if door_manager.right_light_on:
				print("[TKJRoamer] ⚠️ VISIBLE IN RIGHT LIGHT! Player can see me!")
				_show_at_door_sprite(true)
			else:
				_show_at_door_sprite(false)

		# After grace period, check if door is closed
		if door_wait_timer >= door_wait_grace_period:
			_check_door_attack()

		# If waited too long at door, leave
		if door_wait_timer >= max_door_wait:
			print("[TKJRoamer] Waited too long, leaving door")
			_start_retreat()

	elif is_at_door and not waiting_at_door:
		# This should only happen if anomaly is actually at door but not waiting
		print("[TKJRoamer] WARNING: is_at_door=true but waiting_at_door=false")
		door_wait_timer += delta
		if door_wait_timer >= max_door_wait:
			print("[TKJRoamer] Fixing stuck state, leaving door area")
			_leave_door_area()

func move_options() -> void:
	if is_retreating:
		_handle_retreat()
		return
	
	match step:
		0:  # At TKJ Room
			move_to(ROOM_05)  # Move to Stairs
		
		1:  # At Stairs
			move_to(ROOM_03)  # Move to Outer Auditorium
			
		2:  # At Outer Auditorium
			move_to(ROOM_08)  # Move to TKR Room
		
		3:  # At TKR Room
			move_to(ROOM_11)  # Move to North Hallway
		
		4:  # At North Hallway
			print("[TKJRoamer] At North Hallway, proceeding to door")
			_reach_door()  # Attack from here
		
		5:  # At door (shouldn't happen in normal flow)
			print("[TKJRoamer] ERROR: At door step but not at door!")
			pass
		
		_:
			pass

func _handle_retreat() -> void:
	if retreat_steps > 0:
		retreat_steps -= 1
		print("[TKJRoamer] Retreating, steps left:", retreat_steps, " current step:", step, " current_room:", current_room)
		# Move back one step in the path
		match step:
			5:  # At door, move back to North Hallway
				step -= 1  # Decrement to step 4
				# current_room is RIGHT_DOOR (virtual), so just set to ROOM_11
				current_room = ROOM_11
				camera.rooms[ROOM_11][character] = State.PRESENT
				camera.update_feeds([ROOM_11])
				print("[TKJRoamer] Moved back to North Hallway from door")
			4:  # At North Hallway, move back to TKR Room
				step -= 1
				var old_room = current_room  # Store ROOM_11
				camera.rooms[old_room][character] = State.ABSENT  # Clear ROOM_11
				current_room = ROOM_08
				camera.rooms[ROOM_08][character] = State.PRESENT
				camera.update_feeds([old_room, ROOM_08])
				print("[TKJRoamer] Moved back to TKR Room")
			3:  # At TKR Room, move back to Outer Auditorium
				step -= 1
				var old_room = current_room  # Store ROOM_08
				camera.rooms[old_room][character] = State.ABSENT  # Clear ROOM_08
				current_room = ROOM_03
				camera.rooms[ROOM_03][character] = State.PRESENT
				camera.update_feeds([old_room, ROOM_03])
				print("[TKJRoamer] Moved back to Outer Auditorium")
			2:  # At Outer Auditorium, move back to Stairs
				step -= 1
				var old_room = current_room  # Store ROOM_03
				camera.rooms[old_room][character] = State.ABSENT  # Clear ROOM_03
				current_room = ROOM_05
				camera.rooms[ROOM_05][character] = State.PRESENT
				camera.update_feeds([old_room, ROOM_05])
				print("[TKJRoamer] Moved back to Stairs")
			1:  # At Stairs, move back to TKJ Room
				step -= 1
				var old_room = current_room  # Store ROOM_05
				camera.rooms[old_room][character] = State.ABSENT  # Clear ROOM_05
				current_room = ROOM_07
				camera.rooms[ROOM_07][character] = State.PRESENT
				camera.update_feeds([old_room, ROOM_07])
				print("[TKJRoamer] Moved back to TKJ Room")
	else:
		# Finished retreating, continue forward
		is_retreating = false
		print("[TKJRoamer] Finished retreating, resuming from step", step)
		# Continue with normal movement from current position
		# The next timer will trigger move_options() which will handle the current step

func _reach_door() -> void:
	print("[TKJRoamer] Reached right door, waiting for player...")
	print("[TKJRoamer] Current room before door:", current_room)
	
	# Clear from North Hallway camera (current_room should be ROOM_11)
	if current_room == ROOM_11:
		camera.rooms[ROOM_11][character] = State.ABSENT
		camera.update_feeds([ROOM_11])
		print("[TKJRoamer] Cleared from North Hallway (ROOM_11) camera")
	else:
		print("[TKJRoamer] WARNING: current_room is not ROOM_11! current_room=", current_room)
	
	is_at_door = true
	waiting_at_door = true
	door_wait_timer = 0.0
	step = 5  # Mark as at door
	current_room = RIGHT_DOOR  # Track that we're at the door (virtual room)
	
	# Register with door manager so light reveals work
	if office_manager and office_manager.door_manager:
		office_manager.door_manager.register_animatronic_at_door("TKJRoamer", "right")
		print("[TKJRoamer] Registered at right door. Grace period:", door_wait_grace_period, "seconds")
	
	# TODO: Play breathing sound or door creak sound

func _check_door_attack() -> void:
	print("[TKJRoamer] Grace period over, checking door...")
	print("[TKJRoamer] office_manager exists:", office_manager != null)
	
	if office_manager:
		print("[TKJRoamer] office_manager name:", office_manager.name)
		print("[TKJRoamer] office_manager.door_manager exists:", office_manager.door_manager != null)
		if office_manager.door_manager:
			print("[TKJRoamer] door_manager name:", office_manager.door_manager.name)
	
	if office_manager and office_manager.has_method("is_door_closed"):
		var door_closed = office_manager.is_door_closed("right")
		print("[TKJRoamer] Door closed?", door_closed)
		
		if not door_closed:
			print("[TKJRoamer] Door is OPEN - JUMPSCARE!")
			waiting_at_door = false  # Stop waiting
			trigger_jumpscare()
		else:
			print("[TKJRoamer] Door is CLOSED - starting retreat!")
			waiting_at_door = false  # Stop waiting
			# Door is closed! Start retreating
			_start_retreat()
	else:
		print("[TKJRoamer] No office manager or is_door_closed method!")
		waiting_at_door = false
		# No office manager, assume door is open
		trigger_jumpscare()

func _start_retreat() -> void:
	# Unregister from door
	if office_manager and office_manager.door_manager:
		office_manager.door_manager.unregister_animatronic_at_door("TKJRoamer", "right")
		print("[TKJRoamer] Unregistered from right door")
	
	# Determine how far back to retreat (1-3 steps)
	retreat_steps = randi_range(2, 4)
	is_retreating = true
	waiting_at_door = false
	leave_door()  # Leave door area
	door_wait_timer = 0.0
	print("[TKJRoamer] Starting retreat, will go back", retreat_steps, "steps")

func _leave_door_area() -> void:
	# This function is now handled by _start_retreat() when door is closed
	# The retreat system manages backing away from the door
	pass

func trigger_jumpscare() -> void:
	# Unregister from door before jumpscare
	if office_manager and office_manager.door_manager:
		office_manager.door_manager.unregister_animatronic_at_door("TKJRoamer", "right")
	
	# Call parent class jumpscare
	super.trigger_jumpscare()

func _show_at_door_sprite(visible: bool) -> void:
	# TODO: When you have office sprites ready, implement this
	# This function will show/hide the anomaly sprite at the right door
	# 
	# Example implementation:
	# if office_manager and office_manager.has_node("RightDoorSprite"):
	#     var sprite = office_manager.get_node("RightDoorSprite")
	#     sprite.visible = visible
	#     if visible:
	#         sprite.texture = preload("res://path/to/tkj_at_door.png")
	#
	# For now, just print to console
	if visible:
		print("[TKJRoamer] 🚪 SPRITE VISIBLE AT RIGHT DOOR (add your sprite here)")
	else:
		print("[TKJRoamer] 🚪 SPRITE HIDDEN AT RIGHT DOOR")
