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

@onready var audio_manager = $AudioManager

# Title animation
var title_float_tween: Tween
@onready var title_logo = $TitleLogo if has_node("TitleLogo") else null

func _ready() -> void:
	# Update button states based on progress
	_update_continue_button()
	
	_setup_background_rotation()
	
	# Setup title floating animation
	_setup_title_float()
	
	# Setup button hover effects
	_setup_button_hover_effects()

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
	audio_manager.play_button_click_sound()
	GlobalData.start_night(1, false)
	get_tree().change_scene_to_file("res://Scenes/Menu/game_intro.tscn")

func _on_continue_pressed() -> void:
	# Continue from last completed night + 1
	audio_manager.play_button_click_sound()
	var next_night = min(GlobalData.nights_completed + 1, 6)
	GlobalData.start_night(next_night, false)
	get_tree().change_scene_to_file("res://Scenes/Menu/night_intro.tscn")

func _on_custom_night_pressed() -> void:
	# Only available after beating Night 6
	audio_manager.play_button_click_sound()
	if GlobalData.nights_completed >= 6:
		get_tree().change_scene_to_file("res://Scenes/Menu/custom_night.tscn")

func _on_night_select_pressed() -> void:
	audio_manager.play_button_click_sound()
	get_tree().change_scene_to_file("res://Scenes/Menu/night_select.tscn")

func _on_quit_pressed() -> void:
	get_tree().quit()

# ===== TITLE FLOATING ANIMATION =====

func _setup_title_float() -> void:
	"""Setup subtle floating animation for title"""
	if not title_logo:
		return
	
	# Store original position
	var original_y = title_logo.position.y
	
	# Create looping float animation
	title_float_tween = create_tween()
	title_float_tween.set_loops()  # Loop forever
	title_float_tween.set_ease(Tween.EASE_IN_OUT)
	title_float_tween.set_trans(Tween.TRANS_SINE)
	
	# Float up and down (20 pixels total movement)
	title_float_tween.tween_property(title_logo, "position:y", original_y - 10, 2.0)
	title_float_tween.tween_property(title_logo, "position:y", original_y + 10, 2.0)

# ===== BUTTON HOVER EFFECTS =====

func _setup_button_hover_effects() -> void:
	"""Setup hover effects for all buttons"""
	_connect_button_hover("NewGameButton")
	_connect_button_hover("ContinueButton")
	_connect_button_hover("SelectNightButton")
	_connect_button_hover("CustomNightButton")
	_connect_button_hover("SettingsButton")
	_connect_button_hover("ResetButton")

func _connect_button_hover(button_name: String) -> void:
	"""Connect hover signals to a button"""
	if has_node(button_name):
		var button = get_node(button_name)
		button.mouse_entered.connect(_on_button_hover.bind(button, true))
		button.mouse_exited.connect(_on_button_hover.bind(button, false))

func _on_button_hover(button: Control, is_hovering: bool) -> void:
	"""Handle button hover effect (scale and brightness)"""
	var target_scale = Vector2(1.05, 1.05) if is_hovering else Vector2(1.0, 1.0)
	var target_modulate = Color(1.2, 1.2, 1.2, 1.0) if is_hovering else Color(1.0, 1.0, 1.0, 1.0)
	
	# Play hover sound
	if is_hovering and audio_manager:
		audio_manager.play_button_hover_sound()
	
	# Animate scale and brightness
	var tween = create_tween()
	tween.set_parallel(true)
	tween.tween_property(button, "scale", target_scale, 0.2).set_trans(Tween.TRANS_BACK).set_ease(Tween.EASE_OUT)
	tween.tween_property(button, "modulate", target_modulate, 0.2)

# ===== SETTINGS & RESET =====

func _on_settings_pressed() -> void:
	"""Open settings menu"""
	audio_manager.play_button_click_sound()
	# TODO: Open settings popup/scene
	print("[MainMenu] Settings button pressed - TODO: Implement settings menu")

func _on_reset_pressed() -> void:
	"""Reset game progress with confirmation"""
	audio_manager.play_button_click_sound()
	# TODO: Show confirmation dialog
	print("[MainMenu] Reset button pressed - TODO: Implement confirmation dialog")
	_show_reset_confirmation()

func _show_reset_confirmation() -> void:
	"""Show confirmation dialog for reset"""
	var dialog = AcceptDialog.new()
	dialog.dialog_text = "Are you sure you want to reset ALL progress?\nThis cannot be undone!"
	dialog.title = "Reset Progress"
	dialog.ok_button_text = "Yes, Reset"
	dialog.cancel_button_text = "Cancel"
	
	# Add cancel button
	dialog.add_cancel_button("Cancel")
	
	# Connect signals
	dialog.confirmed.connect(_reset_game_data)
	dialog.canceled.connect(func(): dialog.queue_free())
	
	add_child(dialog)
	dialog.popup_centered()

func _reset_game_data() -> void:
	"""Actually reset the game data"""
	GlobalData.reset_progress()
	_update_continue_button()
	print("[MainMenu] Game progress reset!")
