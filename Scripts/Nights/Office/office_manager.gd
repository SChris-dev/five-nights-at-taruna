extends Node2D

@export var door_manager: Node  # Reference to door_and_light_manager
@export var tablet_manager: Node  # Reference to tablet

@onready var office: Node2D = $Office

func _on_area_2d_input_event(_viewport, event, _shape_idx) -> void:
	# This is just a test function for the Button Example
	if event.is_action_pressed("click_left") and office.can_move:
		print('Button Pressed !')

func is_door_closed(side: String) -> bool:
	# Proxy to door manager
	print("[OfficeManager] is_door_closed called for side:", side)
	
	if door_manager and door_manager.has_method("is_door_closed"):
		var result = door_manager.is_door_closed(side)
		print("[OfficeManager] Door manager returned:", result, "for side:", side)
		return result
	else:
		print("[OfficeManager] No door_manager or missing method!")
		if door_manager:
			print("[OfficeManager] door_manager exists but no is_door_closed method")
		else:
			print("[OfficeManager] door_manager is null!")
	
	return false

func is_camera_up() -> bool:
	# Check if tablet/camera is up
	if tablet_manager:
		return tablet_manager.is_tablet_up
	return false

func disable_controls() -> void:
	# Disable all player controls (during jumpscare or power out)
	if office:
		office.can_move = false
	if door_manager and door_manager.has_method("disable_controls"):
		door_manager.disable_controls()

func enable_controls() -> void:
	# Re-enable player controls
	if office:
		office.can_move = true
	if door_manager and door_manager.has_method("enable_controls"):
		door_manager.enable_controls()

func drain_power_from_foxy() -> void:
	# Foxy's door bang drains power
	if door_manager and door_manager.has_method("drain_power_from_foxy"):
		door_manager.drain_power_from_foxy()
