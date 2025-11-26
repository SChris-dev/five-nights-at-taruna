extends Button

# Fix button for RPL Room (Camera Disruptor) and TKJ Room (Power Drainer)
# Place this on buttons that appear on specific camera feeds

@export_enum("RPL_Disruptor", "TKJ_Drainer") var button_type: int = 0
@export var ai_manager: Node  # Reference to CharacterAI node

# Texture settings (128x64 recommended)
@export var button_texture: Texture2D  # Normal button texture
@export var button_texture_hover: Texture2D  # Optional hover texture
@export var button_texture_pressed: Texture2D  # Optional pressed texture

# Randomization bounds (relative to button's initial position)
@export var randomize_position: bool = true
@export var random_x_range: Vector2 = Vector2(100, 700)  # Min/Max X position
@export var random_y_range: Vector2 = Vector2(100, 500)  # Min/Max Y position

var was_visible: bool = false

# Only show button when viewing the correct camera and issue is active
func _ready() -> void:
	# Set button size for 128x64 texture
	custom_minimum_size = Vector2(128, 64)
	
	# Apply textures if provided
	if button_texture:
		# Convert Button to TextureButton-like appearance
		var normal_style = _create_texture_stylebox(button_texture)
		add_theme_stylebox_override("normal", normal_style)
		
		if button_texture_hover:
			add_theme_stylebox_override("hover", _create_texture_stylebox(button_texture_hover))
		else:
			# Use normal texture for hover if not provided
			add_theme_stylebox_override("hover", normal_style)
		
		if button_texture_pressed:
			add_theme_stylebox_override("pressed", _create_texture_stylebox(button_texture_pressed))
		else:
			# Use normal texture for pressed if not provided
			add_theme_stylebox_override("pressed", normal_style)
		
		# Hide text when using texture
		text = ""
	
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

func _create_texture_stylebox(texture: Texture2D) -> StyleBoxTexture:
	"""Create a StyleBoxTexture from a Texture2D"""
	var stylebox = StyleBoxTexture.new()
	stylebox.texture = texture
	# Ensure texture fills the button
	stylebox.texture_margin_left = 0
	stylebox.texture_margin_top = 0
	stylebox.texture_margin_right = 0
	stylebox.texture_margin_bottom = 0
	return stylebox

func _randomize_position() -> void:
	if randomize_position:
		# Store the original button size
		var button_width = size.x
		var button_height = size.y
		
		# Randomize button position within defined bounds
		var new_x = randf_range(random_x_range.x, random_x_range.y)
		var new_y = randf_range(random_y_range.x, random_y_range.y)
		
		# Set position (only randomize position, keep size the same)
		position = Vector2(new_x, new_y)
		
		print("[FixButton] Randomized position to: (", new_x, ", ", new_y, ") with size: (", button_width, ", ", button_height, ")")

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
