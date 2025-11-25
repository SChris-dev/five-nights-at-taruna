extends AI

# INST Room Anomaly - Roams to left door
# Path: INST Room (1) -> Upper Hallway (2) -> Outer Auditorium (3) -> The Stairs (5) -> South Hallway (10) -> Left Door

#enum {
	#ROOM_01,  # INST Room (starting position)
	#ROOM_02,  # Upper Hallway
	#ROOM_03,  # Outer Auditorium
	#ROOM_05,  # The Stairs
	#ROOM_10,  # South Hallway (near left door)
	#LEFT_DOOR # At office (virtual room for attack)
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
	LEFT_DOOR
}

var door_wait_timer: float = 0.0
var max_door_wait: float = 30.0  # Base wait time
var is_retreating: bool = false
var retreat_steps: int = 0
var waiting_at_door: bool = false
var door_wait_grace_period: float = 0.0  # Time to wait before attacking

func _ready() -> void:
	current_room = ROOM_01
	door_side = "left"
	# Calculate grace period based on AI level (lower AI = longer wait)
	# AI 20 = 3 seconds, AI 10 = 6 seconds, AI 5 = 9 seconds, AI 0 = 12 seconds
	door_wait_grace_period = 12.0 - (ai_level * 0.45)

func _process(delta: float) -> void:
	if waiting_at_door:
		door_wait_timer += delta

		# Check if player turned on light
		if office_manager and office_manager.door_manager:
			var door_manager = office_manager.door_manager
			if door_manager.left_light_on:
				print("[INSTAnomaly] ⚠️ VISIBLE IN LEFT LIGHT! Player can see me!")
				_show_at_door_sprite(true)
			else:
				_show_at_door_sprite(false)

		# After grace period, check if door is closed
		if door_wait_timer >= door_wait_grace_period:
			_check_door_attack()

		# If waited too long at door, leave
		if door_wait_timer >= max_door_wait:
			print("[INSTAnomaly] Waited too long, leaving door")
			_start_retreat()

	elif is_at_door and not waiting_at_door:
		# This should only happen if anomaly is actually at door but not waiting
		print("[INSTAnomaly] WARNING: is_at_door=true but waiting_at_door=false")
		door_wait_timer += delta
		if door_wait_timer >= max_door_wait:
			print("[INSTAnomaly] Fixing stuck state, leaving door area")
			_leave_door_area()

func move_options() -> void:
	if is_retreating:
		_handle_retreat()
		return
	
	match step:
		0:  # At INST Room
			move_to(ROOM_02)  # Move to Upper Hallway
		
		1:  # At Upper Hallway
			move_to(ROOM_03)  # Move to Outer Auditorium
			
		2:  # At Outer Auditorium
			move_to(ROOM_05)  # Move to The Stairs
		
		3:  # At The Stairs
			move_to(ROOM_10)  # Move to South Hallway
		
		4:  # At South Hallway
			print("[INSTAnomaly] At South Hallway, proceeding to door")
			_reach_door()  # Attack from here
		
		5:  # At door (shouldn't happen in normal flow)
			print("[INSTAnomaly] ERROR: At door step but not at door!")
			pass
		
		_:
			pass

func _handle_retreat() -> void:
	if retreat_steps > 0:
		retreat_steps -= 1
		print("[INSTAnomaly] Retreating, steps left:", retreat_steps, " current step:", step, " current_room:", current_room)
		# Move back one step in the path
		match step:
			5:  # At door, move back to South Hallway
				step -= 1  # Decrement to step 4
				# current_room is LEFT_DOOR (virtual), so just set to ROOM_10
				current_room = ROOM_10
				camera.rooms[ROOM_10][character] = State.PRESENT
				camera.update_feeds([ROOM_10])
				print("[INSTAnomaly] Moved back to South Hallway from door")
			4:  # At South Hallway, move back to The Stairs
				step -= 1
				var old_room = current_room  # Store ROOM_10
				camera.rooms[old_room][character] = State.ABSENT  # Clear ROOM_10
				current_room = ROOM_05
				camera.rooms[ROOM_05][character] = State.PRESENT
				camera.update_feeds([old_room, ROOM_05])
				print("[INSTAnomaly] Moved back to The Stairs")
			3:  # At The Stairs, move back to Outer Auditorium
				step -= 1
				var old_room = current_room  # Store ROOM_05
				camera.rooms[old_room][character] = State.ABSENT  # Clear ROOM_05
				current_room = ROOM_03
				camera.rooms[ROOM_03][character] = State.PRESENT
				camera.update_feeds([old_room, ROOM_03])
				print("[INSTAnomaly] Moved back to Outer Auditorium")
			2:  # At Outer Auditorium, move back to Upper Hallway
				step -= 1
				var old_room = current_room  # Store ROOM_03
				camera.rooms[old_room][character] = State.ABSENT  # Clear ROOM_03
				current_room = ROOM_02
				camera.rooms[ROOM_02][character] = State.PRESENT
				camera.update_feeds([old_room, ROOM_02])
				print("[INSTAnomaly] Moved back to Upper Hallway")
			1:  # At Upper Hallway, move back to INST Room
				step -= 1
				var old_room = current_room  # Store ROOM_02
				camera.rooms[old_room][character] = State.ABSENT  # Clear ROOM_02
				current_room = ROOM_01
				camera.rooms[ROOM_01][character] = State.PRESENT
				camera.update_feeds([old_room, ROOM_01])
				print("[INSTAnomaly] Moved back to INST Room")
	else:
		# Finished retreating, continue forward
		is_retreating = false
		print("[INSTAnomaly] Finished retreating, resuming from step", step)
		# Continue with normal movement from current position
		# The next timer will trigger move_options() which will handle the current step

func _reach_door() -> void:
	print("[INSTAnomaly] Reached left door, waiting for player...")
	print("[INSTAnomaly] Current room before door:", current_room)
	
	# Clear from South Hallway camera (current_room should be ROOM_10)
	if current_room == ROOM_10:
		camera.rooms[ROOM_10][character] = State.ABSENT
		camera.update_feeds([ROOM_10])
		print("[INSTAnomaly] Cleared from South Hallway (ROOM_10) camera")
	else:
		print("[INSTAnomaly] WARNING: current_room is not ROOM_10! current_room=", current_room)
	
	is_at_door = true
	waiting_at_door = true
	door_wait_timer = 0.0
	step = 5  # Mark as at door
	current_room = LEFT_DOOR  # Track that we're at the door (virtual room)
	
	# Register with door manager so light reveals work
	if office_manager and office_manager.door_manager:
		office_manager.door_manager.register_animatronic_at_door("INSTAnomaly", "left")
		print("[INSTAnomaly] Registered at left door. Grace period:", door_wait_grace_period, "seconds")
	
	# TODO: Play breathing sound or door creak sound

func _check_door_attack() -> void:
	print("[INSTAnomaly] Grace period over, checking door...")
	print("[INSTAnomaly] office_manager exists:", office_manager != null)
	
	if office_manager:
		print("[INSTAnomaly] office_manager name:", office_manager.name)
		print("[INSTAnomaly] office_manager.door_manager exists:", office_manager.door_manager != null)
		if office_manager.door_manager:
			print("[INSTAnomaly] door_manager name:", office_manager.door_manager.name)
	
	if office_manager and office_manager.has_method("is_door_closed"):
		var door_closed = office_manager.is_door_closed("left")
		print("[INSTAnomaly] Door closed?", door_closed)
		
		if not door_closed:
			print("[INSTAnomaly] Door is OPEN - JUMPSCARE!")
			waiting_at_door = false  # Stop waiting
			trigger_jumpscare()
		else:
			print("[INSTAnomaly] Door is CLOSED - starting retreat!")
			waiting_at_door = false  # Stop waiting
			# Door is closed! Start retreating
			_start_retreat()
	else:
		print("[INSTAnomaly] No office manager or is_door_closed method!")
		waiting_at_door = false
		# No office manager, assume door is open
		trigger_jumpscare()

func _start_retreat() -> void:
	# Unregister from door
	if office_manager and office_manager.door_manager:
		office_manager.door_manager.unregister_animatronic_at_door("INSTAnomaly", "left")
		print("[INSTAnomaly] Unregistered from left door")
	
	# Determine how far back to retreat (1-3 steps)
	retreat_steps = randi_range(2, 4)
	is_retreating = true
	waiting_at_door = false
	leave_door()  # Leave door area
	door_wait_timer = 0.0
	print("[INSTAnomaly] Starting retreat, will go back", retreat_steps, "steps")

func _leave_door_area() -> void:
	# This function is now handled by _start_retreat() when door is closed
	# The retreat system manages backing away from the door
	pass

func trigger_jumpscare() -> void:
	# Unregister from door before jumpscare
	if office_manager and office_manager.door_manager:
		office_manager.door_manager.unregister_animatronic_at_door("INSTAnomaly", "left")
	
	# Call parent class jumpscare
	super.trigger_jumpscare()

func _show_at_door_sprite(visible: bool) -> void:
	# TODO: When you have office sprites ready, implement this
	# This function will show/hide the anomaly sprite at the left door
	# 
	# Example implementation:
	# if office_manager and office_manager.has_node("LeftDoorSprite"):
	#     var sprite = office_manager.get_node("LeftDoorSprite")
	#     sprite.visible = visible
	#     if visible:
	#         sprite.texture = preload("res://path/to/inst_at_door.png")
	#
	# For now, just print to console
	if visible:
		print("[INSTAnomaly] 🚪 SPRITE VISIBLE AT LEFT DOOR (add your sprite here)")
	else:
		print("[INSTAnomaly] 🚪 SPRITE HIDDEN AT LEFT DOOR")
