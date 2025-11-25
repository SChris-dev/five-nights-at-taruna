extends Button

# Fix button for RPL Room (Camera Disruptor) and TKJ Room (Power Drainer)
# Place this on buttons that appear on specific camera feeds

@export_enum("RPL_Disruptor", "TKJ_Drainer") var button_type: int = 0
@export var ai_manager: Node  # Reference to CharacterAI node

# Randomization bounds (relative to button's initial position)
@export var randomize_position: bool = true
@export var random_x_range: Vector2 = Vector2(100, 700)  # Min/Max X position
@export var random_y_range: Vector2 = Vector2(100, 500)  # Min/Max Y position

var was_visible: bool = false

# Only show button when viewing the correct camera and issue is active
func _ready() -> void:
	visible = false
	was_visible = false

func _process(_delta: float) -> void:
	_update_visibility()

func _update_visibility() -> void:
	var should_be_visible: bool = false
	
	# Check if button should be visible
	match button_type:
		0:  # RPL Disruptor
			if ai_manager and ai_manager.has_node("RPLDisruptor"):
				var disruptor = ai_manager.get_node("RPLDisruptor")
				if disruptor.has_method("get_disruption_status"):
					should_be_visible = disruptor.get_disruption_status()
		
		1:  # TKJ Drainer
			if ai_manager and ai_manager.has_node("TKJDrainer"):
				var drainer = ai_manager.get_node("TKJDrainer")
				if drainer.has_method("get_drain_status"):
					should_be_visible = drainer.get_drain_status()
	
	# If becoming visible (was hidden, now showing), randomize position
	if should_be_visible and not was_visible:
		_randomize_position()
	
	was_visible = visible
	visible = should_be_visible

func _randomize_position() -> void:
	if randomize_position:
		# Randomize button position within defined bounds
		var new_x = randf_range(random_x_range.x, random_x_range.y)
		var new_y = randf_range(random_y_range.x, random_y_range.y)
		offset_left = new_x
		offset_top = new_y
		# Update right and bottom to maintain button size
		offset_right = offset_left + size.x
		offset_bottom = offset_top + size.y
		print("[FixButton] Randomized position to: (", new_x, ", ", new_y, ")")

func _on_pressed() -> void:
	# Fix the issue when button is clicked
	match button_type:
		0:  # RPL Disruptor
			if ai_manager and ai_manager.has_node("RPLDisruptor"):
				var disruptor = ai_manager.get_node("RPLDisruptor")
				if disruptor.has_method("fix_camera"):
					disruptor.fix_camera()
					print("Camera fixed!")
		
		1:  # TKJ Drainer
			if ai_manager and ai_manager.has_node("TKJDrainer"):
				var drainer = ai_manager.get_node("TKJDrainer")
				if drainer.has_method("fix_power_drain"):
					drainer.fix_power_drain()
					print("Power drain stopped!")
