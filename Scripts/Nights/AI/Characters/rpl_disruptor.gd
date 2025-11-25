extends AI

# RPL Camera Disruptor - Static anomaly that breaks cameras
# Stays in ROOM_06 (RPL Room) and periodically disrupts cameras

const ROOM_06 = 6  # RPL Room (never moves) - matches tjp_setup enum

signal camera_disrupted
signal camera_fixed

var disruption_timer: float = 0.0
var base_disruption_interval: float = 15.0  # Base interval at AI 0
var disruption_interval: float = 45.0
var is_disrupted: bool = false
var has_initialized: bool = false

@export var camera_manager: Node  # Reference to CameraElements

func _ready() -> void:
	current_room = ROOM_06
	_calculate_interval()
	disruption_timer = disruption_interval
	
	# Defer visibility update until after Camera initializes the feeds
	call_deferred("_update_visibility")

func _process(delta: float) -> void:
	# Check if AI level was just set (happens after _ready)
	if not has_initialized:
		_update_visibility()
		has_initialized = true
	
	# Completely disabled at AI level 0
	if ai_level == 0:
		return
	
	if not is_disrupted:
		disruption_timer -= delta
		
		if disruption_timer <= 0.0:
			# Check AI level before disrupting
			if has_passed_check():
				_disrupt_camera()
			else:
				print("[RPLDisruptor] Failed AI check (level:", ai_level, ") - next attempt in", disruption_interval, "sec")
				disruption_timer = disruption_interval  # Reset timer

func _update_visibility() -> void:
	"""Update camera visibility based on AI level"""
	print("[RPLDisruptor] _update_visibility called - AI level:", ai_level)
	print("[RPLDisruptor] Character enum value:", character)
	print("[RPLDisruptor] ROOM_06 value:", ROOM_06)
	print("[RPLDisruptor] Current state in camera:", camera.rooms[ROOM_06][character])
	
	if ai_level == 0:
		print("[RPLDisruptor] Setting to ABSENT (not visible)")
		camera.rooms[ROOM_06][character] = State.ABSENT
		print("[RPLDisruptor] After setting - state is:", camera.rooms[ROOM_06][character])
	else:
		print("[RPLDisruptor] Setting to PRESENT (visible) - AI level:", ai_level)
		camera.rooms[ROOM_06][character] = State.PRESENT
		print("[RPLDisruptor] After setting - state is:", camera.rooms[ROOM_06][character])
	
	camera.update_feeds([ROOM_06])

func _calculate_interval() -> void:
	# Calculate disruption interval based on AI level
	# AI 0 = 45 seconds, AI 10 = 30 seconds, AI 20 = 15 seconds
	disruption_interval = base_disruption_interval - (ai_level * 1.5)
	# Clamp to minimum of 10 seconds
	disruption_interval = max(disruption_interval, 10.0)
	print("[RPLDisruptor] AI Level:", ai_level, "| Interval:", disruption_interval, "seconds")


func move_options() -> void:
	# This anomaly never moves
	pass

func _disrupt_camera() -> void:
	# Cause camera glitch/static
	is_disrupted = true
	emit_signal("camera_disrupted")
	
	print("[RPLDisruptor] 🔴 DISRUPTING CAMERAS!")
	
	# Apply heavy static to all cameras (except Room 6)
	if camera_manager and camera_manager.has_method("apply_disruption"):
		camera_manager.apply_disruption()
	else:
		print("[RPLDisruptor] ❌ ERROR: Camera manager missing or no apply_disruption method!")

func fix_camera() -> void:
	# Called when player clicks fix button on ROOM_06 camera
	if is_disrupted:
		is_disrupted = false
		_calculate_interval()  # Recalculate in case AI level changed
		disruption_timer = disruption_interval
		emit_signal("camera_fixed")
		
		print("[RPLDisruptor] ✅ Cameras fixed! Next disruption in:", disruption_interval, "seconds")
		
		# Remove heavy static effect
		if camera_manager and camera_manager.has_method("remove_disruption"):
			camera_manager.remove_disruption()
		else:
			print("[RPLDisruptor] ❌ ERROR: Camera manager missing remove_disruption method!")

func get_disruption_status() -> bool:
	return is_disrupted
