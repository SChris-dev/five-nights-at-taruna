extends Node

## Power Out Sequence Manager
## Handles the FNAF 1-style power outage sequence where player waits for their doom

signal sequence_started
signal sequence_ended

@export_group("Sequence Settings")
@export var wait_before_music: float = 1.0  # Delay before music starts
@export var music_duration: float = 15.0  # How long the music plays (random within range)
@export var music_duration_variance: float = 5.0  # +/- variance for randomness
@export var chance_to_survive: float = 0.0  # 0.0 = always jumpscare, 1.0 = always survive
@export var music_clip: AudioStream  # The lullaby/music that plays

@export_group("Visual Settings")
@export var darkness_overlay_color: Color = Color(0, 0, 0, 0.9)  # Almost black
@export var eye_glow_color: Color = Color(1, 0.8, 0.2, 1.0)  # Yellow/orange glow
@export var eye_position: Vector2 = Vector2(400, 300)  # Position of glowing eyes
@export var eye_scale: float = 1.0  # Scale of eye sprite
@export var show_eyes: bool = true  # Show glowing eyes during sequence

@export_group("Node References")
@export var office_manager_path: NodePath
@export var tablet_manager_path: NodePath
@export var ai_manager_path: NodePath
@export var jumpscare_manager_path: NodePath
@export var camera_manager_path: NodePath
@export var door_manager_path: NodePath
@export var hud_path: NodePath
@export var door_graphics_path: NodePath  # For visual door/light control

var office_manager: Node
var tablet_manager: Node
var ai_manager: Node
var jumpscare_manager: Node
var camera_manager: Node
var door_manager: Node
var hud: Node
var door_graphics: Node

var is_sequence_active: bool = false
var darkness_overlay: ColorRect
var eye_sprite: Sprite2D
var audio_player: AudioStreamPlayer
var sequence_timer: float = 0.0
var sequence_duration: float = 0.0

func _ready() -> void:
	# Get node references
	office_manager = get_node(office_manager_path) if office_manager_path else null
	tablet_manager = get_node(tablet_manager_path) if tablet_manager_path else null
	ai_manager = get_node(ai_manager_path) if ai_manager_path else null
	jumpscare_manager = get_node(jumpscare_manager_path) if jumpscare_manager_path else null
	camera_manager = get_node(camera_manager_path) if camera_manager_path else null
	door_manager = get_node(door_manager_path) if door_manager_path else null
	hud = get_node(hud_path) if hud_path else null
	door_graphics = get_node(door_graphics_path) if door_graphics_path else null
	
	# Create darkness overlay (hidden by default)
	darkness_overlay = ColorRect.new()
	darkness_overlay.color = darkness_overlay_color
	darkness_overlay.set_anchors_preset(Control.PRESET_FULL_RECT)
	darkness_overlay.mouse_filter = Control.MOUSE_FILTER_IGNORE
	darkness_overlay.visible = false
	darkness_overlay.z_index = 100  # Above most things
	add_child(darkness_overlay)
	
	# Create eye sprite (hidden by default)
	eye_sprite = Sprite2D.new()
	eye_sprite.modulate = eye_glow_color
	eye_sprite.scale = Vector2(eye_scale, eye_scale)
	eye_sprite.position = eye_position
	eye_sprite.visible = false
	eye_sprite.z_index = 101  # Above darkness
	# Note: Set texture externally or via export
	darkness_overlay.add_child(eye_sprite)
	
	# Create audio player
	audio_player = AudioStreamPlayer.new()
	audio_player.bus = "Master"
	add_child(audio_player)
	
	print("[PowerOutSequence] Ready and waiting for power loss...")

func start_sequence() -> void:
	if is_sequence_active:
		print("[PowerOutSequence] Sequence already active!")
		return
	
	print("[PowerOutSequence] 💀 Power out! Starting sequence...")
	is_sequence_active = true
	emit_signal("sequence_started")
	
	# Close all doors and turn off all lights
	_close_doors_and_lights()
	
	# Force camera/tablet down
	_force_camera_down()
	
	# Hide all UI elements
	_hide_ui()
	
	# Disable button controls but ALLOW looking around
	_disable_button_controls()
	
	# Pause all AI
	_pause_all_ai()
	
	# Show darkness overlay
	darkness_overlay.visible = true
	
	# Calculate random duration for this sequence
	sequence_duration = music_duration + randf_range(-music_duration_variance, music_duration_variance)
	sequence_duration = max(sequence_duration, 5.0)  # Minimum 5 seconds
	sequence_timer = 0.0
	
	print("[PowerOutSequence] Sequence will last:", sequence_duration, "seconds")
	
	# Wait a moment, then play music
	await get_tree().create_timer(wait_before_music).timeout
	_play_music()
	
	# Show glowing eyes after music starts
	if show_eyes:
		await get_tree().create_timer(1.0).timeout
		_show_eyes()

func _process(delta: float) -> void:
	if not is_sequence_active:
		return
	
	sequence_timer += delta
	
	# Check if sequence should end
	if sequence_timer >= sequence_duration:
		_end_sequence()

func _end_sequence() -> void:
	print("[PowerOutSequence] Sequence ending...")
	is_sequence_active = false
	
	# Stop music
	if audio_player.playing:
		audio_player.stop()
	
	# Determine outcome: survive or jumpscare?
	var survived: bool = randf() < chance_to_survive
	
	if survived:
		print("[PowerOutSequence] 🎉 Player survived the night!")
		_player_survived()
	else:
		print("[PowerOutSequence] 💀 Time for jumpscare...")
		_trigger_jumpscare()
	
	emit_signal("sequence_ended")

func _close_doors_and_lights() -> void:
	"""Close all doors and turn off all lights"""
	print("[PowerOutSequence] Closing doors and turning off lights...")
	
	if door_manager:
		# Turn off all lights (state)
		if door_manager.has_method("set_left_light"):
			door_manager.set_left_light(false)
		if door_manager.has_method("set_right_light"):
			door_manager.set_right_light(false)
		
		# Open all doors (power out = doors open) (state)
		if door_manager.has_method("set_left_door"):
			door_manager.set_left_door(false)
		if door_manager.has_method("set_right_door"):
			door_manager.set_right_door(false)
	
	# Also update the visual graphics directly (make sure doors are visually open)
	if door_graphics:
		if door_graphics.has_method("hide_left_door"):
			door_graphics.hide_left_door()
		if door_graphics.has_method("hide_right_door"):
			door_graphics.hide_right_door()

func _disable_button_controls() -> void:
	"""Disable button controls but ALLOW looking around"""
	print("[PowerOutSequence] Disabling buttons, allowing looking around...")
	
	# Disable door/light buttons only (not movement)
	if door_manager and door_manager.has_method("disable_controls"):
		door_manager.disable_controls()
	
	# Disable tablet
	if tablet_manager:
		if tablet_manager.has_method("disable_tablet"):
			tablet_manager.disable_tablet()
		else:
			tablet_manager.is_tablet_up = false
	
	# Keep office scrolling ENABLED (player can look around)
	# Do NOT call office_manager.disable_controls() as that locks movement

func _hide_ui() -> void:
	"""Hide all UI elements (power, hour, etc.)"""
	print("[PowerOutSequence] Hiding UI...")
	
	if hud:
		hud.visible = false

func _pause_all_ai() -> void:
	"""Pause all AI characters during power out"""
	print("[PowerOutSequence] Pausing all AI...")
	
	if ai_manager:
		# Pause all AI children
		for child in ai_manager.get_children():
			if child.has_method("set_paused"):
				child.set_paused(true)
			elif child.has_method("set_process"):
				child.set_process(false)

func _force_camera_down() -> void:
	"""Force camera view down and disable camera access"""
	print("[PowerOutSequence] Forcing camera down...")
	
	if camera_manager:
		if camera_manager.has_method("force_camera_down"):
			camera_manager.force_camera_down()
		elif camera_manager.has_method("set_camera_disabled"):
			camera_manager.set_camera_disabled(true)

func _play_music() -> void:
	"""Play the power out music/lullaby"""
	if not music_clip:
		print("[PowerOutSequence] WARNING: No music clip set!")
		return
	
	print("[PowerOutSequence] 🎵 Playing power out music...")
	audio_player.stream = music_clip
	audio_player.play()

func _show_eyes() -> void:
	"""Show glowing eyes in the darkness"""
	if not show_eyes:
		return
	
	print("[PowerOutSequence] 👀 Showing glowing eyes...")
	eye_sprite.visible = true
	
	# Optional: Add subtle animation to eyes
	var tween = create_tween()
	tween.set_loops()
	tween.tween_property(eye_sprite, "modulate:a", 0.7, 1.5)
	tween.tween_property(eye_sprite, "modulate:a", 1.0, 1.5)

func _trigger_jumpscare() -> void:
	"""Trigger the power out jumpscare"""
	print("[PowerOutSequence] Triggering power out jumpscare!")
	
	# Hide eyes but KEEP darkness overlay visible
	eye_sprite.visible = false
	# Don't hide darkness_overlay - keep it dark!
	
	# Show UI again before jumpscare (optional)
	_restore_ui()
	
	if jumpscare_manager and jumpscare_manager.has_method("trigger_jumpscare"):
		# Trigger jumpscare with specific character (e.g., Freddy or special power out character)
		jumpscare_manager.trigger_jumpscare("BigRobot")  # Or "BigRobot" or whatever you name it
	else:
		print("[PowerOutSequence] ERROR: Could not trigger jumpscare!")
	
	# Wait a brief moment then hide darkness so jumpscare is visible
	await get_tree().create_timer(0.1).timeout
	darkness_overlay.visible = false

func _player_survived() -> void:
	"""Player survived the power out (reached 6 AM)"""
	print("[PowerOutSequence] Player survived!")
	
	# Hide darkness and eyes
	darkness_overlay.visible = false
	eye_sprite.visible = false
	
	# Restore UI
	_restore_ui()
	
	# Trigger night complete / win screen
	# This should be connected to your night timer's night_won signal
	get_tree().call_group("night_timer", "emit_signal", "night_won")

func _restore_ui() -> void:
	"""Restore UI visibility"""
	if hud:
		hud.visible = true

# Public method to set eye texture
func set_eye_texture(texture: Texture2D) -> void:
	if eye_sprite:
		eye_sprite.texture = texture

# Public method to update eye position
func set_eye_position(pos: Vector2) -> void:
	eye_position = pos
	if eye_sprite:
		eye_sprite.position = pos
