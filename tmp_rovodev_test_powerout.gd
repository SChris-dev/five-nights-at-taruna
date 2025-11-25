extends Node

## Quick Power Out Tester
## Attach this to a node in your nights scene to test power out with a hotkey

@export var power_manager_path: NodePath = ""
@export var power_out_sequence_path: NodePath = ""

var power_manager: Node = null
var power_out_sequence: Node = null

func _ready() -> void:
	# Find the managers
	if power_manager_path:
		power_manager = get_node(power_manager_path)
	else:
		power_manager = get_node_or_null("/root/Nights/PowerManager")
		if not power_manager:
			power_manager = get_tree().root.find_child("PowerManager", true, false)
	
	if power_out_sequence_path:
		power_out_sequence = get_node(power_out_sequence_path)
	else:
		power_out_sequence = get_node_or_null("/root/Nights/PowerOutSequence")
		if not power_out_sequence:
			power_out_sequence = get_tree().root.find_child("PowerOutSequence", true, false)
	
	if power_manager:
		print("[PowerOut Tester] ✓ PowerManager found")
	else:
		print("[PowerOut Tester] ✗ PowerManager NOT found!")
	
	if power_out_sequence:
		print("[PowerOut Tester] ✓ PowerOutSequence found")
		_check_sequence_setup()
	else:
		print("[PowerOut Tester] ✗ PowerOutSequence NOT found!")
	
	print("[PowerOut Tester] Ready! Press P to trigger power out, or K to drain power to 1%")

func _check_sequence_setup() -> void:
	print("[PowerOut Tester] Checking PowerOutSequence setup...")
	
	var checks = {
		"office_manager_path": power_out_sequence.office_manager_path,
		"tablet_manager_path": power_out_sequence.tablet_manager_path,
		"ai_manager_path": power_out_sequence.ai_manager_path,
		"jumpscare_manager_path": power_out_sequence.jumpscare_manager_path,
		"camera_manager_path": power_out_sequence.camera_manager_path,
		"door_manager_path": power_out_sequence.door_manager_path,
		"hud_path": power_out_sequence.hud_path,
		"door_graphics_path": power_out_sequence.door_graphics_path,
	}
	
	for key in checks:
		var path = checks[key]
		if path and path != NodePath(""):
			print("[PowerOut Tester]   ✓", key, "= ", path)
		else:
			print("[PowerOut Tester]   ✗", key, "NOT SET!")
	
	if power_out_sequence.music_clip:
		print("[PowerOut Tester]   ✓ music_clip is set")
	else:
		print("[PowerOut Tester]   ⚠ music_clip NOT set (optional)")

func _input(event: InputEvent) -> void:
	if event is InputEventKey and event.is_pressed():
		if event.keycode == KEY_P:
			_test_power_out()
		elif event.keycode == KEY_K:
			_drain_power_to_almost_zero()

func _test_power_out() -> void:
	if not power_out_sequence:
		print("[PowerOut Tester] ERROR: No PowerOutSequence found!")
		return
	
	print("[PowerOut Tester] =====================")
	print("[PowerOut Tester] TRIGGERING POWER OUT!")
	print("[PowerOut Tester] =====================")
	
	if power_out_sequence.has_method("start_sequence"):
		power_out_sequence.start_sequence()
	else:
		print("[PowerOut Tester] ERROR: PowerOutSequence doesn't have start_sequence method!")

func _drain_power_to_almost_zero() -> void:
	if not power_manager:
		print("[PowerOut Tester] ERROR: No PowerManager found!")
		return
	
	print("[PowerOut Tester] Draining power to 1%...")
	
	if power_manager.has_method("drain_power"):
		var current_power = power_manager.current_power
		var drain_amount = current_power - 1.0  # Leave 1% remaining
		power_manager.drain_power(drain_amount)
		print("[PowerOut Tester] Power drained! Current power:", power_manager.current_power)
	else:
		print("[PowerOut Tester] ERROR: PowerManager doesn't have drain_power method!")
