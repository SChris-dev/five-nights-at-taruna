extends Control

# Game over screen after jumpscare

@export var display_duration: float = 10.0
@export var min_click_delay: float = 1.0  # Minimum time before user can skip
@export var fade_out_duration: float = 1.0
@export_enum("Fade", "Static") var transition_type: String = "Static"

@onready var static_sprite: AnimatedSprite2D = $StaticSprite if has_node("StaticSprite") else null
@onready var game_over_text: Label = $GameOverText if has_node("GameOverText") else null

var timer: float = 0.0
var static_shown: bool = false
var is_transitioning: bool = false
var fade_overlay: ColorRect = null

func _ready() -> void:
	# Show which animatronic got you (optional)
	if game_over_text and GlobalData.game_over_reason != "":
		game_over_text.text = ""  # Don't show in FNAF 1 style
	
	# Show static immediately (no delay)
	if static_sprite:
		static_sprite.visible = true
		static_sprite.play()
		static_shown = true
	
	# Create fade overlay if using fade transition
	if transition_type == "Fade":
		fade_overlay = ColorRect.new()
		fade_overlay.color = Color.BLACK
		fade_overlay.modulate.a = 0.0
		fade_overlay.set_anchors_preset(Control.PRESET_FULL_RECT)
		fade_overlay.mouse_filter = Control.MOUSE_FILTER_IGNORE
		add_child(fade_overlay)
	
	# TODO: Play jumpscare sound effect

func _process(delta: float) -> void:
	timer += delta
	
	# Return to menu after display duration
	if timer >= display_duration and not is_transitioning:
		_return_to_menu()

func _return_to_menu() -> void:
	if is_transitioning:
		return
	
	is_transitioning = true
	
	# Play transition effect before returning to menu
	if transition_type == "Static":
		await _play_static_transition()
	else:  # Fade
		await _play_fade_transition()
	
	get_tree().change_scene_to_file("res://Scenes/Menu/main_menu.tscn")

func _play_fade_transition() -> void:
	"""Fade to black before transitioning"""
	if not fade_overlay:
		return
	
	var tween = create_tween()
	tween.set_ease(Tween.EASE_IN)
	tween.set_trans(Tween.TRANS_CUBIC)
	tween.tween_property(fade_overlay, "modulate:a", 1.0, fade_out_duration)
	await tween.finished

func _play_static_transition() -> void:
	"""Flash static effect before transitioning"""
	if static_sprite:
		# Make static more intense by increasing speed
		if static_sprite.sprite_frames:
			static_sprite.sprite_frames.set_animation_speed("default", 120.0)
		
		# Flash static for a moment
		await get_tree().create_timer(0.5).timeout

func _input(event: InputEvent) -> void:
	# Allow skipping with any key/click after minimum delay
	if timer >= min_click_delay and not is_transitioning:
		if event is InputEventMouseButton or event is InputEventKey:
			if event.is_pressed():
				_return_to_menu()
