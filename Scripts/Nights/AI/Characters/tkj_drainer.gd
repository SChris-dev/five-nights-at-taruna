extends AI

# TKJ Power Drainer - Static anomaly that drains extra power
# Stays in ROOM_07 (TKJ Room) and increases power drain

const ROOM_07 = 7  # TKJ Room (never moves) - matches tjp_setup enum

signal power_drain_active
signal power_drain_stopped

var is_draining: bool = false
var drain_timer: float = 0.0
var base_drain_interval: float = 40.0  # Base interval at AI 0
var drain_interval: float = 40.0
var base_drain_rate: float = 0.5  # Base drain rate
var extra_drain_rate: float = 0.5  # Calculated based on AI level
var has_initialized: bool = false

@export var power_manager: Node  # Reference to PowerManager

func _ready() -> void:
	current_room = ROOM_07
	_calculate_drain_values()
	drain_timer = drain_interval
	
	# Defer visibility update until after Camera initializes the feeds
	call_deferred("_update_visibility")

func _update_visibility() -> void:
	"""Update camera visibility based on AI level"""
	print("[TKJDrainer] _update_visibility called - AI level:", ai_level)
	print("[TKJDrainer] Character enum value:", character)
	print("[TKJDrainer] ROOM_07 value:", ROOM_07)
	print("[TKJDrainer] Current state in camera:", camera.rooms[ROOM_07][character])
	
	if ai_level == 0:
		print("[TKJDrainer] Setting to ABSENT (not visible)")
		camera.rooms[ROOM_07][character] = State.ABSENT
		print("[TKJDrainer] After setting - state is:", camera.rooms[ROOM_07][character])
	else:
		print("[TKJDrainer] Setting to PRESENT (visible) - AI level:", ai_level)
		camera.rooms[ROOM_07][character] = State.PRESENT
		print("[TKJDrainer] After setting - state is:", camera.rooms[ROOM_07][character])
	
	camera.update_feeds([ROOM_07])

func _calculate_drain_values() -> void:
	# Calculate drain interval and rate based on AI level
	# AI 0 = 40 seconds interval, 0.5% drain/sec
	# AI 10 = 25 seconds interval, 1.0% drain/sec
	# AI 20 = 10 seconds interval, 1.5% drain/sec
	drain_interval = base_drain_interval - (ai_level * 1.5)
	drain_interval = max(drain_interval, 8.0)  # Min 8 seconds
	
	extra_drain_rate = base_drain_rate + (ai_level * 0.05)
	print("[TKJDrainer] AI Level:", ai_level, "| Interval:", drain_interval, "sec | Drain rate:", extra_drain_rate, "%/sec")

func _process(delta: float) -> void:
	# Check if AI level was just set (happens after _ready)
	if not has_initialized:
		_update_visibility()
		has_initialized = true
	
	# Completely disabled at AI level 0
	if ai_level == 0:
		return
	
	if not is_draining:
		drain_timer -= delta
		if drain_timer <= 0.0:
			# Check AI level before starting drain
			if has_passed_check():
				_start_draining()
			else:
				print("[TKJDrainer] Failed AI check - no drain this time")
				drain_timer = drain_interval  # Reset timer
	else:
		# Apply extra power drain
		if power_manager and power_manager.has_method("drain_power"):
			power_manager.drain_power(extra_drain_rate * delta)

func move_options() -> void:
	# This anomaly never moves
	pass

func _start_draining() -> void:
	is_draining = true
	emit_signal("power_drain_active")
	
	# TODO: Show warning indicator
	print("TKJ Drainer is draining power! Fix it quickly!")

func fix_power_drain() -> void:
	# Called when player clicks fix button on ROOM_07 camera
	if is_draining:
		is_draining = false
		_calculate_drain_values()  # Recalculate in case AI level changed
		drain_timer = drain_interval
		emit_signal("power_drain_stopped")
		
		print("[TKJDrainer] Power drain fixed! Next drain in:", drain_interval, "seconds")

func get_drain_status() -> bool:
	return is_draining
