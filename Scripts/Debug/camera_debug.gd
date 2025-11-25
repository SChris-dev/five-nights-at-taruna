extends Control

# Visual debug overlay for camera system
# Shows which anomalies are in which rooms

@export var camera_manager: Node  # Reference to CameraElements
@export var enabled: bool = true  # Toggle debug display

var debug_label: Label

func _ready() -> void:
	if not enabled:
		visible = false
		return
	
	# Create debug label
	debug_label = Label.new()
	debug_label.position = Vector2(10, 100)
	debug_label.add_theme_font_size_override("font_size", 12)
	add_child(debug_label)

func _process(_delta: float) -> void:
	if not enabled or not camera_manager:
		return
	
	_update_debug_display()

func _update_debug_display() -> void:
	if not camera_manager.has("rooms"):
		return
	
	var rooms: Array = camera_manager.rooms
	var debug_text: String = "=== CAMERA DEBUG ===\n\n"
	
	var room_names = [
		"ROOM_01: INST Room",
		"ROOM_02: Upper Hallway",
		"ROOM_03: Outer Auditorium",
		"ROOM_04: School Yard",
		"ROOM_05: The Stairs",
		"ROOM_06: RPL Room",
		"ROOM_07: TKJ Room",
		"ROOM_08: TKR Hallway",
		"ROOM_09: TPM/LAS Hallway",
		"ROOM_10: South Hallway",
		"ROOM_11: North Hallway",
		"ROOM_12: Lower Hallway",
		"ROOM_13: OSIS Room"
	]
	
	var anomaly_names = [
		"INST",
		"TKJ_Roamer",
		"TKR_Sprinter",
		"BigRobot",
		"RPL_Disruptor",
		"TKJ_Drainer"
	]
	
	for i in range(rooms.size()):
		var room_state: Array = rooms[i]
		var anomalies_here: Array[String] = []
		
		for j in range(room_state.size()):
			if room_state[j] != 0:  # Anomaly present
				anomalies_here.append(anomaly_names[j])
		
		if anomalies_here.size() > 0:
			debug_text += room_names[i] + "\n"
			debug_text += "  └─ " + ", ".join(anomalies_here) + "\n"
	
	debug_label.text = debug_text

func toggle_debug() -> void:
	enabled = not enabled
	visible = enabled
