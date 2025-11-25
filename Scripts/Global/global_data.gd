extends Node

# Night progression
var current_night: int = 1
var nights_completed: int = 0
var max_night_unlocked: int = 1

# AI difficulty presets for each night (Taruna style)
# Character order: INSTAnomaly, TKJRoamer, TKRSprinter, BigRobot, RPLDisruptor, TKJDrainer
var ai_presets: Dictionary = {
	1: {"inst": 0, "tkj_roamer": 0, "tkr_sprinter": 0, "big_robot": 0, "rpl_disruptor": 0, "tkj_drainer": 0},  # Very easy start
	2: {"inst": 0, "tkj_roamer": 3, "tkr_sprinter": 1, "big_robot": 1, "rpl_disruptor": 0, "tkj_drainer": 0},   # Gentle introduction
	3: {"inst": 1, "tkj_roamer": 0, "tkr_sprinter": 5, "big_robot": 2, "rpl_disruptor": 3, "tkj_drainer": 3},   # TKR gets aggressive
	4: {"inst": 1, "tkj_roamer": 2, "tkr_sprinter": 4, "big_robot": 6, "rpl_disruptor": 5, "tkj_drainer": 4},   # Multiple threats
	5: {"inst": 3, "tkj_roamer": 5, "tkr_sprinter": 7, "big_robot": 5, "rpl_disruptor": 7, "tkj_drainer": 6},   # All become active
	6: {"inst": 4, "tkj_roamer": 10, "tkr_sprinter": 12, "big_robot": 16, "rpl_disruptor": 12, "tkj_drainer": 10}, # Very aggressive
	7: {"inst": 0, "tkj_roamer": 0, "tkr_sprinter": 0, "big_robot": 0, "rpl_disruptor": 0, "tkj_drainer": 0}     # Custom Night - set manually
}

# Custom Night AI levels (for Night 7)
var custom_night_levels: Dictionary = {
	"inst": 20,
	"tkj_roamer": 20,
	"tkr_sprinter": 20,
	"big_robot": 20,
	"rpl_disruptor": 20,
	"tkj_drainer": 20
}

# Game state
var is_custom_night: bool = false
var game_over_reason: String = ""  # Which animatronic caused game over

# Save file path
const SAVE_FILE_PATH: String = "user://fnaf_save.dat"

func _ready() -> void:
	load_progress()

func get_night_ai_levels() -> Dictionary:
	if is_custom_night:
		return custom_night_levels
	return ai_presets.get(current_night, ai_presets[1])

func start_night(night: int, custom: bool = false) -> void:
	current_night = night
	is_custom_night = custom
	game_over_reason = ""

func complete_night() -> void:
	if not is_custom_night:
		nights_completed = max(nights_completed, current_night)
		max_night_unlocked = min(nights_completed + 1, 7)
		save_progress()

func game_over(reason: String = "") -> void:
	game_over_reason = reason

func save_progress() -> void:
	var save_data: Dictionary = {
		"nights_completed": nights_completed,
		"max_night_unlocked": max_night_unlocked
	}
	
	var file = FileAccess.open(SAVE_FILE_PATH, FileAccess.WRITE)
	if file:
		file.store_var(save_data)
		file.close()

func load_progress() -> void:
	if not FileAccess.file_exists(SAVE_FILE_PATH):
		return
	
	var file = FileAccess.open(SAVE_FILE_PATH, FileAccess.READ)
	if file:
		var save_data = file.get_var()
		if save_data is Dictionary:
			nights_completed = save_data.get("nights_completed", 0)
			max_night_unlocked = save_data.get("max_night_unlocked", 1)
		file.close()

func reset_progress() -> void:
	current_night = 1
	nights_completed = 0
	max_night_unlocked = 1
	if FileAccess.file_exists(SAVE_FILE_PATH):
		DirAccess.remove_absolute(SAVE_FILE_PATH)
