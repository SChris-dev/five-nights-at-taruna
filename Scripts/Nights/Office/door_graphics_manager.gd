extends Node2D

## Door Graphics Manager
## Handles the visual representation of doors when they are closed/opened
## Doors appear as separate sprites above the office background but below buttons

# References to door sprites
@onready var left_door_sprite: Sprite2D = $LeftDoor
@onready var right_door_sprite: Sprite2D = $RightDoor

# Animation settings
@export var door_animation_duration: float = 0.5  # Duration in seconds for door to slide
@export var use_slide_animation: bool = true  # If false, doors just appear/disappear

# Animation intensity settings
@export_enum("Linear", "Sine", "Quad", "Cubic", "Quart", "Quint", "Expo", "Circ", "Back", "Bounce", "Elastic") var ease_type: String = "Quad"
@export_enum("In", "Out", "InOut") var ease_direction: String = "Out"

# Door textures (set these in the inspector or load them here)
@export var left_door_texture: Texture2D
@export var right_door_texture: Texture2D

# Starting positions for door animation (doors slide down from above)
var left_door_start_pos: Vector2
var right_door_start_pos: Vector2
var left_door_end_pos: Vector2
var right_door_end_pos: Vector2

# Track door states
var left_door_visible: bool = false
var right_door_visible: bool = false

# Store active tweens to kill them if needed
var left_door_tween: Tween = null
var right_door_tween: Tween = null

func _ready() -> void:
	# Setup door sprites
	if left_door_sprite and left_door_texture:
		left_door_sprite.texture = left_door_texture
		left_door_sprite.visible = false
		# Store positions (adjust these based on your door sprite positions)
		left_door_end_pos = left_door_sprite.position
		left_door_start_pos = left_door_end_pos - Vector2(0, 1500)  # Start 200 pixels above
	
	if right_door_sprite and right_door_texture:
		right_door_sprite.texture = right_door_texture
		right_door_sprite.visible = false
		# Store positions
		right_door_end_pos = right_door_sprite.position
		right_door_start_pos = right_door_end_pos - Vector2(0, 1500)  # Start 200 pixels above

func show_left_door() -> void:
	"""Shows/animates the left door closing"""
	if left_door_visible:
		return
	
	left_door_visible = true
	
	if not left_door_sprite:
		return
	
	# Kill any existing tween to prevent conflicts
	if left_door_tween:
		left_door_tween.kill()
	
	if use_slide_animation:
		# Slide down animation
		left_door_sprite.position = left_door_start_pos
		left_door_sprite.visible = true
		
		left_door_tween = create_tween()
		left_door_tween.set_ease(_get_ease_type())
		left_door_tween.set_trans(_get_trans_type())
		left_door_tween.tween_property(left_door_sprite, "position", left_door_end_pos, door_animation_duration)
	else:
		# Just appear
		left_door_sprite.position = left_door_end_pos
		left_door_sprite.visible = true

func hide_left_door() -> void:
	"""Hides/animates the left door opening"""
	if not left_door_visible:
		return
	
	left_door_visible = false
	
	if not left_door_sprite:
		return
	
	# Kill any existing tween to prevent conflicts
	if left_door_tween:
		left_door_tween.kill()
	
	if use_slide_animation:
		# Slide up animation
		left_door_tween = create_tween()
		left_door_tween.set_ease(_get_ease_type())
		left_door_tween.set_trans(_get_trans_type())
		left_door_tween.tween_property(left_door_sprite, "position", left_door_start_pos, door_animation_duration)
		left_door_tween.tween_callback(func(): left_door_sprite.visible = false)
	else:
		# Just disappear
		left_door_sprite.visible = false

func show_right_door() -> void:
	"""Shows/animates the right door closing"""
	if right_door_visible:
		return
	
	right_door_visible = true
	
	if not right_door_sprite:
		return
	
	# Kill any existing tween to prevent conflicts
	if right_door_tween:
		right_door_tween.kill()
	
	if use_slide_animation:
		# Slide down animation
		right_door_sprite.position = right_door_start_pos
		right_door_sprite.visible = true
		
		right_door_tween = create_tween()
		right_door_tween.set_ease(_get_ease_type())
		right_door_tween.set_trans(_get_trans_type())
		right_door_tween.tween_property(right_door_sprite, "position", right_door_end_pos, door_animation_duration)
	else:
		# Just appear
		right_door_sprite.position = right_door_end_pos
		right_door_sprite.visible = true

func hide_right_door() -> void:
	"""Hides/animates the right door opening"""
	if not right_door_visible:
		return
	
	right_door_visible = false
	
	if not right_door_sprite:
		return
	
	# Kill any existing tween to prevent conflicts
	if right_door_tween:
		right_door_tween.kill()
	
	if use_slide_animation:
		# Slide up animation
		right_door_tween = create_tween()
		right_door_tween.set_ease(_get_ease_type())
		right_door_tween.set_trans(_get_trans_type())
		right_door_tween.tween_property(right_door_sprite, "position", right_door_start_pos, door_animation_duration)
		right_door_tween.tween_callback(func(): right_door_sprite.visible = false)
	else:
		# Just disappear
		right_door_sprite.visible = false

func set_left_door_state(closed: bool) -> void:
	"""Public method to set left door state"""
	if closed:
		show_left_door()
	else:
		hide_left_door()

func set_right_door_state(closed: bool) -> void:
	"""Public method to set right door state"""
	if closed:
		show_right_door()
	else:
		hide_right_door()

# Helper functions to convert string enums to Godot constants
func _get_ease_type() -> Tween.EaseType:
	match ease_direction:
		"In":
			return Tween.EASE_IN
		"Out":
			return Tween.EASE_OUT
		"InOut":
			return Tween.EASE_IN_OUT
	return Tween.EASE_OUT

func _get_trans_type() -> Tween.TransitionType:
	match ease_type:
		"Linear":
			return Tween.TRANS_LINEAR
		"Sine":
			return Tween.TRANS_SINE
		"Quad":
			return Tween.TRANS_QUAD
		"Cubic":
			return Tween.TRANS_CUBIC
		"Quart":
			return Tween.TRANS_QUART
		"Quint":
			return Tween.TRANS_QUINT
		"Expo":
			return Tween.TRANS_EXPO
		"Circ":
			return Tween.TRANS_CIRC
		"Back":
			return Tween.TRANS_BACK
		"Bounce":
			return Tween.TRANS_BOUNCE
		"Elastic":
			return Tween.TRANS_ELASTIC
	return Tween.TRANS_QUAD
