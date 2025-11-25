extends AI

# Big Robot - Freddy-like behavior, slow but relentless
# Path: TPM/LAS Hallway (9) -> Yard (4) -> Upper Hallway (2) -> Outer Auditorium (3) -> Stairs (5) -> South Hallway (10) -> Left Door
# Behavior: Never retreats, only moves when camera is DOWN (like FNAF 1 Freddy)

enum {
	ROOM_01,  # INST Room - Roaming anomaly starts here
	ROOM_02,  # Upper Hallway
	ROOM_03,  # Outer Auditorium (static)
	ROOM_04,  # School Yard (static)
	ROOM_05,  # The Stairs - INST can pass through here
	ROOM_06,  # RPL Room - Camera disruptor (static)
	ROOM_07,  # TKJ Room - Power drainer + Roaming anomaly
	ROOM_08,  # TKR Hallway - Sprinter (Foxy-like)
	ROOM_09,  # TPM/LAS Hallway - Big robot (starting position)
	ROOM_10,  # South Hallway (near left door)
	ROOM_11,  # North Hallway (near right door)
	ROOM_12,  # Lower Hallway (sprinter visible)
	ROOM_13,   # OSIS Room (audio only)
	LEFT_DOOR # At office (virtual room for attack)
}

var is_being_viewed: bool = false  # True when player is viewing Big Robot's current room
var move_timer: float = 0.0
var attack_ready: bool = false  # True when at ROOM_10, next move = attack

# Audio player for movement sounds (Freddy's laugh)
@onready var movement_sound: AudioStreamPlayer = null  # TODO: Assign in scene

func _ready() -> void:
	current_room = ROOM_09
	door_side = "left"
	# Set initial position in camera
	camera.rooms[ROOM_09][character] = State.PRESENT
	camera.update_feeds([ROOM_09])
	print("[BigRobot] Initialized at TPM/LAS Hallway (ROOM_09)")

func move_check() -> void:
	# This is called by BigRobotTimer every X seconds (longer than other anomalies)
	# Timer only advances when player is NOT viewing Big Robot's current room (like Freddy)
	
	if is_being_viewed:
		print("[BigRobot] Player is viewing my room (", current_room, ") - movement PAUSED!")
		return
	
	print("[BigRobot] Not being viewed - checking for movement...")
	
	# Check AI level before moving
	if not has_passed_check():
		print("[BigRobot] Failed AI level check (level:", ai_level, ") - no movement this time")
		return
	
	print("[BigRobot] Passed AI level check! Moving...")
	
	# If at last room before office, attack on next move
	if attack_ready:
		print("[BigRobot] ⚠️ Attack ready! Moving to door...")
		_reach_door()
		return
	
	# Normal movement through path
	move_options()

func move_options() -> void:
	# Big Robot NEVER retreats - always moves forward
	match step:
		0:  # At TPM/LAS Hallway (ROOM_09)
			print("[BigRobot] Moving from TPM/LAS Hallway to Yard...")
			_play_movement_sound()
			move_to(ROOM_04)  # Move to Yard
		
		1:  # At Yard (ROOM_04)
			print("[BigRobot] Moving from Yard to Upper Hallway...")
			_play_movement_sound()
			move_to(ROOM_02)  # Move to Upper Hallway
			
		2:  # At Upper Hallway (ROOM_02)
			print("[BigRobot] Moving from Upper Hallway to Outer Auditorium...")
			_play_movement_sound()
			move_to(ROOM_03)  # Move to Outer Auditorium
		
		3:  # At Outer Auditorium (ROOM_03)
			print("[BigRobot] Moving from Outer Auditorium to Stairs...")
			_play_movement_sound()
			move_to(ROOM_05)  # Move to The Stairs
		
		4:  # At The Stairs (ROOM_05)
			print("[BigRobot] Moving from Stairs to South Hallway...")
			_play_movement_sound()
			move_to(ROOM_10)  # Move to South Hallway (last room before door)
		
		5:  # At South Hallway (ROOM_10) - CRITICAL POSITION
			print("[BigRobot] ⚠️⚠️ AT SOUTH HALLWAY - NEXT MOVE WILL ATTACK! ⚠️⚠️")
			attack_ready = true
			# Stay here until next move_check(), then attack
		
		6:  # This should only happen during attack
			print("[BigRobot] ERROR: Should not reach step 6 in normal flow")
		
		_:
			pass

func _reach_door() -> void:
	print("[BigRobot] 🚪 Reached left door - checking if closed...")
	
	# Clear from South Hallway camera
	if current_room == ROOM_10:
		camera.rooms[ROOM_10][character] = State.ABSENT
		camera.update_feeds([ROOM_10])
		print("[BigRobot] Cleared from South Hallway (ROOM_10) camera")
	
	# Big Robot does NOT appear at door light (unlike INST/TKJ)
	# It directly checks if door is closed
	
	is_at_door = true
	step = 6  # Mark as attacking
	current_room = LEFT_DOOR  # Track that we're at the door (virtual room)
	
	_check_door_attack()

func _check_door_attack() -> void:
	print("[BigRobot] Checking door status...")
	
	if office_manager and office_manager.has_method("is_door_closed"):
		var door_closed = office_manager.is_door_closed("left")
		print("[BigRobot] Left door closed?", door_closed)
		
		if door_closed:
			print("[BigRobot] ✅ Door is CLOSED - player survives!")
			print("[BigRobot] Big Robot cannot get in, but stays menacing...")
			# Big Robot does NOT retreat - it stays at the door
			# Player must keep door closed while Big Robot is there
			# TODO: Add continuous door drain or other penalty
			_blocked_by_door()
		else:
			print("[BigRobot] ❌ Door is OPEN - JUMPSCARE!")
			trigger_jumpscare()
	else:
		print("[BigRobot] No office manager - JUMPSCARE!")
		trigger_jumpscare()

func _blocked_by_door() -> void:
	print("[BigRobot] 🚪 Blocked by door!")
	
	# TODO: Play door bang sound
	
	# Big Robot stays at door for a while (doesn't retreat like others)
	# This creates pressure on the player
	# For now, we'll make it retreat after a delay to avoid softlock
	# In full implementation, you might want it to stay until conditions change
	
	# Optionally: Drain power continuously while at door
	# if office_manager and office_manager.has_method("drain_power"):
	#     office_manager.drain_power(10)
	
	# Reset to start after being blocked
	# In FNAF 1, Freddy retreats to starting position
	_reset_to_start()

func _reset_to_start() -> void:
	print("[BigRobot] Resetting to TPM/LAS Hallway (ROOM_09)...")
	
	# Clear from all rooms
	camera.rooms[ROOM_10][character] = State.ABSENT
	
	# Reset to starting position
	current_room = ROOM_09
	step = 0
	attack_ready = false
	is_at_door = false
	
	# Set back at starting room
	camera.rooms[ROOM_09][character] = State.PRESENT
	camera.update_feeds([ROOM_09, ROOM_10])

func trigger_jumpscare() -> void:
	print("[BigRobot] 💀 JUMPSCARE! Big Robot attacks!")
	
	# Clear from cameras
	camera.rooms[ROOM_10][character] = State.ABSENT
	camera.update_feeds([ROOM_10])
	
	# Call parent class jumpscare
	super.trigger_jumpscare()

func on_camera_viewed(cam_room: int) -> void:
	# Called when player views a specific camera
	if cam_room == current_room:
		if not is_being_viewed:  # State changed
			print("[BigRobot] ⚠️ Player is viewing my camera (", cam_room, ") - FROZEN!")
		is_being_viewed = true
	else:
		if is_being_viewed:  # State changed
			print("[BigRobot] Player viewing different camera (", cam_room, ") - can move again")
		is_being_viewed = false

func on_camera_opened() -> void:
	# Camera opened but not necessarily viewing Big Robot's room
	# is_being_viewed will be set by on_camera_viewed()
	pass

func on_camera_closed() -> void:
	# When camera closes, Big Robot is no longer being viewed
	is_being_viewed = false
	print("[BigRobot] Camera closed - can move again")

func _play_movement_sound() -> void:
	# TODO: Play Freddy-like laugh sound when moving
	# Example implementation:
	# if movement_sound and movement_sound.stream:
	#     movement_sound.play()
	#     print("[BigRobot] 🔊 Playing movement sound (laugh)")
	
	print("[BigRobot] 🔊 [SOUND PLACEHOLDER] Playing laugh sound when moving")
	print("[BigRobot] TODO: Assign AudioStreamPlayer with laugh sound in scene")
