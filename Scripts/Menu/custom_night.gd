extends Control

# Custom Night menu - FNAF-style difficulty sliders (0-20)
# Uses YOUR 6 Taruna Anomaly animatronics!

# Sliders (Card-based layout)
@onready var inst_slider: HSlider = $CharacterGrid/INSTCard/VBoxContainer/SliderContainer/Slider
@onready var tkj_roamer_slider: HSlider = $CharacterGrid/TKJRoamerCard/VBoxContainer/SliderContainer/Slider
@onready var tkr_sprinter_slider: HSlider = $CharacterGrid/TKRSprinterCard/VBoxContainer/SliderContainer/Slider
@onready var big_robot_slider: HSlider = $CharacterGrid/BigRobotCard/VBoxContainer/SliderContainer/Slider
@onready var rpl_disruptor_slider: HSlider = $CharacterGrid/RPLDisruptorCard/VBoxContainer/SliderContainer/Slider
@onready var tkj_drainer_slider: HSlider = $CharacterGrid/TKJDrainerCard/VBoxContainer/SliderContainer/Slider

# Value labels (Card-based layout)
@onready var inst_value: Label = $CharacterGrid/INSTCard/VBoxContainer/SliderContainer/Value
@onready var tkj_roamer_value: Label = $CharacterGrid/TKJRoamerCard/VBoxContainer/SliderContainer/Value
@onready var tkr_sprinter_value: Label = $CharacterGrid/TKRSprinterCard/VBoxContainer/SliderContainer/Value
@onready var big_robot_value: Label = $CharacterGrid/BigRobotCard/VBoxContainer/SliderContainer/Value
@onready var rpl_disruptor_value: Label = $CharacterGrid/RPLDisruptorCard/VBoxContainer/SliderContainer/Value
@onready var tkj_drainer_value: Label = $CharacterGrid/TKJDrainerCard/VBoxContainer/SliderContainer/Value

# Portrait TextureRects for character images
@onready var inst_portrait: ColorRect = $CharacterGrid/INSTCard/VBoxContainer/Portrait
@onready var tkj_roamer_portrait: ColorRect = $CharacterGrid/TKJRoamerCard/VBoxContainer/Portrait
@onready var tkr_sprinter_portrait: ColorRect = $CharacterGrid/TKRSprinterCard/VBoxContainer/Portrait
@onready var big_robot_portrait: ColorRect = $CharacterGrid/BigRobotCard/VBoxContainer/Portrait
@onready var rpl_disruptor_portrait: ColorRect = $CharacterGrid/RPLDisruptorCard/VBoxContainer/Portrait
@onready var tkj_drainer_portrait: ColorRect = $CharacterGrid/TKJDrainerCard/VBoxContainer/Portrait

func _ready() -> void:
	_load_saved_levels()

func _load_saved_levels() -> void:
	# Load last custom night settings (defaults to 0)
	inst_slider.value = GlobalData.custom_night_levels.get("inst", 0)
	tkj_roamer_slider.value = GlobalData.custom_night_levels.get("tkj_roamer", 0)
	tkr_sprinter_slider.value = GlobalData.custom_night_levels.get("tkr_sprinter", 0)
	big_robot_slider.value = GlobalData.custom_night_levels.get("big_robot", 0)
	rpl_disruptor_slider.value = GlobalData.custom_night_levels.get("rpl_disruptor", 0)
	tkj_drainer_slider.value = GlobalData.custom_night_levels.get("tkj_drainer", 0)
	_update_value_labels()

func _update_value_labels() -> void:
	inst_value.text = str(int(inst_slider.value))
	tkj_roamer_value.text = str(int(tkj_roamer_slider.value))
	tkr_sprinter_value.text = str(int(tkr_sprinter_slider.value))
	big_robot_value.text = str(int(big_robot_slider.value))
	rpl_disruptor_value.text = str(int(rpl_disruptor_slider.value))
	tkj_drainer_value.text = str(int(tkj_drainer_slider.value))

func _on_slider_changed(_value: float) -> void:
	_update_value_labels()

func _on_start_pressed() -> void:
	# Save custom levels to GlobalData (using correct animatronic keys)
	GlobalData.custom_night_levels["inst"] = int(inst_slider.value)
	GlobalData.custom_night_levels["tkj_roamer"] = int(tkj_roamer_slider.value)
	GlobalData.custom_night_levels["tkr_sprinter"] = int(tkr_sprinter_slider.value)
	GlobalData.custom_night_levels["big_robot"] = int(big_robot_slider.value)
	GlobalData.custom_night_levels["rpl_disruptor"] = int(rpl_disruptor_slider.value)
	GlobalData.custom_night_levels["tkj_drainer"] = int(tkj_drainer_slider.value)
	
	# Start custom night (night 7)
	GlobalData.start_night(7, true)
	get_tree().change_scene_to_file("res://Scenes/Menu/night_intro.tscn")

func _on_back_pressed() -> void:
	get_tree().change_scene_to_file("res://Scenes/Menu/main_menu.tscn")

func _on_reset_pressed() -> void:
	# Reset all to 0
	inst_slider.value = 0
	tkj_roamer_slider.value = 0
	tkr_sprinter_slider.value = 0
	big_robot_slider.value = 0
	rpl_disruptor_slider.value = 0
	tkj_drainer_slider.value = 0
	_update_value_labels()
