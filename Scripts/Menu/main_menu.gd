extends Control

# TODO: Connect these to actual buttons in the scene
# Buttons should call these functions

# Background rotation
var background_images: Array[String] = [
	"res://Graphics/Menu/main_menu/bg_1.jpg",
	"res://Graphics/Menu/main_menu/bg_2.png",
	"res://Graphics/Menu/main_menu/bg_3.png",
	#"res://Graphics/Menu/main_menu/bg_4.jpg",
	#"res://Graphics/Menu/main_menu/menu_bg.png"
]
var current_bg_index: int = 0
var next_bg_index: int = 1
var bg_timer: Timer
var current_bg_node: TextureRect
var next_bg_node: TextureRect
var is_transitioning: bool = false
var current_move_direction: int = 1  # 1 for right, -1 for left
var move_tween: Tween

func _ready() -> void:
	# Update button states based on progress
	_update_continue_button()
	
	_setup_background_rotation()

func _setup_background_rotation() -> void:
	# Create background nodes
	_setup_background_nodes()

	# Setup continuous carousel movement
	_setup_carousel_movement()

	# Create and configure timer for background rotation
	bg_timer = Timer.new()
	bg_timer.wait_time = 5.0  # Change background every 5 seconds
	bg_timer.autostart = true
	bg_timer.timeout.connect(_on_bg_timer_timeout)
	add_child(bg_timer)

	# Set initial background
	_update_background()

func _setup_carousel_movement() -> void:
	# Start continuous carousel movement synchronized with fade timer
	_start_carousel_movement()

func _start_carousel_movement() -> void:
	if current_bg_node:  # Removed is_transitioning check since we control when to start
		# Calculate movement distance for smooth carousel effect
		# Move 120px over 5 seconds (24px per second)
		var move_distance = 100.0 * current_move_direction

		# Stop any existing tween
		if move_tween:
			move_tween.kill()

		# Create new smooth movement tween
		move_tween = create_tween()
		move_tween.tween_property(current_bg_node, "position:x", current_bg_node.position.x + move_distance, 5.0).set_trans(Tween.TRANS_LINEAR).set_ease(Tween.EASE_IN_OUT)

func _setup_background_nodes() -> void:
	# Remove existing background node
	if has_node("Background"):
		$Background.queue_free()

	# Create current background
	current_bg_node = TextureRect.new()
	current_bg_node.name = "CurrentBackground"
	# Note: Using integer constants that correspond to Godot 4 enum values
	# LAYOUT_MODE_ANCHORS = 1, PRESET_FULL_RECT = 15, GROW_DIRECTION_BOTH = 2, STRETCH_KEEP_ASPECT_COVERED = 6
	current_bg_node.layout_mode = 1
	current_bg_node.anchors_preset = 15
	current_bg_node.grow_horizontal = 2
	current_bg_node.grow_vertical = 2
	current_bg_node.stretch_mode = 6
	current_bg_node.modulate.a = 0.0  # Start transparent
	add_child(current_bg_node)
	# Move to front of the node tree (index 0) so it appears behind other elements
	move_child(current_bg_node, 0)

	# Create next background (for smooth transitions)
	next_bg_node = TextureRect.new()
	next_bg_node.name = "NextBackground"
	# Note: Using integer constants that correspond to Godot 4 enum values
	# LAYOUT_MODE_ANCHORS = 1, PRESET_FULL_RECT = 15, GROW_DIRECTION_BOTH = 2, STRETCH_KEEP_ASPECT_COVERED = 6
	next_bg_node.layout_mode = 1
	next_bg_node.anchors_preset = 1
	next_bg_node.grow_horizontal = 2
	next_bg_node.grow_vertical = 2
	next_bg_node.stretch_mode = 0
	next_bg_node.modulate.a = 0.0  # Start transparent
	add_child(next_bg_node)
	# Move to front of the node tree (index 1) so it appears behind other elements
	move_child(next_bg_node, 1)

func _on_bg_timer_timeout() -> void:
	if not is_transitioning:
		# Cycle to next background
		current_bg_index = (current_bg_index + 1) % background_images.size()
		next_bg_index = (current_bg_index + 1) % background_images.size()
		_start_fade_transition()

func _start_fade_transition() -> void:
	is_transitioning = true

	# Stop any current movement and reset position
	_reset_background_position()

	# Load next background texture (but don't show it yet)
	next_bg_node.texture = load(background_images[current_bg_index])
	next_bg_node.modulate.a = 0.0

	# Fade out current background with direction change during fade
	var tween = create_tween()
	tween.tween_property(current_bg_node, "modulate:a", 0.0, 0.5)
	tween.tween_callback(_on_fade_out_complete)

func _on_fade_out_complete() -> void:
	# Reverse direction during fade-out completion
	current_move_direction *= -1

	# Switch textures and reset position
	current_bg_node.texture = load(background_images[current_bg_index])
	current_bg_node.position.x = -1600  # Reset to center
	current_bg_node.modulate.a = 0.0

	# Start movement immediately as fade-in begins
	_start_carousel_movement()

	# Fade in current background
	var tween = create_tween()
	tween.tween_property(current_bg_node, "modulate:a", 0.5, 0.5)
	tween.tween_callback(_on_fade_in_complete)

func _on_fade_in_complete() -> void:
	is_transitioning = false

func _reset_background_position() -> void:
	# Stop any running tweens and reset position
	if current_bg_node:
		current_bg_node.position.x = 0

func _update_background() -> void:
	if current_bg_node:
		current_bg_node.texture = load(background_images[current_bg_index])
		current_bg_node.modulate.a = 0.5
		current_bg_node.position.x = 1600  # Start at center position

func _update_continue_button() -> void:
	# Disable continue button if no progress
	if has_node("ContinueButton"):
		$ContinueButton.disabled = GlobalData.nights_completed == 0

func _on_new_game_pressed() -> void:
	GlobalData.start_night(1, false)
	get_tree().change_scene_to_file("res://Scenes/Menu/game_intro.tscn")

func _on_continue_pressed() -> void:
	# Continue from last completed night + 1
	var next_night = min(GlobalData.nights_completed + 1, 6)
	GlobalData.start_night(next_night, false)
	get_tree().change_scene_to_file("res://Scenes/Menu/night_intro.tscn")

func _on_custom_night_pressed() -> void:
	# Only available after beating Night 6
	if GlobalData.nights_completed >= 6:
		get_tree().change_scene_to_file("res://Scenes/Menu/custom_night.tscn")

func _on_night_select_pressed() -> void:
	get_tree().change_scene_to_file("res://Scenes/Menu/night_select.tscn")

func _on_quit_pressed() -> void:
	get_tree().quit()
