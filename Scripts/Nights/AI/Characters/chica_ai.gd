extends AI

# Chica - Right side character
# Movement path: Show Stage -> Dining Area -> Restrooms -> Kitchen -> East Hall -> East Hall Corner -> Right Door

# TODO: Update these room indices to match your camera setup
enum {
	SHOW_STAGE,      # Starting position
	DINING_AREA,     # Moves here first
	RESTROOMS,       # Right side path
	KITCHEN,         # Camera is audio-only!
	EAST_HALL,       # Approaching office
	EAST_HALL_CORNER,# Right before office
	RIGHT_DOOR       # At office door (attack position)
}

var door_wait_timer: float = 0.0
var max_door_wait: float = 30.0  # Seconds before leaving door
var in_kitchen: bool = false

func _ready() -> void:
	current_room = SHOW_STAGE
	door_side = "right"

func _process(delta: float) -> void:
	# Handle door waiting logic
	if is_at_door:
		door_wait_timer += delta
		if door_wait_timer >= max_door_wait:
			_leave_door_area()

func move_options() -> void:
	match step:
		0:  # At Show Stage
			move_to(DINING_AREA)
		
		1:  # At Dining Area
			move_to(RESTROOMS)
		
		2:  # At Restrooms
			move_to(KITCHEN)
			in_kitchen = true
			# TODO: Play kitchen audio sounds when Chica is here
		
		3:  # At Kitchen
			move_to(EAST_HALL)
			in_kitchen = false
		
		4:  # At East Hall
			move_to(EAST_HALL_CORNER)
		
		5:  # At East Hall Corner
			move_to(RIGHT_DOOR)
			_reach_door()
		
		_:
			# Chica doesn't return to start position
			pass

func _reach_door() -> void:
	# Chica has reached the right door
	is_at_door = true
	door_wait_timer = 0.0
	# Start waiting to attack
	_check_door_attack()

func _check_door_attack() -> void:
	# Called when Chica tries to enter
	if office_manager and office_manager.has_method("is_door_closed"):
		if not office_manager.is_door_closed("right"):
			# Door is open, attack!
			trigger_jumpscare()
	# If door is closed, wait and try again periodically

func _leave_door_area() -> void:
	# Chica leaves door after timeout
	leave_door()
	door_wait_timer = 0.0
	# Move back into halls
	if has_passed_check():
		move_to(EAST_HALL, State.PRESENT, -2)
