extends AI

# TKR Sprinter - Foxy-like behavior, sprints to right door
# Path: TKR Hallway (8) -> Lower Hallway (12) -> Right Door
# Behavior: Only advances phases when camera is DOWN (like FNAF 1 Foxy)

#enum {
	#ROOM_08,  # TKR Hallway (starting position)
	#ROOM_12,  # Lower Hallway (visible when sprinting)
	#RIGHT_DOOR # At office door
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

enum Phase {
	DEACTIVATED,  # Phase 0: Idle, not moving
	STANDING,     # Phase 1: Starting to stand up
	READY,        # Phase 2: Ready to sprint
	SPRINTING     # Phase 3: Running down hallway
}

var current_phase: int = Phase.DEACTIVATED
var phase_timer: float = 0.0
var phase_check_interval: float = 5.0  # Check for phase change every 5 seconds
var is_camera_up: bool = false
var sprint_countdown: float = 0.0
var sprint_timeout: float = 3.0  # Player has 3 seconds to close door
var player_aware_of_sprint: bool = false  # Player checked cam 12 or saw disappearance
var attack_cooldown: float = 0.0
var cooldown_duration: float = 25.0

func _ready() -> void:
	current_room = ROOM_08
	door_side = "right"
	# Set initial state in camera - DEACTIVATED phase
	camera.rooms[ROOM_08][character] = State.PRESENT
	camera.update_feeds([ROOM_08])

func move_check() -> void:
	# This is called by TKRSprinterTimer every 5.5 seconds
	if attack_cooldown > 0:
		attack_cooldown -= 5.5  # Decrease by timer interval
		return

	# Handle sprint countdown (after player becomes aware)
	if current_phase == Phase.SPRINTING and player_aware_of_sprint:
		sprint_countdown -= 5.5
		if sprint_countdown <= 0:
			_reach_door()
		return

	# Phase timer only advances when camera is DOWN (like Foxy)
	if not is_camera_up and current_phase != Phase.SPRINTING:
		phase_timer += 5.5  # Increase by timer interval

		# Check for phase advancement
		if phase_timer >= phase_check_interval:
			phase_timer = 0.0
			_attempt_phase_change()

func _attempt_phase_change() -> void:
	# Use standard AI level check (same as other characters)
	# AI 0 = 0% chance, AI 1 = 5%, AI 10 = 50%, AI 20 = 100%
	if not has_passed_check():
		print("[TKRSprinter] Failed AI level check (level:", ai_level, ") - no phase change")
		return
	
	_advance_phase()
	print("[TKRSprinter] Phase changed! Current phase:", current_phase)

func _advance_phase() -> void:
	match current_phase:
		Phase.DEACTIVATED:
			current_phase = Phase.STANDING
			# Update camera to show standing sprite (frame 1)
			camera.rooms[ROOM_08][character] = State.ALT_1
			camera.update_feeds([ROOM_08])

		Phase.STANDING:
			current_phase = Phase.READY
			# Update camera to show ready sprite (frame 2)
			camera.rooms[ROOM_08][character] = State.ALT_2
			camera.update_feeds([ROOM_08])

		Phase.READY:
			_start_sprint()

func _start_sprint() -> void:
	print("[TKRSprinter] ⚡ STARTING SPRINT! Player has 3 seconds after checking cam 12!")
	current_phase = Phase.SPRINTING
	player_aware_of_sprint = false

	# Disappear from cam 8
	camera.rooms[ROOM_08][character] = State.ABSENT
	camera.update_feeds([ROOM_08])

	# Show in cam 12 (running)
	current_room = ROOM_12
	camera.rooms[ROOM_12][character] = State.PRESENT
	camera.update_feeds([ROOM_12])

	# TODO: Play sprint sound effect
	print("[TKRSprinter] 🏃 Running through hallway! Check cam 12 to see!")

func _reach_door() -> void:
	print("[TKRSprinter] Reached door, checking if closed...")

	# Check if door is closed
	if office_manager and office_manager.has_method("is_door_closed"):
		var door_closed = office_manager.is_door_closed("right")
		print("[TKRSprinter] Right door closed?", door_closed)

		if door_closed:
			_blocked_by_door()
		else:
			print("[TKRSprinter] Door is OPEN - JUMPSCARE!")
			trigger_jumpscare()
	else:
		print("[TKRSprinter] No office manager, assuming door open - JUMPSCARE!")
		trigger_jumpscare()

func _blocked_by_door() -> void:
	print("[TKRSprinter] 🚪 Blocked by door! Draining power and resetting...")

	# Clear from hallway and reset animation
	camera.rooms[ROOM_12][character] = State.ABSENT
	camera.update_feeds([ROOM_12])

	# TODO: Play door bang sound

	# Drain extra power (more than normal door usage)
	# Try to find PowerManager in the scene tree
	var power_manager = get_node_or_null("../PowerManager")
	if not power_manager:
		# Try alternative path (might be sibling to parent)
		power_manager = get_node_or_null("../../PowerManager")
	
	if power_manager and power_manager.has_method("drain_power"):
		power_manager.drain_power(5.0)  # Drain 5% power as penalty
		print("[TKRSprinter] Drained 5% power!")
	else:
		print("[TKRSprinter] Warning: Could not find PowerManager to drain power")

	_reset_to_start()

func _reset_to_start() -> void:
	print("[TKRSprinter] Resetting to TKR Hallway...")
	current_phase = Phase.DEACTIVATED
	current_room = ROOM_08
	phase_timer = 0.0
	sprint_countdown = 0.0
	player_aware_of_sprint = false
	attack_cooldown = cooldown_duration

	# Reset camera state and clear animation
	camera.rooms[ROOM_08][character] = State.PRESENT
	camera.rooms[ROOM_12][character] = State.ABSENT
	camera.update_feeds([ROOM_08, ROOM_12])

func trigger_jumpscare() -> void:
	print("[TKRSprinter] 💀 JUMPSCARE! Player failed to close door in time!")

	# Clear from cameras
	camera.rooms[ROOM_12][character] = State.ABSENT
	camera.update_feeds([ROOM_12])

	# Call parent class jumpscare
	super.trigger_jumpscare()

func on_camera_viewed(cam_room: int) -> void:
	# Player is checking cam 8 (TKR's starting room)
	if cam_room == ROOM_08:
		# If sprinting and player sees empty room, start countdown
		if current_phase == Phase.SPRINTING and not player_aware_of_sprint:
			player_aware_of_sprint = true
			sprint_countdown = sprint_timeout
			print("[TKRSprinter] ⚠️ Player noticed I'm gone from cam 8! Countdown started:", sprint_timeout, "seconds")

	# Player is checking cam 12 (hallway where TKR runs)
	elif cam_room == ROOM_12:
		# If sprinting and player sees me running, start countdown
		if current_phase == Phase.SPRINTING and not player_aware_of_sprint:
			player_aware_of_sprint = true
			sprint_countdown = sprint_timeout
			print("[TKRSprinter] ⚠️ Player saw me running in cam 12! Countdown started:", sprint_timeout, "seconds")

func on_camera_opened() -> void:
	is_camera_up = true
	print("[TKRSprinter] Camera opened, phase timer paused")

func on_camera_closed() -> void:
	is_camera_up = false
	print("[TKRSprinter] Camera closed, phase timer resumed")

func move_options() -> void:
	# This character doesn't use the standard move_options system
	# All movement is handled by phase advancement and move_check()
	pass
