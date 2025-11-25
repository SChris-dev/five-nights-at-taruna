extends Control

# Shows "6 AM" screen after completing a night

@export var display_duration: float = 5.0
@export var paycheck_delay: float = 2.0  # Delay before showing paycheck

@onready var six_am_label: Label = $SixAMLabel if has_node("SixAMLabel") else null
@onready var paycheck_panel: Control = $PaycheckPanel if has_node("PaycheckPanel") else null
@onready var night_label: Label = $PaycheckPanel/NightLabel if has_node("PaycheckPanel/NightLabel") else null
@onready var amount_label: Label = $PaycheckPanel/AmountLabel if has_node("PaycheckPanel/AmountLabel") else null

var timer: float = 0.0
var paycheck_shown: bool = false

func _ready() -> void:
	GlobalData.complete_night()
	
	if paycheck_panel:
		paycheck_panel.visible = false
	
	if night_label and not GlobalData.is_custom_night:
		night_label.text = "Night %d Complete" % GlobalData.current_night
	elif night_label:
		night_label.text = "Custom Night Complete"
	
	if amount_label:
		amount_label.text = _get_paycheck_amount()
	
	# TODO: Play 6 AM chime sound

func _get_paycheck_amount() -> String:
	# FNAF 1 style paycheck amounts
	if GlobalData.is_custom_night:
		return "$0.00"  # No pay for custom night
	
	match GlobalData.current_night:
		1, 2, 3, 4: return "$120.00"
		5: return "$120.50"
		6: return "$0.50"  # Overtime
		_: return "$120.00"

func _process(delta: float) -> void:
	timer += delta
	
	# Show paycheck after delay
	if not paycheck_shown and timer >= paycheck_delay:
		paycheck_shown = true
		if paycheck_panel:
			paycheck_panel.visible = true
		# TODO: Play paper sound effect
	
	# Return to menu after display duration
	if timer >= display_duration:
		_return_to_menu()

func _return_to_menu() -> void:
	get_tree().change_scene_to_file("res://Scenes/Menu/main_menu.tscn")

func _input(event: InputEvent) -> void:
	# Allow skipping with any key/click
	if event is InputEventMouseButton or event is InputEventKey:
		if event.is_pressed():
			_return_to_menu()
