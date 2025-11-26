extends Node

## Jumpscare Manager
## Manages jumpscares for all anomalies with easy spritesheet/animation configuration

signal jumpscare_started(character: String)
signal jumpscare_ended

# General settings
@export_group("General Settings")
@export var jumpscare_duration: float = 1.5  # Seconds (0 = use animation length)
@export var screen_shake_enabled: bool = true
@export var screen_shake_intensity: float = 10.0
@export var fade_to_black: bool = false
@export var fade_duration: float = 0.3

# Slide-in animation settings
@export_group("Slide-In Animation")
@export var slide_in_enabled: bool = true
@export var slide_duration: float = 0.15  # How long the slide-in takes (shorter = snappier)
@export var slide_start_scale: float = 1.5  # Starting scale multiplier (larger = more zoom effect)
@export var slide_offset: Vector2 = Vector2(0, -100)  # Starting position offset
@export_enum("Back", "Elastic", "Bounce", "Cubic", "Quad") var slide_transition: String = "Back"

# Static transition settings
@export_group("Static Transition")
@export var static_duration: float = 1.0  # How long to show static before game over screen
@export var static_animation_speed: float = 60.0  # Frame rate of static animation
@export var static_scale: Vector2 = Vector2(1.6, 1.35)  # Scale of static sprite

# Node references
@export_group("Node References")
@export var office_manager: Node  # To disable controls during jumpscare
@export var camera_manager: Node  # To hide camera
@export var tablet_manager: Node  # To hide tablet
@export var camera_node: Camera2D  # For screen shake effect

# Jumpscare configurations for each anomaly
@export_group("Jumpscare Configurations")
@export var jumpscare_configs: Array[JumpscareConfig] = []

# Container for jumpscare sprites (created dynamically)
@onready var jumpscare_container: CanvasLayer = $JumpscareLayer if has_node("JumpscareLayer") else null
@onready var audio_player: AudioStreamPlayer = $JumpscareAudio if has_node("JumpscareAudio") else null
@onready var fade_rect: ColorRect = $FadeRect if has_node("FadeRect") else null

var is_jumpscare_active: bool = false
var jumpscare_timer: float = 0.0
var current_jumpscare_sprite: Node = null
var original_camera_offset: Vector2 = Vector2.ZERO
var shake_time: float = 0.0

func _ready() -> void:
	_setup_jumpscare_system()
	_validate_configs()
	
	# Store original camera offset for shake reset
	if camera_node:
		original_camera_offset = camera_node.offset

func _validate_configs() -> void:
	"""Validate all jumpscare configs and print warnings"""
	print("[JumpscareManager] Validating", jumpscare_configs.size(), "jumpscare configs...")
	
	for config in jumpscare_configs:
		if not config:
			print("[JumpscareManager] WARNING: Null config in array!")
			continue
		
		if not config.is_valid():
			print("[JumpscareManager] WARNING: Invalid config for:", config.character_name)
			print("  - Has character name:", not config.character_name.is_empty())
			print("  - Use animated:", config.use_animated_sprite)
			print("  - Has texture:", config.static_texture != null)
			print("  - Has frames:", config.sprite_frames != null)
		else:
			print("[JumpscareManager] ✓ Valid config for:", config.character_name)

func _process(delta: float) -> void:
	if is_jumpscare_active:
		# Handle screen shake
		if screen_shake_enabled and camera_node:
			shake_time += delta * 20.0  # Shake frequency
			var shake_offset = Vector2(
				sin(shake_time) * screen_shake_intensity,
				cos(shake_time * 1.5) * screen_shake_intensity
			)
			camera_node.offset = original_camera_offset + shake_offset
		
		# Handle jumpscare timer
		jumpscare_timer += delta
		var duration_to_use = jumpscare_duration
		
		# Check if config has custom duration
		if current_jumpscare_sprite and current_jumpscare_sprite.has_meta("config"):
			var config = current_jumpscare_sprite.get_meta("config") as JumpscareConfig
			if config and config.custom_duration > 0.0:
				duration_to_use = config.custom_duration
		
		# If duration is still 0, use animation length if available
		if duration_to_use == 0.0 and current_jumpscare_sprite:
			if current_jumpscare_sprite is AnimatedSprite2D:
				var anim_sprite = current_jumpscare_sprite as AnimatedSprite2D
				if anim_sprite.sprite_frames:
					duration_to_use = anim_sprite.sprite_frames.get_frame_count("default") / anim_sprite.sprite_frames.get_animation_speed("default")
			else:
				duration_to_use = 1.5  # Fallback
		
		if jumpscare_timer >= duration_to_use:
			_end_jumpscare()

func _setup_jumpscare_system() -> void:
	# Create jumpscare layer if it doesn't exist
	if not jumpscare_container:
		jumpscare_container = CanvasLayer.new()
		jumpscare_container.name = "JumpscareLayer"
		jumpscare_container.layer = 100  # On top of everything
		add_child(jumpscare_container)
	
	# Create audio player if it doesn't exist
	if not audio_player:
		audio_player = AudioStreamPlayer.new()
		audio_player.name = "JumpscareAudio"
		audio_player.bus = "Master"
		add_child(audio_player)
	
	# Create fade rect if it doesn't exist and fade is enabled
	if fade_to_black and not fade_rect:
		fade_rect = ColorRect.new()
		fade_rect.name = "FadeRect"
		fade_rect.color = Color.BLACK
		fade_rect.modulate.a = 0.0
		fade_rect.size = Vector2(1920, 1080)  # Will be resized in viewport
		fade_rect.mouse_filter = Control.MOUSE_FILTER_IGNORE
		jumpscare_container.add_child(fade_rect)
		
		# Set to fill viewport
		fade_rect.set_anchors_and_offsets_preset(Control.PRESET_FULL_RECT)

func trigger_jumpscare(character: String) -> void:
	if is_jumpscare_active:
		return  # Already in jumpscare
	
	print("[JumpscareManager] Triggering jumpscare for:", character)
	
	is_jumpscare_active = true
	jumpscare_timer = 0.0
	shake_time = 0.0
	
	# Disable game controls
	_disable_game_controls()
	
	# Hide UI elements
	_hide_game_ui()
	
	# Play jumpscare visual
	_play_jumpscare_for(character)
	
	# Play jumpscare sound
	_play_jumpscare_sound(character)
	
	# Fade effect
	if fade_to_black and fade_rect:
		_fade_in()
	
	# Record in GlobalData
	GlobalData.game_over(character)
	
	emit_signal("jumpscare_started", character)

func _play_jumpscare_for(character: String) -> void:
	# Find matching jumpscare config
	var config: JumpscareConfig = _get_config_for_character(character)
	
	if not config:
		print("[JumpscareManager] WARNING: No jumpscare config found for:", character)
		return
	
	print("[JumpscareManager] Found config for:", character)
	print("[JumpscareManager] Use animated:", config.use_animated_sprite)
	print("[JumpscareManager] Has sprite_frames:", config.sprite_frames != null)
	print("[JumpscareManager] Has static_texture:", config.static_texture != null)
	
	# Clear previous jumpscare sprite
	if current_jumpscare_sprite:
		current_jumpscare_sprite.queue_free()
		current_jumpscare_sprite = null
	
	# Get viewport size for proper centering
	var viewport_size = get_viewport().get_visible_rect().size
	var center_pos = viewport_size / 2.0
	
	print("[JumpscareManager] Viewport size:", viewport_size)
	print("[JumpscareManager] Center position:", center_pos)
	
	# Create appropriate sprite type based on config
	if config.use_animated_sprite and config.sprite_frames:
		# Use AnimatedSprite2D for frame-by-frame animation
		var anim_sprite = AnimatedSprite2D.new()
		anim_sprite.sprite_frames = config.sprite_frames
		anim_sprite.centered = true
		anim_sprite.position = center_pos
		
		# Apply scale
		if config.jumpscare_scale > 0:
			anim_sprite.scale = Vector2(config.jumpscare_scale, config.jumpscare_scale)
		
		# Store config reference for duration
		anim_sprite.set_meta("config", config)
		
		jumpscare_container.add_child(anim_sprite)
		anim_sprite.play("default")
		current_jumpscare_sprite = anim_sprite
		print("[JumpscareManager] Created AnimatedSprite2D")
		
	elif config.static_texture:
		# Use Sprite2D for static image
		var sprite = Sprite2D.new()
		sprite.texture = config.static_texture
		sprite.centered = true
		sprite.position = center_pos
		
		# Apply scale
		if config.jumpscare_scale > 0:
			sprite.scale = Vector2(config.jumpscare_scale, config.jumpscare_scale)
		
		# Store config reference for duration
		sprite.set_meta("config", config)
		
		jumpscare_container.add_child(sprite)
		current_jumpscare_sprite = sprite
		print("[JumpscareManager] Created Sprite2D")
	else:
		print("[JumpscareManager] WARNING: No texture/animation set for:", character)
	
	# Apply slide-in animation for dynamic effect
	if current_jumpscare_sprite:
		_apply_slide_in_animation(current_jumpscare_sprite, center_pos)

func _apply_slide_in_animation(sprite: Node2D, final_pos: Vector2) -> void:
	"""Apply a quick slide-in animation to make the jumpscare feel more dynamic"""
	
	if not slide_in_enabled:
		return
	
	# Store the final scale before modifying
	var final_scale = sprite.scale
	
	# Start from slightly off-screen (closer to camera/larger)
	sprite.scale *= slide_start_scale  # Start larger for zoom effect
	sprite.modulate.a = 0.0  # Start invisible
	
	# Position slightly offset for slide effect
	sprite.position = final_pos + slide_offset
	
	# Create the tween animation
	var tween = create_tween()
	tween.set_parallel(true)  # Run all animations simultaneously
	tween.set_ease(Tween.EASE_OUT)
	
	# Set transition type based on export variable
	match slide_transition:
		"Back":
			tween.set_trans(Tween.TRANS_BACK)  # Gives a slight overshoot for impact
		"Elastic":
			tween.set_trans(Tween.TRANS_ELASTIC)  # Bouncy elastic effect
		"Bounce":
			tween.set_trans(Tween.TRANS_BOUNCE)  # Multiple bounces
		"Cubic":
			tween.set_trans(Tween.TRANS_CUBIC)  # Smooth curve
		"Quad":
			tween.set_trans(Tween.TRANS_QUAD)  # Gentler curve
		_:
			tween.set_trans(Tween.TRANS_BACK)
	
	# Animate position (slide in)
	tween.tween_property(sprite, "position", final_pos, slide_duration)
	
	# Animate scale (zoom in effect)
	tween.tween_property(sprite, "scale", final_scale, slide_duration)
	
	# Animate opacity (fade in quickly)
	tween.tween_property(sprite, "modulate:a", 1.0, slide_duration * 0.5)

func _get_config_for_character(character: String) -> JumpscareConfig:
	# Find config matching character name
	for config in jumpscare_configs:
		if config and config.character_name.to_lower() == character.to_lower():
			return config
	return null

func _disable_game_controls() -> void:
	# Disable office scrolling
	if office_manager and office_manager.has_method("disable_controls"):
		office_manager.disable_controls()
	
	# Close camera if open
	if tablet_manager:
		tablet_manager.is_tablet_up = false
		if tablet_manager.has_node("Tablet_Sprite"):
			tablet_manager.get_node("Tablet_Sprite").visible = false
	
	# Disable camera
	if camera_manager:
		camera_manager.visible = false

func _hide_game_ui() -> void:
	# Hide tablet button, office elements, etc.
	if tablet_manager and tablet_manager.has_node("Tablet_Button"):
		tablet_manager.get_node("Tablet_Button").visible = false

func _play_jumpscare_sound(character: String) -> void:
	if not audio_player:
		return
	
	var config: JumpscareConfig = _get_config_for_character(character)
	
	if config and config.jumpscare_sound:
		audio_player.stream = config.jumpscare_sound
		audio_player.play()
		print("[JumpscareManager] Playing jumpscare sound for:", character)
	else:
		print("[JumpscareManager] No jumpscare sound configured for:", character)

func _end_jumpscare() -> void:
	is_jumpscare_active = false
	
	# Reset camera shake
	if camera_node:
		camera_node.offset = original_camera_offset
	
	# Stop audio
	#if audio_player and audio_player.playing:
		#audio_player.stop()
	
	emit_signal("jumpscare_ended")
	
	# Clean up jumpscare sprite before showing static
	if current_jumpscare_sprite:
		current_jumpscare_sprite.queue_free()
		current_jumpscare_sprite = null
	
	# Show static effect and wait for configured duration
	_show_static_transition()
	
	# Wait for static to play before transitioning to game over
	print("[JumpscareManager] Playing static for", static_duration, "seconds")
	await get_tree().create_timer(static_duration).timeout
	
	get_tree().change_scene_to_file("res://Scenes/Menu/game_over.tscn")

func _show_static_transition() -> void:
	"""Show static effect immediately when jumpscare ends to prevent empty frame"""
	# Load and show the static animation
	var static_texture = preload("res://Graphics/Static/static_anim.png")
	
	# Create static sprite
	var static_sprite = AnimatedSprite2D.new()
	static_sprite.centered = true
	
	# Get viewport size for centering
	var viewport_size = get_viewport().get_visible_rect().size
	static_sprite.position = viewport_size / 2.0
	
	# Create sprite frames for static animation
	var sprite_frames = SpriteFrames.new()
	sprite_frames.add_animation("default")
	
	# Add frames from the static spritesheet (4 frames in a 2x2 grid)
	var frame_width = 1198
	var frame_height = 890
	
	for i in range(4):
		var atlas = AtlasTexture.new()
		atlas.atlas = static_texture
		var x = (i % 2) * frame_width
		var y = (i / 2) * frame_height
		atlas.region = Rect2(x, y, frame_width, frame_height)
		sprite_frames.add_frame("default", atlas)
	
	# Use customizable animation speed
	sprite_frames.set_animation_speed("default", static_animation_speed)
	sprite_frames.set_animation_loop("default", true)
	
	static_sprite.sprite_frames = sprite_frames
	static_sprite.scale = static_scale  # Use customizable scale
	
	jumpscare_container.add_child(static_sprite)
	static_sprite.play("default")
	
	print("[JumpscareManager] Static transition displayed (duration:", static_duration, "s, speed:", static_animation_speed, "fps)")

func _fade_in() -> void:
	if not fade_rect:
		return
	
	fade_rect.modulate.a = 0.0
	var tween = create_tween()
	tween.set_ease(Tween.EASE_IN)
	tween.set_trans(Tween.TRANS_CUBIC)
	tween.tween_property(fade_rect, "modulate:a", 0.8, fade_duration)

# Public utility methods
func add_jumpscare_config(character_name: String, texture: Texture2D = null, frames: SpriteFrames = null, sound: AudioStream = null) -> void:
	"""Helper method to add jumpscare config at runtime"""
	var config = JumpscareConfig.new()
	config.character_name = character_name
	config.static_texture = texture
	config.sprite_frames = frames
	config.use_animated_sprite = (frames != null)
	config.jumpscare_sound = sound
	jumpscare_configs.append(config)
	print("[JumpscareManager] Added config for:", character_name)

func get_character_config(character_name: String) -> JumpscareConfig:
	"""Get the jumpscare config for a specific character"""
	return _get_config_for_character(character_name)
