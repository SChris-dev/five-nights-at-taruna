extends Control

# This shows the intro image with fade in/out before the Night intro screen
# Similar to FNAF 1's intro sequence

@export var display_duration: float = 5  # Seconds to show intro image
@export var fade_in_duration: float = 1.0
@export var fade_out_duration: float = 1.0

@onready var intro_image: TextureRect = $IntroImage if has_node("IntroImage") else null
@onready var fade_overlay: ColorRect = $FadeOverlay if has_node("FadeOverlay") else null

var timer: float = 0.0
var state: String = "fade_in"  # States: fade_in, display, fade_out, complete

func _ready() -> void:
	# Start with black screen
	if fade_overlay:
		fade_overlay.modulate.a = 1.0
	
	# Start fade in
	_fade_in()

func _fade_in() -> void:
	state = "fade_in"
	if fade_overlay:
		var tween = create_tween()
		tween.tween_property(fade_overlay, "modulate:a", 0.0, fade_in_duration)
		tween.tween_callback(_on_fade_in_complete)

func _on_fade_in_complete() -> void:
	state = "display"
	timer = 0.0

func _process(delta: float) -> void:
	if state == "display":
		timer += delta
		if timer >= display_duration:
			_fade_out()

func _fade_out() -> void:
	state = "fade_out"
	if fade_overlay:
		var tween = create_tween()
		tween.tween_property(fade_overlay, "modulate:a", 1.0, fade_out_duration)
		tween.tween_callback(_on_fade_out_complete)

func _on_fade_out_complete() -> void:
	state = "complete"
	# Transition to night intro
	get_tree().change_scene_to_file("res://Scenes/Menu/night_intro.tscn")
