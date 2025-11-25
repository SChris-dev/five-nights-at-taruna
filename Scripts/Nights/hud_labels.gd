extends CanvasLayer

# UI element paths
@export var power_label_path: NodePath
@export var hour_label_path: NodePath
@export var debug_left_path: NodePath  # Will be removed
@export var debug_right_path: NodePath  # Will be removed

# FNAF 1 style formatting options
@export_group("Display Settings")
@export var show_power_usage: bool = true  # Show "Usage X" after power percent
@export var show_debug_labels: bool = false  # Toggle debug labels on/off

var power_label: Label
var hour_label: Label
var debug_left: Label
var debug_right: Label

func _ready() -> void:
	power_label = get_node(power_label_path) if power_label_path != NodePath("") else null
	hour_label = get_node(hour_label_path) if hour_label_path != NodePath("") else null
	debug_left = get_node(debug_left_path) if debug_left_path != NodePath("") else null
	debug_right = get_node(debug_right_path) if debug_right_path != NodePath("") else null
	
	# Hide debug labels if disabled
	if not show_debug_labels:
		if debug_left:
			debug_left.visible = false
		if debug_right:
			debug_right.visible = false

func set_power(power_percent: int, usage_level: int) -> void:
	if power_label:
		if show_power_usage:
			# FNAF 1 style: "XX% | Usage X"
			power_label.text = "%d%%  |  Usage %d" % [power_percent, usage_level]
		else:
			# Simple style: "Power: XX%"
			power_label.text = "Power: %d%%" % power_percent

func set_hour(hour_label_text: String, minute: int = 0) -> void:
	if hour_label:
		# Just display the formatted time (already includes WIB)
		hour_label.text = hour_label_text

func set_debug(left_door_closed: bool, right_door_closed: bool, left_light_on: bool, right_light_on: bool) -> void:
	if not show_debug_labels:
		return
		
	if debug_left:
		debug_left.text = str("L Door:", ("Closed" if left_door_closed else "Open"), " | L Light:", ("On" if left_light_on else "Off"))
	if debug_right:
		debug_right.text = str("R Door:", ("Closed" if right_door_closed else "Open"), " | R Light:", ("On" if right_light_on else "Off"))
