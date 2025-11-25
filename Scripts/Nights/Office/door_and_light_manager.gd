extends Node2D

@export var power_manager: Node
@export var hud: Node
@export var ai_manager: Node  # Reference to check animatronic positions
@export var door_graphics: Node  # Reference to door graphics manager
@export var door_indicator_graphics: Node  # Reference to door indicator graphics manager

var left_door_closed: bool = false
var right_door_closed: bool = false
var left_light_on: bool = false
var right_light_on: bool = false

# Track which animatronics are at doors
var animatronics_at_left_door: Array[String] = []
var animatronics_at_right_door: Array[String] = []

var controls_disabled: bool = false

# Door indicator sprites (OLD - ColorRect placeholders, kept for backwards compatibility)
@onready var inst_indicator: ColorRect = $LeftDoorIndicators/INSTIndicator if has_node("LeftDoorIndicators/INSTIndicator") else null
@onready var tkj_indicator: ColorRect = $RightDoorIndicators/TKJIndicator if has_node("RightDoorIndicators/TKJIndicator") else null

# Light button sprites
@onready var left_light_button: Sprite2D = $"../Buttons/LeftLightButton"
@onready var right_light_button: Sprite2D = $"../Buttons/RightLightButton"

# Light textures
var light_on_texture: Texture2D = preload("res://Graphics/Office/buttons/light_on.png")
var light_off_texture: Texture2D = preload("res://Graphics/Office/buttons/light_off.png")

func _toggle_left_door() -> void:
	if controls_disabled:
		return
	
	left_door_closed = not left_door_closed
	if power_manager:
		power_manager.set_left_door(left_door_closed)
	_update_hud()
	_update_door_indicators()
	_update_door_graphics()
	# TODO: Play door sound effect

func _toggle_right_door() -> void:
	if controls_disabled:
		return
	
	right_door_closed = not right_door_closed
	if power_manager:
		power_manager.set_right_door(right_door_closed)
	_update_hud()
	_update_door_indicators()
	_update_door_graphics()
	# TODO: Play door sound effect

func _toggle_left_light() -> void:
	if controls_disabled:
		return
	
	left_light_on = not left_light_on
	if power_manager:
		power_manager.set_left_light(left_light_on)
	_update_hud()
	_check_light_reveal("left")
	_update_door_indicators()
	_update_light_button_sprites()
	# TODO: Play light sound effect

func _toggle_right_light() -> void:
	if controls_disabled:
		return
	
	right_light_on = not right_light_on
	if power_manager:
		power_manager.set_right_light(right_light_on)
	_update_hud()
	_check_light_reveal("right")
	_update_door_indicators()
	_update_light_button_sprites()
	# TODO: Play light sound effect

func _on_left_door_area_input(_viewport, event, _shape_idx) -> void:
	if event.is_action_pressed("click_left"):
		_toggle_left_door()

func _on_right_door_area_input(_viewport, event, _shape_idx) -> void:
	if event.is_action_pressed("click_left"):
		_toggle_right_door()

func _on_left_light_area_input(_viewport, event, _shape_idx) -> void:
	if event.is_action_pressed("click_left"):
		_toggle_left_light()

func _on_right_light_area_input(_viewport, event, _shape_idx) -> void:
	if event.is_action_pressed("click_left"):
		_toggle_right_light()

func _on_left_door_button_input(_viewport, event, _shape_idx) -> void:
	if event.is_action_pressed("click_left"):
		_toggle_left_door()

func _on_right_door_button_input(_viewport, event, _shape_idx) -> void:
	if event.is_action_pressed("click_left"):
		_toggle_right_door()

func _on_left_light_button_input(_viewport, event, _shape_idx) -> void:
	if event.is_action_pressed("click_left"):
		_toggle_left_light()

func _on_right_light_button_input(_viewport, event, _shape_idx) -> void:
	if event.is_action_pressed("click_left"):
		_toggle_right_light()

func _update_hud() -> void:
	if hud and hud.has_method("set_debug"):
		hud.set_debug(left_door_closed, right_door_closed, left_light_on, right_light_on)

func _check_light_reveal(side: String) -> void:
	# Check if animatronic is at door when light turns on
	var animatronics: Array[String] = []
	
	if side == "left":
		animatronics = animatronics_at_left_door
	else:
		animatronics = animatronics_at_right_door
	
	if animatronics.size() > 0 and ((side == "left" and left_light_on) or (side == "right" and right_light_on)):
		# Show animatronic indicators
		# TODO: Play breathing/ambient sound for that animatronic
		pass

func is_door_closed(side: String) -> bool:
	# Called by AI to check door status
	print("[DoorManager] is_door_closed called for side:", side)
	print("[DoorManager] left_door_closed:", left_door_closed, "right_door_closed:", right_door_closed)
	
	if side == "left":
		var result = left_door_closed
		print("[DoorManager] Returning", result, "for left door")
		return result
	elif side == "right":
		var result = right_door_closed
		print("[DoorManager] Returning", result, "for right door")
		return result
	
	print("[DoorManager] Invalid side:", side)
	return false

func register_animatronic_at_door(character: String, side: String) -> void:
	# Called by AI when animatronic reaches door
	if side == "left" and character not in animatronics_at_left_door:
		animatronics_at_left_door.append(character)
		print("[DoorManager] Registered", character, "at left door")
		_update_door_indicators()
	elif side == "right" and character not in animatronics_at_right_door:
		animatronics_at_right_door.append(character)
		print("[DoorManager] Registered", character, "at right door")
		_update_door_indicators()

func unregister_animatronic_at_door(character: String, side: String) -> void:
	# Called by AI when animatronic leaves door
	if side == "left" and character in animatronics_at_left_door:
		animatronics_at_left_door.erase(character)
		print("[DoorManager] Unregistered", character, "from left door")
		_update_door_indicators()
	elif side == "right" and character in animatronics_at_right_door:
		animatronics_at_right_door.erase(character)
		print("[DoorManager] Unregistered", character, "from right door")
		_update_door_indicators()

func is_camera_up() -> bool:
	# Check if tablet is up
	if has_node("../../TabletElements"):
		var tablet = get_node("../../TabletElements")
		return tablet.is_tablet_up if tablet else false
	return false

func disable_controls() -> void:
	# Called during jumpscares or power out
	controls_disabled = true

func enable_controls() -> void:
	# Re-enable controls
	controls_disabled = false

# Direct setters for power out sequence
func set_left_door(closed: bool) -> void:
	if left_door_closed != closed:
		left_door_closed = closed
		if power_manager:
			power_manager.set_left_door(closed)
		_update_hud()
		_update_door_indicators()
		_update_door_graphics()

func set_right_door(closed: bool) -> void:
	if right_door_closed != closed:
		right_door_closed = closed
		if power_manager:
			power_manager.set_right_door(closed)
		_update_hud()
		_update_door_indicators()
		_update_door_graphics()

func set_left_light(on: bool) -> void:
	if left_light_on != on:
		left_light_on = on
		if power_manager:
			power_manager.set_left_light(on)
		_update_hud()
		_check_light_reveal("left")
		_update_door_indicators()
		_update_light_button_sprites()

func set_right_light(on: bool) -> void:
	if right_light_on != on:
		right_light_on = on
		if power_manager:
			power_manager.set_right_light(on)
		_update_hud()
		_check_light_reveal("right")
		_update_door_indicators()
		_update_light_button_sprites()

func _update_door_indicators() -> void:
	# Update visual indicators for animatronics at doors
	
	# Use new graphics system if available, otherwise fall back to old ColorRect system
	if door_indicator_graphics:
		_update_door_indicators_new()
	else:
		_update_door_indicators_legacy()

func _update_door_indicators_new() -> void:
	# NEW: Use sprite-based indicator system
	
	# LEFT DOOR
	if left_light_on and animatronics_at_left_door.size() > 0:
		# Show indicator for the first animatronic (or you can layer multiple)
		var character = animatronics_at_left_door[0]
		door_indicator_graphics.show_left_indicator(character, left_door_closed)
		print("[DoorManager]", character, "seen at left door | Door closed:", left_door_closed)
	else:
		door_indicator_graphics.hide_left_indicator()
	
	# RIGHT DOOR
	if right_light_on and animatronics_at_right_door.size() > 0:
		# Show indicator for the first animatronic
		var character = animatronics_at_right_door[0]
		door_indicator_graphics.show_right_indicator(character, right_door_closed)
		print("[DoorManager]", character, "seen at right door | Door closed:", right_door_closed)
	else:
		door_indicator_graphics.hide_right_indicator()

func _update_door_indicators_legacy() -> void:
	# OLD: Use ColorRect placeholder system (backwards compatibility)
	
	# LEFT DOOR (INST)
	if inst_indicator:
		if left_light_on:
			var inst_at_left = "INSTAnomaly" in animatronics_at_left_door
			inst_indicator.visible = inst_at_left
			inst_indicator.modulate.a = 0.5 if left_door_closed else 1.0
			if inst_at_left:
				print("[DoorManager] INST seen at left door | Door closed:", left_door_closed)
		else:
			inst_indicator.visible = false

	# RIGHT DOOR (TKJ)
	if tkj_indicator:
		if right_light_on:
			var tkj_at_right = "TKJRoamer" in animatronics_at_right_door
			tkj_indicator.visible = tkj_at_right
			tkj_indicator.modulate.a = 0.5 if right_door_closed else 1.0
			if tkj_at_right:
				print("[DoorManager] TKJ seen at right door | Door closed:", right_door_closed)
		else:
			tkj_indicator.visible = false

func _update_light_button_sprites() -> void:
	# Update light button sprites based on light state
	if left_light_button:
		left_light_button.texture = light_on_texture if left_light_on else light_off_texture
	
	if right_light_button:
		right_light_button.texture = light_on_texture if right_light_on else light_off_texture

func _update_door_graphics() -> void:
	# Update door sprite visibility based on door states
	if door_graphics and door_graphics.has_method("set_left_door_state"):
		door_graphics.set_left_door_state(left_door_closed)
	
	if door_graphics and door_graphics.has_method("set_right_door_state"):
		door_graphics.set_right_door_state(right_door_closed)
	
	# Also update indicator opacity when door state changes
	if door_indicator_graphics and door_indicator_graphics.has_method("update_left_indicator_opacity"):
		door_indicator_graphics.update_left_indicator_opacity(left_door_closed)
	
	if door_indicator_graphics and door_indicator_graphics.has_method("update_right_indicator_opacity"):
		door_indicator_graphics.update_right_indicator_opacity(right_door_closed)
