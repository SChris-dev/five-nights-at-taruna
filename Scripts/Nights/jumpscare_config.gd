extends Resource
class_name JumpscareConfig

## Configuration for a single character's jumpscare
## This resource makes it easy to configure jumpscares per anomaly in the Inspector

# Character identification
@export var character_name: String = ""

# Visual settings - Choose ONE of these two options:
@export_group("Visual Settings")
@export var use_animated_sprite: bool = false  # If true, uses sprite_frames; if false, uses static_texture

# Option 1: Static image (simple jumpscare)
@export var static_texture: Texture2D = null

# Option 2: Animated spritesheet (frame-by-frame animation)
@export var sprite_frames: SpriteFrames = null

# Display settings
@export_group("Display Settings")
@export var jumpscare_scale: float = 1.0  # Scale multiplier (1.0 = original size)
@export var custom_duration: float = 0.0  # Override global duration (0 = use global)

# Audio settings
@export_group("Audio Settings")
@export var jumpscare_sound: AudioStream = null
@export var sound_volume_db: float = 0.0  # Volume adjustment (-80 to 24)

# Effect settings
@export_group("Effect Settings")
@export var override_shake_intensity: float = -1.0  # -1 = use global setting
@export var custom_fade: bool = false  # Use custom fade for this character
@export var fade_color: Color = Color.BLACK

# Behavior
@export_group("Behavior")
@export var instant_kill: bool = true  # Go to game over after jumpscare
@export var special_behavior: bool = false  # For unique jumpscares (like Golden Freddy)

func is_valid() -> bool:
	"""Check if this config has the minimum required data"""
	if character_name.is_empty():
		return false
	
	if use_animated_sprite:
		return sprite_frames != null
	else:
		return static_texture != null
