extends Control

# This shows the "Night X" title card before starting gameplay

@export var display_duration: float = 0.5  # Seconds to show intro
@export var fade_duration: float = 0.5

@onready var night_label: Label = $NightLabel if has_node("NightLabel") else null
@onready var date_label: Label = $DateLabel if has_node("DateLabel") else null

var timer: float = 0.0

func _ready() -> void:
	_setup_text()
	# TODO: Play intro sound effect here
	
func _setup_text() -> void:
	var night_text = _get_night_text()
	
	if night_label:
		night_label.text = night_text
	
	if date_label:
		date_label.text = _get_date_text()

func _get_night_text() -> String:
	if GlobalData.is_custom_night:
		return "Custom Night"
	
	match GlobalData.current_night:
		1: return "Night 1"
		2: return "Night 2"
		3: return "Night 3"
		4: return "Night 4"
		5: return "Night 5"
		6: return "Night 6"
		_: return "Night 1"

func _get_date_text() -> String:
	# FNAF 1 style date strings
	match GlobalData.current_night:
		1: return "00:00 WIB"
		2: return "00:00 WIB"
		3: return "00:00 WIB"
		4: return "00:00 WIB"
		5: return "00:00 WIB"
		6: return "00:00 WIB"
		_: return ""

func _process(delta: float) -> void:
	timer += delta
	
	if timer >= display_duration:
		_start_night()

func _start_night() -> void:
	# TODO: Add fade out transition here
	get_tree().change_scene_to_file("res://Scenes/Nights/nights.tscn")
