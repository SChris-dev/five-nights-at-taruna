extends Node2D

## Door Indicator Graphics Manager
## Displays anomaly sprites when they're at doors and lights are on
## More advanced than simple ColorRect - supports sprites, animations, effects

# Export variables for textures (set in Inspector)
@export_group("Left Door Indicators")
@export var inst_door_texture: Texture2D  # INSTAnomaly at left door
@export var left_door_backup_texture: Texture2D  # Generic indicator if no specific texture

@export_group("Right Door Indicators")
@export var tkj_door_texture: Texture2D  # TKJRoamer at right door
@export var right_door_backup_texture: Texture2D  # Generic indicator

@export_group("Animation Settings")
@export var use_fade_animation: bool = true
@export var fade_duration: float = 0.3
@export var breathing_effect: bool = false  # Subtle pulsing animation
@export var breathing_speed: float = 2.0
@export var breathing_intensity: float = 0.1  # 0.1 = 10% scale change

# References to sprite nodes
@onready var left_indicator_sprite: Sprite2D = $LeftIndicator
@onready var right_indicator_sprite: Sprite2D = $RightIndicator

# Track animation state
var left_tween: Tween = null
var right_tween: Tween = null
var breathing_time: float = 0.0

func _ready() -> void:
	# Setup sprites
	if left_indicator_sprite:
		left_indicator_sprite.visible = false
		if inst_door_texture:
			left_indicator_sprite.texture = inst_door_texture
	
	if right_indicator_sprite:
		right_indicator_sprite.visible = false
		if tkj_door_texture:
			right_indicator_sprite.texture = tkj_door_texture

func _process(delta: float) -> void:
	if breathing_effect:
		breathing_time += delta * breathing_speed
		
		# Apply breathing effect to visible sprites
		if left_indicator_sprite and left_indicator_sprite.visible:
			var breath_scale = 1.0 + sin(breathing_time) * breathing_intensity
			left_indicator_sprite.scale = Vector2(breath_scale, breath_scale)
		
		if right_indicator_sprite and right_indicator_sprite.visible:
			var breath_scale = 1.0 + sin(breathing_time) * breathing_intensity
			right_indicator_sprite.scale = Vector2(breath_scale, breath_scale)

func show_left_indicator(character: String, door_closed: bool) -> void:
	"""Show left door indicator for specific character"""
	if not left_indicator_sprite:
		return
	
	# Set appropriate texture based on character
	match character:
		"INSTAnomaly":
			if inst_door_texture:
				left_indicator_sprite.texture = inst_door_texture
		_:
			if left_door_backup_texture:
				left_indicator_sprite.texture = left_door_backup_texture
	
	# Set opacity based on door state
	var target_alpha = 1.0 if door_closed else 1.0
	
	# Kill existing tween
	if left_tween:
		left_tween.kill()
	
	if use_fade_animation and not left_indicator_sprite.visible:
		# Fade in
		left_indicator_sprite.modulate.a = 0.0
		left_indicator_sprite.visible = true
		
		left_tween = create_tween()
		left_tween.set_ease(Tween.EASE_OUT)
		left_tween.set_trans(Tween.TRANS_SINE)
		left_tween.tween_property(left_indicator_sprite, "modulate:a", target_alpha, fade_duration)
	else:
		# Just show
		left_indicator_sprite.visible = true
		left_indicator_sprite.modulate.a = target_alpha

func hide_left_indicator() -> void:
	"""Hide left door indicator"""
	if not left_indicator_sprite:
		return
	
	# Kill existing tween
	if left_tween:
		left_tween.kill()
	
	if use_fade_animation and left_indicator_sprite.visible:
		# Fade out
		left_tween = create_tween()
		left_tween.set_ease(Tween.EASE_IN)
		left_tween.set_trans(Tween.TRANS_SINE)
		left_tween.tween_property(left_indicator_sprite, "modulate:a", 0.0, fade_duration)
		left_tween.tween_callback(func(): left_indicator_sprite.visible = false)
	else:
		# Just hide
		left_indicator_sprite.visible = false

func update_left_indicator_opacity(door_closed: bool) -> void:
	"""Update left indicator opacity when door state changes"""
	if not left_indicator_sprite or not left_indicator_sprite.visible:
		return
	
	var target_alpha = 1.0 if door_closed else 1.0
	
	# Kill existing tween
	if left_tween:
		left_tween.kill()
	
	if use_fade_animation:
		left_tween = create_tween()
		left_tween.set_ease(Tween.EASE_OUT)
		left_tween.set_trans(Tween.TRANS_SINE)
		left_tween.tween_property(left_indicator_sprite, "modulate:a", target_alpha, fade_duration * 0.5)
	else:
		left_indicator_sprite.modulate.a = target_alpha

func show_right_indicator(character: String, door_closed: bool) -> void:
	"""Show right door indicator for specific character"""
	if not right_indicator_sprite:
		return
	
	# Set appropriate texture based on character
	match character:
		"TKJRoamer":
			if tkj_door_texture:
				right_indicator_sprite.texture = tkj_door_texture
		_:
			if right_door_backup_texture:
				right_indicator_sprite.texture = right_door_backup_texture
	
	# Set opacity based on door state
	var target_alpha = 1.0 if door_closed else 1.0
	
	# Kill existing tween
	if right_tween:
		right_tween.kill()
	
	if use_fade_animation and not right_indicator_sprite.visible:
		# Fade in
		right_indicator_sprite.modulate.a = 0.0
		right_indicator_sprite.visible = true
		
		right_tween = create_tween()
		right_tween.set_ease(Tween.EASE_OUT)
		right_tween.set_trans(Tween.TRANS_SINE)
		right_tween.tween_property(right_indicator_sprite, "modulate:a", target_alpha, fade_duration)
	else:
		# Just show
		right_indicator_sprite.visible = true
		right_indicator_sprite.modulate.a = target_alpha

func hide_right_indicator() -> void:
	"""Hide right door indicator"""
	if not right_indicator_sprite:
		return
	
	# Kill existing tween
	if right_tween:
		right_tween.kill()
	
	if use_fade_animation and right_indicator_sprite.visible:
		# Fade out
		right_tween = create_tween()
		right_tween.set_ease(Tween.EASE_IN)
		right_tween.set_trans(Tween.TRANS_SINE)
		right_tween.tween_property(right_indicator_sprite, "modulate:a", 0.0, fade_duration)
		right_tween.tween_callback(func(): right_indicator_sprite.visible = false)
	else:
		# Just hide
		right_indicator_sprite.visible = false

func update_right_indicator_opacity(door_closed: bool) -> void:
	"""Update right indicator opacity when door state changes"""
	if not right_indicator_sprite or not right_indicator_sprite.visible:
		return
	
	var target_alpha = 1.0 if door_closed else 1.0
	
	# Kill existing tween
	if right_tween:
		right_tween.kill()
	
	if use_fade_animation:
		right_tween = create_tween()
		right_tween.set_ease(Tween.EASE_OUT)
		right_tween.set_trans(Tween.TRANS_SINE)
		right_tween.tween_property(right_indicator_sprite, "modulate:a", target_alpha, fade_duration * 0.5)
	else:
		right_indicator_sprite.modulate.a = target_alpha
