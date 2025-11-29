extends Control

## Settings Menu
## Allows players to configure game settings like subtitles

@onready var subtitle_checkbox: CheckBox = $Panel/VBoxContainer/SubtitleCheckBox if has_node("Panel/VBoxContainer/SubtitleCheckBox") else null
@onready var continuous_nights_checkbox: CheckBox = $Panel/VBoxContainer/ContinuousNightsCheckBox if has_node("Panel/VBoxContainer/ContinuousNightsCheckBox") else null
@onready var close_button: Button = $Panel/VBoxContainer/CloseButton if has_node("Panel/VBoxContainer/CloseButton") else null

func _ready() -> void:
	# Load current settings
	if subtitle_checkbox:
		subtitle_checkbox.button_pressed = GlobalData.subtitles_enabled
		subtitle_checkbox.toggled.connect(_on_subtitle_toggled)
	
	if continuous_nights_checkbox:
		continuous_nights_checkbox.button_pressed = GlobalData.continuous_nights
		continuous_nights_checkbox.toggled.connect(_on_continuous_nights_toggled)
	
	if close_button:
		close_button.pressed.connect(_on_close_pressed)

func _on_subtitle_toggled(enabled: bool) -> void:
	"""Called when subtitle checkbox is toggled"""
	GlobalData.subtitles_enabled = enabled
	GlobalData.save_progress()
	print("[Settings] Subtitles ", "enabled" if enabled else "disabled")

func _on_continuous_nights_toggled(enabled: bool) -> void:
	"""Called when continuous nights checkbox is toggled"""
	GlobalData.continuous_nights = enabled
	GlobalData.save_progress()
	print("[Settings] Continuous Nights ", "enabled" if enabled else "disabled")

func _on_close_pressed() -> void:
	"""Close the settings menu"""
	queue_free()

func _input(event: InputEvent) -> void:
	# Close on ESC key
	if event.is_action_pressed("ui_cancel"):
		_on_close_pressed()
