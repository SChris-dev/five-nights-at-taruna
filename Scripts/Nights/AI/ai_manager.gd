extends Node

# Manual level overrides (for testing)
@export var use_manual_levels: bool = false

# FNAF 1 Characters
@export_range(0, 20) var freddy_level: int = 0
@export_range(0, 20) var bonnie_level: int = 0
@export_range(0, 20) var chica_level: int = 0
@export_range(0, 20) var foxy_level: int = 0

# Legacy Characters
@export_range(0, 20) var red_level: int = 0
@export_range(0, 20) var green_level: int = 0

# Taruna Anomalies
@export_range(0, 20) var inst_level: int = 0
@export_range(0, 20) var tkj_roamer_level: int = 0
@export_range(0, 20) var tkr_sprinter_level: int = 0
@export_range(0, 20) var big_robot_level: int = 0
@export_range(0, 20) var rpl_disruptor_level: int = 0
@export_range(0, 20) var tkj_drainer_level: int = 0

func _ready() -> void:
	randomize() # Sets new RNG seed
	_initialize_char_levels()

func _initialize_char_levels() -> void:
	var levels: Dictionary
	
	if use_manual_levels:
		# Use manually set levels (for testing)
		levels = {
			"freddy": freddy_level,
			"bonnie": bonnie_level,
			"chica": chica_level,
			"foxy": foxy_level
		}
	else:
		# Load from GlobalData based on current night
		levels = GlobalData.get_night_ai_levels()
	
	# Apply to FNAF 1 characters (if they exist)
	if has_node("Freddy"):
		$Freddy.ai_level = levels.get("freddy", 0)
	if has_node("Bonnie"):
		$Bonnie.ai_level = levels.get("bonnie", 0)
	if has_node("Chica"):
		$Chica.ai_level = levels.get("chica", 0)
	if has_node("Foxy"):
		$Foxy.ai_level = levels.get("foxy", 0)
	
	# Legacy characters (Red/Green)
	if has_node("Red"):
		$Red.ai_level = red_level
	if has_node("Green"):
		$Green.ai_level = green_level
	
	# Taruna Anomalies
	if use_manual_levels:
		# Use manual levels from inspector
		if has_node("INSTAnomaly"):
			$INSTAnomaly.ai_level = inst_level
		if has_node("TKJRoamer"):
			$TKJRoamer.ai_level = tkj_roamer_level
		if has_node("TKRSprinter"):
			$TKRSprinter.ai_level = tkr_sprinter_level
		if has_node("BigRobot"):
			$BigRobot.ai_level = big_robot_level
		if has_node("RPLDisruptor"):
			$RPLDisruptor.ai_level = rpl_disruptor_level
		if has_node("TKJDrainer"):
			$TKJDrainer.ai_level = tkj_drainer_level
	else:
		# Load from GlobalData preset
		if has_node("INSTAnomaly"):
			$INSTAnomaly.ai_level = levels.get("inst", 0)
		if has_node("TKJRoamer"):
			$TKJRoamer.ai_level = levels.get("tkj_roamer", 0)
		if has_node("TKRSprinter"):
			$TKRSprinter.ai_level = levels.get("tkr_sprinter", 0)
		if has_node("BigRobot"):
			$BigRobot.ai_level = levels.get("big_robot", 0)
		if has_node("RPLDisruptor"):
			$RPLDisruptor.ai_level = levels.get("rpl_disruptor", 0)
		if has_node("TKJDrainer"):
			$TKJDrainer.ai_level = levels.get("tkj_drainer", 0)
	
	print("[AIManager] AI Levels Set:")
	print("  INST:", levels.get("inst", inst_level) if not use_manual_levels else inst_level)
	print("  TKJ Roamer:", levels.get("tkj_roamer", tkj_roamer_level) if not use_manual_levels else tkj_roamer_level)
	print("  TKR Sprinter:", levels.get("tkr_sprinter", tkr_sprinter_level) if not use_manual_levels else tkr_sprinter_level)
	print("  Big Robot:", levels.get("big_robot", big_robot_level) if not use_manual_levels else big_robot_level)
	print("  RPL Disruptor:", levels.get("rpl_disruptor", rpl_disruptor_level) if not use_manual_levels else rpl_disruptor_level)
	print("  TKJ Drainer:", levels.get("tkj_drainer", tkj_drainer_level) if not use_manual_levels else tkj_drainer_level)
