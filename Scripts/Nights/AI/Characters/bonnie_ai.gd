extends AI

# Bonnie - Left side character
# Movement path: Show Stage -> Backstage -> Dining Area -> Supply Closet -> West Hall -> West Hall Corner -> Left Door

# TODO: Update these room indices to match your camera setup
enum {
	SHOW_STAGE,      # Starting position
	DINING_AREA,     # Moves here first
	BACKSTAGE,       # Can go here from stage
	SUPPLY_CLOSET,   # Left path
	WEST_HALL,       # Approaching office
	WEST_HALL_CORNER,# Right before office
	LEFT_DOOR        # At office door (attack position)
}

var door_wait_timer: float = 0.0
var max_door_wait: float = 30.0  # Seconds before leaving door

func _ready() -> void:
	current_room = SHOW_STAGE
	door_side = "left"

func _process(delta: float) -> void:
	# Handle door waiting logic
	if is_at_door:
		door_wait_timer += delta
		if door_wait_timer >= max_door_wait:
			_leave_door_area()

func move_options() -> void:
	match step:
		0:  # At Show Stage
			if randf() < 0.5:
				move_to(DINING_AREA)
			else:
				move_to(BACKSTAGE)
		
		1:  # First move complete
			if current_room == BACKSTAGE:
				move_to(DINING_AREA)
			elif current_room == DINING_AREA:
				move_to(SUPPLY_CLOSET)
		
		2:  # At Supply Closet
			move_to(WEST_HALL)
		
		3:  # At West Hall
			move_to(WEST_HALL_CORNER)
		
		4:  # At West Hall Corner
			move_to(LEFT_DOOR)
			_reach_door()
		
		_:
			# Bonnie doesn't return to start position
			pass

func _reach_door() -> void:
	# Bonnie has reached the left door
	is_at_door = true
	door_wait_timer = 0.0
	# Start waiting to attack
	_check_door_attack()

func _check_door_attack() -> void:
	# Called when Bonnie tries to enter
	if office_manager and office_manager.has_method("is_door_closed"):
		if not office_manager.is_door_closed("left"):
			# Door is open, attack!
			trigger_jumpscare()
	# If door is closed, wait and try again periodically

func _leave_door_area() -> void:
	# Bonnie leaves door after timeout
	leave_door()
	door_wait_timer = 0.0
	# Move back into halls
	if has_passed_check():
		move_to(WEST_HALL, State.PRESENT, -2)
