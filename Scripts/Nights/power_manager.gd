extends Node

signal power_changed(power_percent: int, usage_level: int)
signal power_out

@export_group("Drain Settings (per second)")
@export var passive_drain: float = 0.1
@export var tablet_drain: float = 0.1
@export var door_left_drain: float = 0.2
@export var door_right_drain: float = 0.2
@export var light_left_drain: float = 0.1
@export var light_right_drain: float = 0.1

@export_group("Setup")
@export var max_power: int = 100
@export var tablet_manager: Node
@export var power_out_sequence: Node  # Reference to PowerOutSequence node

var current_power: float
var last_reported_percent: int
var is_out: bool = false
var left_door_closed: bool = false
var right_door_closed: bool = false
var left_light_on: bool = false
var right_light_on: bool = false

func _ready() -> void:
	current_power = float(max_power)
	last_reported_percent = 100
	_emit_change()

func _process(delta: float) -> void:
	if is_out:
		return
	var _usage_level: int = _compute_usage_level()
	var drain: float = passive_drain
	if tablet_manager and tablet_manager.is_tablet_up:
		drain += tablet_drain
	if left_door_closed:
		drain += door_left_drain
	if right_door_closed:
		drain += door_right_drain
	if left_light_on:
		drain += light_left_drain
	if right_light_on:
		drain += light_right_drain
	# Doors/lights will be added later and can increase drain here
	current_power = max(current_power - drain * delta, 0.0)
	var percent: int = int(round((current_power / float(max_power)) * 100.0))
	if percent != last_reported_percent:
		last_reported_percent = percent
		_emit_change()
	if current_power <= 0.0 and not is_out:
		is_out = true
		_trigger_power_out()

func _compute_usage_level() -> int:
	var level: int = 0
	if tablet_manager and tablet_manager.is_tablet_up:
		level += 1
	if left_door_closed:
		level += 1
	if right_door_closed:
		level += 1
	if left_light_on:
		level += 1
	if right_light_on:
		level += 1
	return level

func _emit_change() -> void:
	var usage_level: int = _compute_usage_level()
	emit_signal("power_changed", last_reported_percent, usage_level)

func set_left_door(closed: bool) -> void:
	left_door_closed = closed
	_emit_change()

func set_right_door(closed: bool) -> void:
	right_door_closed = closed
	_emit_change()

func set_left_light(on: bool) -> void:
	left_light_on = on
	_emit_change()

func set_right_light(on: bool) -> void:
	right_light_on = on
	_emit_change()

func drain_power(amount: float) -> void:
	# Direct power drain (e.g., from Foxy's door bang)
	current_power = max(current_power - amount, 0.0)
	var percent: int = int(round((current_power / float(max_power)) * 100.0))
	if percent != last_reported_percent:
		last_reported_percent = percent
		_emit_change()
	if current_power <= 0.0 and not is_out:
		is_out = true
		_trigger_power_out()

func _trigger_power_out() -> void:
	# Power has run out - trigger power out sequence
	emit_signal("power_out")
	_emit_change()
	
	print("[PowerManager] 💀 Power depleted! Starting power out sequence...")
	
	# Disable all doors and lights immediately
	left_door_closed = false
	right_door_closed = false
	left_light_on = false
	right_light_on = false
	
	# Start the power out sequence
	if power_out_sequence and power_out_sequence.has_method("start_sequence"):
		power_out_sequence.start_sequence()
	else:
		print("[PowerManager] ERROR: No PowerOutSequence found! Falling back to immediate game over.")
		# Fallback: immediate jumpscare if no sequence manager
		var jumpscare_manager = get_node_or_null("../JumpscareManager")
		if jumpscare_manager and jumpscare_manager.has_method("trigger_jumpscare"):
			jumpscare_manager.trigger_jumpscare("BigRobot")
