extends Sprite2D

const SCROLL_SMOOTHING: int = 9 # Lower for smoother scrolling
const SCROLL_SPEED: float = 0.07 # Lower for faster scrolling
const SCROLL_SCREEN_FRACTION: float = 3 # Lower for bigger scroll areas

@export var scroll_clamp: int = 650 # Clamps office scrolling on both sides
@export var door_manager: Node # Reference to door_and_light_manager

var scroll_area_left: float
var scroll_area_right: float
var scroll_amount: float = 0
var can_move: bool = true

# Office spritesheet frames (3000x6000, 4 frames of 1500 height each)
var office_texture: Texture2D
var frame_both_off: AtlasTexture
var frame_both_on: AtlasTexture
var frame_left_on: AtlasTexture
var frame_right_on: AtlasTexture

func _ready() -> void:
	_initialize_scroll_areas(get_viewport())
	_setup_spritesheet_frames()
	_update_office_frame()

func _physics_process(delta: float) -> void:
	_handle_move(delta)
	_update_office_frame()

func _initialize_scroll_areas(viewport: Viewport) -> void:
	var view_size_x: float = viewport.content_scale_size.x
	# Fixes an issue on the right edge of the screen related to how getting the mouse position works
	var scroll_area_offset: float = 1 / (viewport.size.x / view_size_x)
	
	var scroll_area_size: float = view_size_x / SCROLL_SCREEN_FRACTION
	scroll_area_left = scroll_area_size
	scroll_area_right = view_size_x - (scroll_area_size + scroll_area_offset)

func _handle_move(delta: float) -> void:
	if can_move:
		var mouse_position: Vector2 = get_global_mouse_position()
		# Checks if the mouse is within one of the scroll areas, and scrolls if it is
		if mouse_position.x < scroll_area_left:
			scroll_amount += (scroll_area_left - mouse_position.x) * SCROLL_SPEED
		elif mouse_position.x > scroll_area_right:
			scroll_amount += (scroll_area_right - mouse_position.x) * SCROLL_SPEED
	
	# Clamps the position so the office doesn't leave the frame
	scroll_amount = clamp(scroll_amount, -scroll_clamp, scroll_clamp)
	position.x = lerp(position.x, scroll_amount, SCROLL_SMOOTHING * delta)

func _setup_spritesheet_frames() -> void:
	# Load the office spritesheet
	office_texture = preload("res://Graphics/Office/office_complete.png")
	
	# Create AtlasTextures for each frame (3000 width x 1500 height per frame)
	# Frame 0: Both lights off (y=0)
	frame_both_off = AtlasTexture.new()
	frame_both_off.atlas = office_texture
	frame_both_off.region = Rect2(0, 0, 3000, 1500)
	
	# Frame 1: Both lights on (y=1500)
	frame_both_on = AtlasTexture.new()
	frame_both_on.atlas = office_texture
	frame_both_on.region = Rect2(0, 1500, 3000, 1500)
	
	# Frame 2: Left light on, right off (y=3000)
	frame_left_on = AtlasTexture.new()
	frame_left_on.atlas = office_texture
	frame_left_on.region = Rect2(0, 3000, 3000, 1500)
	
	# Frame 3: Right light on, left off (y=4500)
	frame_right_on = AtlasTexture.new()
	frame_right_on.atlas = office_texture
	frame_right_on.region = Rect2(0, 4500, 3000, 1500)

func _update_office_frame() -> void:
	# Update the office sprite based on light states
	if not door_manager:
		return
	
	var left_light: bool = door_manager.left_light_on
	var right_light: bool = door_manager.right_light_on
	
	# Determine which frame to show
	if left_light and right_light:
		texture = frame_both_on
	elif left_light and not right_light:
		texture = frame_left_on
	elif not left_light and right_light:
		texture = frame_right_on
	else:
		texture = frame_both_off
