extends Node
class_name AI

enum State {ABSENT, PRESENT, ALT_1, ALT_2}

@export_enum("INSTAnomaly", "TKJRoamer", "TKRSprinter", "BigRobot", "RPLDisruptor", "TKJDrainer") var character: int
@export var camera: Camera
@export var office_manager: Node  # Reference to office for attack checks
@export var jumpscare_manager: Node  # Reference to jumpscare handler

var ai_level: int
var step: int
var current_room: int
var is_at_door: bool = false  # Track if at office door
var door_side: String = ""  # "left" or "right"

func has_passed_check() -> bool:
	# Handles whether character moves or not (depending on char_level)
	return ai_level >= randi_range(1,20)

func _is_room_empty(room: int) -> bool:
	return camera.rooms[room].max() == State.ABSENT

func move_check() -> void:
	if has_passed_check():
		move_options()

func move_options() -> void:
	pass

func move_to(target_room: int, new_state: int = State.PRESENT, move_step: int = 1) -> void:
	# And character state changes in a room (handled by new_state)
	print("[AI] Moving from room", current_room, "to room", target_room, "with state", new_state)
	print("[AI] Before move - rooms[", current_room, "][", character, "] =", camera.rooms[current_room][character])
	print("[AI] Before move - rooms[", target_room, "][", character, "] =", camera.rooms[target_room][character])
	
	step += move_step
	
	camera.rooms[current_room][character] = State.ABSENT
	camera.rooms[target_room][character] = new_state
	
	print("[AI] After move - rooms[", current_room, "][", character, "] =", camera.rooms[current_room][character])
	print("[AI] After move - rooms[", target_room, "][", character, "] =", camera.rooms[target_room][character])
	print("[AI] Updating camera feeds for rooms", [current_room, target_room])
	camera.update_feeds([current_room, target_room])
	current_room = target_room

func attempt_door_attack(side: String) -> void:
	# Try to attack through a door
	is_at_door = true
	door_side = side
	
	if office_manager and office_manager.has_method("is_door_closed"):
		var door_closed = office_manager.is_door_closed(side)
		if not door_closed:
			# Door is open, trigger jumpscare
			trigger_jumpscare()
	else:
		# No office manager, assume door is open
		trigger_jumpscare()

func trigger_jumpscare() -> void:
	# Trigger jumpscare through manager
	if jumpscare_manager and jumpscare_manager.has_method("trigger_jumpscare"):
		var character_name = _get_character_name()
		jumpscare_manager.trigger_jumpscare(character_name)

func _get_character_name() -> String:
	match character:
		0: return "INSTAnomaly"
		1: return "TKJRoamer"
		2: return "TKRSprinter"
		3: return "BigRobot"
		4: return "RPLDisruptor"
		5: return "TKJDrainer"
		_: return "Unknown"

func leave_door() -> void:
	# Character leaves door area
	is_at_door = false
	door_side = ""

func on_camera_opened() -> void:
	# Called when player opens camera system
	# Override in child classes if needed
	pass

func on_camera_closed() -> void:
	# Called when player closes camera system
	# Override in child classes if needed
	pass

func on_camera_viewed(_cam_room: int) -> void:
	# Called when player views a specific camera
	# Override in child classes if needed
	pass
