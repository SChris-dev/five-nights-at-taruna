extends Control

# Shows "6 AM" screen after completing a night

@export var display_duration: float = 5.0
@export var paycheck_delay: float = 2.0  # Delay before showing paycheck
@export var fade_in_duration: float = 1.0  # How long the fade-in takes

@onready var six_am_label: Label = $SixAMLabel if has_node("SixAMLabel") else null
@onready var paycheck_panel: Control = $PaycheckPanel if has_node("PaycheckPanel") else null
@onready var night_label: Label = $PaycheckPanel/NightLabel if has_node("PaycheckPanel/NightLabel") else null
@onready var amount_label: Label = $PaycheckPanel/AmountLabel if has_node("PaycheckPanel/AmountLabel") else null

var timer: float = 0.0
var paycheck_shown: bool = false
var fade_overlay: ColorRect = null

func _ready() -> void:
	GlobalData.complete_night()
	
	# Determine if we should show paycheck
	var should_show_paycheck = _should_show_paycheck()
	
	if paycheck_panel:
		if not should_show_paycheck:
			paycheck_panel.visible = false
			paycheck_panel.queue_free()  # Don't even keep it
		else:
			paycheck_panel.visible = false  # Will show after delay
	
	if night_label and not GlobalData.is_custom_night:
		night_label.text = "Night %d Complete" % GlobalData.current_night
	elif night_label:
		night_label.text = "Custom Night Complete"
	
	if amount_label:
		amount_label.text = _get_paycheck_amount()
	
	# Create fade overlay and fade in
	_create_fade_and_fade_in()

func _should_show_paycheck() -> bool:
	"""Determine if paycheck should be shown"""
	# Show paycheck for: Custom Night, Night 5, Night 6
	if GlobalData.is_custom_night:
		return true
	if GlobalData.current_night == 5 or GlobalData.current_night == 6:
		return true
	return false

func _create_fade_and_fade_in() -> void:
	"""Create black overlay and fade in from black"""
	# Create overlay starting at full black
	fade_overlay = ColorRect.new()
	fade_overlay.color = Color(0, 0, 0, 1)  # Start fully black
	fade_overlay.mouse_filter = Control.MOUSE_FILTER_IGNORE
	fade_overlay.z_index = 1000  # Above everything
	
	# Make it fill the screen
	fade_overlay.anchor_right = 1.0
	fade_overlay.anchor_bottom = 1.0
	
	add_child(fade_overlay)
	
	# Fade from black to transparent IMMEDIATELY (no wait)
	var tween = create_tween()
	tween.tween_property(fade_overlay, "color:a", 0.0, fade_in_duration).from(1.0)
	tween.finished.connect(_on_fade_in_complete)
	
	print("[NightComplete] Fading in from black...")

func _on_fade_in_complete() -> void:
	"""Clean up fade overlay after fade-in completes"""
	if fade_overlay:
		fade_overlay.queue_free()
		fade_overlay = null
	print("[NightComplete] Fade-in complete")

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
	
	# Show paycheck after delay (only if it should be shown)
	if not paycheck_shown and timer >= paycheck_delay and _should_show_paycheck():
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

#func _input(event: InputEvent) -> void:
	## Allow skipping with any key/click
	#if event is InputEventMouseButton or event is InputEventKey:
		#if event.is_pressed():
			#_return_to_menu()
