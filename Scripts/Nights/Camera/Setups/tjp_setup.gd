extends Camera

enum {
	ROOM_01,  # INST Room - Roaming anomaly starts here
	ROOM_02,  # Upper Hallway
	ROOM_03,  # Outer Auditorium (static)
	ROOM_04,  # School Yard (static)
	ROOM_05,  # The Stairs - INST can pass through here
	ROOM_06,  # RPL Room - Camera disruptor (static)
	ROOM_07,  # TKJ Room - Power drainer + Roaming anomaly
	ROOM_08,  # TKR Hallway - Sprinter (Foxy-like)
	ROOM_09,  # TPM/LAS Hallway - Big robot
	ROOM_10,  # South Hallway (near left door)
	ROOM_11,  # North Hallway (near right door)
	ROOM_12,  # Lower Hallway (sprinter visible)
	ROOM_13   # OSIS Room (audio only)
}

# Room names displayed on camera feeds
const ROOM_NAMES: Array[String] = [
	"Ruang Instalasi",    # ROOM_01
	"Lorong Atas",        # ROOM_02
	"Luar Aula",          # ROOM_03
	"Lapangan Sekolah",   # ROOM_04
	"Pertigaan Tangga",   # ROOM_05
	"LAB RPL",            # ROOM_06
	"LAB TKJ",            # ROOM_07
	"Lorong TKR",         # ROOM_08
	"Lorong TPM/LAS",     # ROOM_09
	"Lorong Selatan",     # ROOM_10
	"Lorong Utara",       # ROOM_11
	"Lorong Bawah",       # ROOM_12
	"Ruang OSIS"          # ROOM_13
]

# Character indices in rooms array
enum Characters {
	INST_ANOMALY,    # 0
	TKJ_ROAMER,      # 1
	TKR_SPRINTER,    # 2
	BIG_ROBOT,       # 3
	RPL_DISRUPTOR,   # 4 (never moves)
	TKJ_DRAINER      # 5 (never moves)
}

# Animation state for TKR sprinter running
var tkr_running_frame: int = 0
var tkr_animation_timer: float = 0.0
var tkr_animation_speed: float = 0.25  # Time between frame changes (seconds)

# Camera disruption state
var is_disrupted: bool = false
var normal_static_alpha: float = 0.235  # Normal static transparency (from animation)
var disrupted_static_alpha: float = 0.95  # Max static when disrupted (barely visible)

@onready var cam_static: AnimatedSprite2D = $CamHUD/CamStatic
@onready var audio_manager = get_node("/root/Nights/AudioManager")

func _ready() -> void:
	super._ready()  # Call parent's _ready to initialize feeds and buttons
	create_room_labels(ROOM_NAMES)  # Create room name labels

func _process(delta: float) -> void:
	# Handle TKR sprinter running animation
	_animate_tkr_sprinter(delta)
	
	# Force heavy static to stay when disrupted (override any animations)
	if is_disrupted:
		if current_feed != ROOM_06:
			# Keep heavy static on all cameras except Room 6
			if cam_static.modulate.a < disrupted_static_alpha - 0.1:  # If animation is trying to reduce it
				cam_static.modulate.a = disrupted_static_alpha
		else:
			# Keep Room 6 at normal static
			if cam_static.modulate.a > normal_static_alpha + 0.1:  # If too high
				cam_static.modulate.a = normal_static_alpha

func _animate_tkr_sprinter(delta: float) -> void:
	# Only animate when TKR is in room 12 (running)
	var tkr_sprinter_here = rooms[ROOM_12][Characters.TKR_SPRINTER] != AI.State.ABSENT

	if tkr_sprinter_here:
		tkr_animation_timer += delta
		if tkr_animation_timer >= tkr_animation_speed:
			tkr_animation_timer = 0.0
			# Advance to next frame, but stop at the last frame (don't loop)
			# Assuming your spritesheet has frames 0 to 15 (16 total frames)
			if tkr_running_frame < 15:  # Stop at frame 15 (last frame)
				tkr_running_frame += 1

			# Update the feed if it's currently showing room 12
			if current_feed == ROOM_12:
				set_feed(ROOM_12)
	else:
		# Reset to first frame when TKR is not in room 12
		tkr_running_frame = 0

func play_static() -> void:
	# If cameras are disrupted, DON'T play animation - manually control static
	if is_disrupted:
		# Stop any running animation first
		animtree["parameters/OneShot/request"] = AnimationNodeOneShot.ONE_SHOT_REQUEST_ABORT
		
		# Instant blackout
		cam_static.modulate.a = 1.0
		
		# Brief pause for visual feedback (0.1 seconds)
		await get_tree().create_timer(0.1).timeout
		
		# Set to heavy static (or normal for Room 6)
		if current_feed != ROOM_06:
			cam_static.modulate.a = disrupted_static_alpha
			print("[Camera] Heavy static set (alpha:", cam_static.modulate.a, ")")
		else:
			cam_static.modulate.a = normal_static_alpha
			print("[Camera] Room 6 - normal static (alpha:", cam_static.modulate.a, ")")
	else:
		# Normal behavior - play the animation
		super.play_static()

func switch_feed(new_feed: int) -> void:
	# Handle camera switching manually to control static effect
	audio_manager.play_camera_switch_sound()
	if current_feed != new_feed:
		# Show blackout/static effect
		play_static()
		
		# Hide old feed, show new feed
		all_feeds[current_feed].visible = false
		all_buttons[current_feed].disabled = false
		all_feeds[new_feed].visible = true
		all_buttons[new_feed].disabled = true
		
		# Notify AI characters about camera view change
		_notify_ai_camera_viewed(current_feed)
		current_feed = new_feed
		_notify_ai_camera_viewed(new_feed)
	elif current_feed == 0:
		# Special case: initial camera setup
		_notify_ai_camera_viewed(current_feed)

func set_feed(feed_to_update: int) -> void:
	var room_state: Array = rooms[feed_to_update]
	var room_feed: Sprite2D = all_feeds[feed_to_update]

	# Check which anomalies are in this room
	var inst_here = room_state[Characters.INST_ANOMALY] != AI.State.ABSENT
	var tkj_roamer_here = room_state[Characters.TKJ_ROAMER] != AI.State.ABSENT
	var tkr_sprinter_here = room_state[Characters.TKR_SPRINTER] != AI.State.ABSENT
	var big_robot_here = room_state[Characters.BIG_ROBOT] != AI.State.ABSENT
	var _rpl_disruptor_here = room_state[Characters.RPL_DISRUPTOR] != AI.State.ABSENT
	var _tkj_drainer_here = room_state[Characters.TKJ_DRAINER] != AI.State.ABSENT

	# Handle each camera feed
	match feed_to_update:
		ROOM_01:  # INST Room
			if inst_here:
				room_feed.frame = 0  # INST Anomaly present
			else:
				room_feed.frame = 1  # Empty

		ROOM_02:  # Upper Hallway
			if inst_here and big_robot_here:
				room_feed.frame = 0  # INST and big robot
			elif big_robot_here:
				room_feed.frame = 1  # big robot only
			elif inst_here:
				room_feed.frame = 2 # inst only
			else:
				room_feed.frame = 3

		ROOM_03:  # Outer Auditorium
			if inst_here and tkj_roamer_here and big_robot_here:
				room_feed.frame = 0  # all of them
			elif inst_here and big_robot_here:
				room_feed.frame = 2 # inst and big robot only
			elif inst_here and tkj_roamer_here:
				room_feed.frame = 3 # INST and tkj only
			elif tkj_roamer_here and big_robot_here:
				room_feed.frame = 1 # tkj and big robot only
			elif big_robot_here:
				room_feed.frame = 6 # big robot only
			elif inst_here:
				room_feed.frame = 4 # inst only
			elif tkj_roamer_here:
				room_feed.frame = 5 # tkj only
			else:
				room_feed.frame = 7 # empty

		ROOM_04:  # School Yard
			if big_robot_here:
				room_feed.frame = 0 # big robot
			else:
				room_feed.frame = 1  # Static room

		ROOM_05:  # The Stairs
			if inst_here and tkj_roamer_here and big_robot_here:
				room_feed.frame = 0  # all of them
			elif inst_here and big_robot_here:
				room_feed.frame = 2 # inst and big robot only
			elif inst_here and tkj_roamer_here:
				room_feed.frame = 3 # INST and tkj only
			elif tkj_roamer_here and big_robot_here:
				room_feed.frame = 1 # tkj and big robot only
			elif big_robot_here:
				room_feed.frame = 6 # big robot only
			elif inst_here:
				room_feed.frame = 4 # inst only
			elif tkj_roamer_here:
				room_feed.frame = 5 # tkj only
			else:
				room_feed.frame = 7 # empty

		ROOM_06:  # RPL Room (Camera Disruptor)
			var disruptor_state = room_state[Characters.RPL_DISRUPTOR]
			if disruptor_state == AI.State.PRESENT:
				room_feed.frame = 1  # Disruptor active (AI level > 0)
			else:
				room_feed.frame = 0  # Empty (AI level 0 or absent)

		ROOM_07:  # TKJ Room (Power Drainer + Roamer)
			var drainer_state = room_state[Characters.TKJ_DRAINER]
			var drainer_active = drainer_state == AI.State.PRESENT
			
			if tkj_roamer_here and drainer_active:
				room_feed.frame = 0  # Both roamer and active drainer
			elif tkj_roamer_here:
				room_feed.frame = 1  # Roamer only (drainer disabled/absent)
			elif drainer_active:
				room_feed.frame = 2  # Only active drainer (AI level > 0)
			else:
				room_feed.frame = 3  # Empty (AI level 0 or both absent)
		
		ROOM_08:
			if tkr_sprinter_here and tkj_roamer_here:
				# Both TKR sprinter and TKJ roamer in room
				var sprinter_state = room_state[Characters.TKR_SPRINTER]
				if sprinter_state == AI.State.PRESENT:
					room_feed.frame = 0  # TKR deactivated + TKJ present
				elif sprinter_state == AI.State.ALT_1:
					room_feed.frame = 1  # TKR standing + TKJ present
				elif sprinter_state == AI.State.ALT_2:
					room_feed.frame = 2  # TKR ready + TKJ present
				else:
					room_feed.frame = 0  # Both visible somehow
			elif tkj_roamer_here:
				room_feed.frame = 6  # TKJ roamer only, TKR gone
			elif tkr_sprinter_here:
				var sprinter_state = room_state[Characters.TKR_SPRINTER]
				if sprinter_state == AI.State.PRESENT:
					room_feed.frame = 3  # Phase 0: Deactivated/Idle
				elif sprinter_state == AI.State.ALT_1:
					room_feed.frame = 4  # Phase 1: Standing
				elif sprinter_state == AI.State.ALT_2:
					room_feed.frame = 5  # Phase 2: Ready to sprint
				else:
					room_feed.frame = 7  # Empty or gone
			else:
				room_feed.frame = 7  # Empty

		ROOM_09:  # TPM/LAS Hallway (Big Robot)
			if big_robot_here:
				room_feed.frame = 0  # Big Robot present
			else:
				room_feed.frame = 1  # Empty

		ROOM_10:  # South Hallway (near left door)
			if inst_here and big_robot_here:
				room_feed.frame = 0
			elif big_robot_here:
				room_feed.frame = 1
			elif inst_here:
				room_feed.frame = 2  # INST Anomaly at door
			else:
				room_feed.frame = 3  # Empty

		ROOM_11:  # North Hallway (near right door)
			if tkj_roamer_here:
				room_feed.frame = 0  # TKJ Roamer here
			else:
				room_feed.frame = 1  # Empty

		ROOM_12:  # Lower Hallway (sprinter visible)
			if tkr_sprinter_here:
				# Use animated frame for running (frames 0, 1, 2)
				room_feed.frame = tkr_running_frame
			else:
				room_feed.frame = 0  # Empty

		ROOM_13:  # OSIS Room (audio only)
			room_feed.frame = 0  # Always shows audio indicator
			# TODO: Play audio cues when anomalies are active

func apply_disruption() -> void:
	# Called by RPL Disruptor when cameras are broken
	print("[Camera] 🔴 CAMERAS DISRUPTED!")
	
	is_disrupted = true
	
	# Disable AnimationTree to stop all animations
	animtree.active = false
	
	# Manually show blackout then heavy static
	cam_static.modulate.a = 1.0
	await get_tree().create_timer(0.15).timeout
	
	if current_feed != ROOM_06:
		cam_static.modulate.a = disrupted_static_alpha
	else:
		cam_static.modulate.a = normal_static_alpha
	
	print("[Camera] ✅ Disruption effect applied! Static locked at:", cam_static.modulate.a)

func remove_disruption() -> void:
	# Called when player fixes cameras in Room 6
	print("[Camera] ✅ Cameras fixed!")
	
	is_disrupted = false
	
	# Re-enable AnimationTree
	animtree.active = true
	
	# Play the blackout animation - it will return to normal static automatically
	play_static()
	
	print("[Camera] Static back to normal - animations restored")
