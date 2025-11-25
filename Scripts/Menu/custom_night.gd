extends Control

# Custom Night menu where player can set AI difficulty for each animatronic

@onready var freddy_slider: HSlider = $FreddySlider if has_node("FreddySlider") else null
@onready var bonnie_slider: HSlider = $BonnieSlider if has_node("BonnieSlider") else null
@onready var chica_slider: HSlider = $ChicaSlider if has_node("ChicaSlider") else null
@onready var foxy_slider: HSlider = $FoxySlider if has_node("FoxySlider") else null

@onready var freddy_value: Label = $FreddyValue if has_node("FreddyValue") else null
@onready var bonnie_value: Label = $BonnieValue if has_node("BonnieValue") else null
@onready var chica_value: Label = $ChicaValue if has_node("ChicaValue") else null
@onready var foxy_value: Label = $FoxyValue if has_node("FoxyValue") else null

# Preset challenges (famous modes from FNAF 1)
var presets: Dictionary = {
	"4/20 Mode": {"freddy": 20, "bonnie": 20, "chica": 20, "foxy": 20},
	"Golden Freddy": {"freddy": 20, "bonnie": 0, "chica": 0, "foxy": 0},
	"New & Shiny": {"freddy": 0, "bonnie": 10, "chica": 10, "foxy": 10},
	"Blind Mode": {"freddy": 20, "bonnie": 20, "chica": 20, "foxy": 20}
}

func _ready() -> void:
	_setup_sliders()
	_load_saved_levels()

func _setup_sliders() -> void:
	# Set slider ranges (0-20 like FNAF)
	for slider in [freddy_slider, bonnie_slider, chica_slider, foxy_slider]:
		if slider:
			slider.min_value = 0
			slider.max_value = 20
			slider.step = 1
			slider.value = 0

func _load_saved_levels() -> void:
	# Load last custom night settings
	if freddy_slider: freddy_slider.value = GlobalData.custom_night_levels.get("freddy", 20)
	if bonnie_slider: bonnie_slider.value = GlobalData.custom_night_levels.get("bonnie", 20)
	if chica_slider: chica_slider.value = GlobalData.custom_night_levels.get("chica", 20)
	if foxy_slider: foxy_slider.value = GlobalData.custom_night_levels.get("foxy", 20)
	_update_value_labels()

func _update_value_labels() -> void:
	if freddy_value and freddy_slider:
		freddy_value.text = str(int(freddy_slider.value))
	if bonnie_value and bonnie_slider:
		bonnie_value.text = str(int(bonnie_slider.value))
	if chica_value and chica_slider:
		chica_value.text = str(int(chica_slider.value))
	if foxy_value and foxy_slider:
		foxy_value.text = str(int(foxy_slider.value))

func _on_freddy_slider_changed(_value: float) -> void:
	_update_value_labels()

func _on_bonnie_slider_changed(_value: float) -> void:
	_update_value_labels()

func _on_chica_slider_changed(_value: float) -> void:
	_update_value_labels()

func _on_foxy_slider_changed(_value: float) -> void:
	_update_value_labels()

func _on_start_pressed() -> void:
	# Save custom levels to GlobalData
	GlobalData.custom_night_levels["freddy"] = int(freddy_slider.value) if freddy_slider else 20
	GlobalData.custom_night_levels["bonnie"] = int(bonnie_slider.value) if bonnie_slider else 20
	GlobalData.custom_night_levels["chica"] = int(chica_slider.value) if chica_slider else 20
	GlobalData.custom_night_levels["foxy"] = int(foxy_slider.value) if foxy_slider else 20
	
	GlobalData.start_night(7, true)
	get_tree().change_scene_to_file("res://Scenes/Menu/night_intro.tscn")

func _on_back_pressed() -> void:
	get_tree().change_scene_to_file("res://Scenes/Menu/main_menu.tscn")

func _on_preset_selected(preset_name: String) -> void:
	# Load a preset challenge
	if preset_name in presets:
		var preset = presets[preset_name]
		if freddy_slider: freddy_slider.value = preset.get("freddy", 0)
		if bonnie_slider: bonnie_slider.value = preset.get("bonnie", 0)
		if chica_slider: chica_slider.value = preset.get("chica", 0)
		if foxy_slider: foxy_slider.value = preset.get("foxy", 0)
		_update_value_labels()

func _on_reset_pressed() -> void:
	# Reset all to 0
	if freddy_slider: freddy_slider.value = 0
	if bonnie_slider: bonnie_slider.value = 0
	if chica_slider: chica_slider.value = 0
	if foxy_slider: foxy_slider.value = 0
	_update_value_labels()
