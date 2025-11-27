extends Node

signal hour_changed(hour_label: String, minute: int)
signal night_won

@export var seconds_per_hour: float = 45.0  # Total seconds for 00:00 to 06:00 (6 hours)
@export var show_minutes: bool = true  # Enable minute display

# 6 AM audio settings
@export_group("6 AM Audio")
@export var bell_chime_sound: AudioStream  # Bell/clock chime sound
@export var cheer_sound: AudioStream  # Children cheering sound (optional)
@export var bell_volume: float = 0.0  # Volume in dB (should be loud and clear)
@export var cheer_volume: float = -5.0  # Volume in dB
@export var cheer_delay: float = 1.0  # Delay before cheer plays after bell

@export_group("Transition Settings")
@export var disable_controls_on_victory: bool = true  # Disable player controls when 6 AM hits
@export var fade_out_duration: float = 2.0  # How long the fade out takes
@export var fade_in_duration: float = 1.0  # How long the fade in takes for next scene
@export var wait_after_sounds: float = 1.5  # Extra wait after sounds before fade
@export var show_time_text: bool = true  # Show "06:00 WIB" text during transition
@export var time_text_size: int = 80  # Font size for time text
@export var time_text_font: Font  # Custom font for time text (optional)

# References to managers for disabling controls
@export var office_manager: Node  # Reference to OfficeManager
@export var tablet_manager: Node  # Reference to TabletManager

var current_hour: int = 0  # 0 = 00:00 WIB, 6 = 06:00 WIB
var current_minute: int = 0  # Current minute within the hour
var elapsed: float = 0.0
var is_done: bool = false

# Transition elements
var fade_overlay: ColorRect = null
var time_label: Label = null

# Calculate how many real seconds = 1 in-game minute
# 89 seconds / 6 hours / 60 minutes = ~0.247 seconds per minute
var seconds_per_minute: float = 0.0

func _ready() -> void:
	# Calculate seconds per minute based on total duration
	# We have 6 hours (00:00 to 06:00) = 360 in-game minutes
	seconds_per_minute = seconds_per_hour / 60.0
	
	# Create fade overlay (hidden initially)
	_create_fade_overlay()
	
	_emit_hour()

func _input(event: InputEvent) -> void:
	# Allow skipping the victory sequence with any key/click
	if is_done and (event is InputEventMouseButton or event is InputEventKey):
		if event.is_pressed():
			print("[NightTimer] Skipping victory sequence...")
			_skip_to_next_scene()

func _create_fade_overlay() -> void:
	"""Create a black overlay for fade-out transition"""
	fade_overlay = ColorRect.new()
	fade_overlay.color = Color(0, 0, 0, 0)  # Start transparent
	fade_overlay.mouse_filter = Control.MOUSE_FILTER_IGNORE
	fade_overlay.z_index = 1000  # Above everything
	
	# Make it fill the screen
	fade_overlay.anchor_right = 1.0
	fade_overlay.anchor_bottom = 1.0
	
	# Create time label (06:00 WIB) on top of fade overlay
	if show_time_text:
		time_label = Label.new()
		time_label.text = "06:00 WIB"
		time_label.add_theme_font_size_override("font_size", time_text_size)
		time_label.add_theme_color_override("font_color", Color(1, 1, 1, 1))  # White color
		
		# Apply custom font if provided
		if time_text_font:
			time_label.add_theme_font_override("font", time_text_font)
		
		time_label.modulate.a = 0.0  # Start transparent (use modulate for fading)
		time_label.horizontal_alignment = HORIZONTAL_ALIGNMENT_CENTER
		time_label.vertical_alignment = VERTICAL_ALIGNMENT_CENTER
		time_label.anchor_right = 1.0
		time_label.anchor_bottom = 1.0
		time_label.mouse_filter = Control.MOUSE_FILTER_IGNORE
		# Add directly to root so z_index works properly
		get_tree().root.add_child(time_label)
		time_label.z_index = 1001  # Above fade overlay
		print("[NightTimer] Time label created")
	
	# Add to root (so it covers everything)
	get_tree().root.add_child(fade_overlay)
	print("[NightTimer] Fade overlay created")

func _process(delta: float) -> void:
	if is_done:
		return
	
	elapsed += delta
	
	# Update minutes
	if show_minutes and elapsed >= seconds_per_minute:
		elapsed -= seconds_per_minute
		current_minute += 1
		
		# Check if hour completed
		if current_minute >= 60:
			current_minute = 0
			current_hour += 1
			
			# Check if night won (reached 6 AM / 06:00 WIB)
			if current_hour >= 6:
				current_hour = 6
				current_minute = 0
				is_done = true
				emit_signal("night_won")
				_emit_hour()
				_handle_night_complete()
				return
		
		_emit_hour()
	elif not show_minutes and elapsed >= seconds_per_hour:
		# Original behavior without minutes
		elapsed = 0.0
		current_hour += 1
		_emit_hour()
		if current_hour >= 6:
			is_done = true
			emit_signal("night_won")
			_handle_night_complete()

func _emit_hour() -> void:
	emit_signal("hour_changed", _hour_label(), current_minute)

func _hour_label() -> String:
	if show_minutes:
		# Format: "00:00 WIB" with leading zeros
		return "%02d:%02d WIB" % [current_hour, current_minute]
	else:
		# Simple hour format
		return "%02d:00 WIB" % current_hour

func _handle_night_complete() -> void:
	# Player won the night!
	print("[NightTimer] 🎉 6 AM REACHED - Night complete!")
	
	# Disable player controls instead of freezing
	if disable_controls_on_victory:
		_disable_player_controls()
		print("[NightTimer] Player controls disabled for victory moment")
	
	# Play 6 AM bell chime
	_play_6am_sounds()
	
	# Calculate total wait time
	var total_wait = cheer_delay + wait_after_sounds
	
	print("[NightTimer] Waiting", total_wait, "seconds for sounds...")
	# Wait for sounds to play
	await get_tree().create_timer(total_wait).timeout
	print("[NightTimer] Sound wait complete!")
	
	# Fade out to black
	print("[NightTimer] Starting fade...")
	await _fade_to_black()
	print("[NightTimer] Fade complete, changing scene...")
	
	# Clean up fade overlay and time label before changing scenes
	print("[NightTimer] Cleaning up overlays...")
	if fade_overlay:
		fade_overlay.queue_free()
		fade_overlay = null
	if time_label:
		time_label.queue_free()
		time_label = null
	print("[NightTimer] Overlays cleaned up")
	
	# Change scene
	get_tree().change_scene_to_file("res://Scenes/Menu/night_complete.tscn")
	print("[NightTimer] Scene change initiated")

func _disable_player_controls() -> void:
	"""Disable player controls for victory moment"""
	# Disable office controls (doors, lights, scrolling)
	if office_manager and office_manager.has_method("disable_controls"):
		office_manager.disable_controls()
	
	# Disable tablet/camera controls
	if tablet_manager and tablet_manager.has_method("disable_controls"):
		tablet_manager.disable_controls()
	
	print("[NightTimer] Player controls disabled")

func _play_6am_sounds() -> void:
	"""Play the 6 AM bell chime and optional cheer sounds"""
	
	# Play bell chime
	if bell_chime_sound:
		var bell_player = AudioStreamPlayer.new()
		bell_player.stream = bell_chime_sound
		bell_player.volume_db = bell_volume
		add_child(bell_player)
		bell_player.play()
		bell_player.finished.connect(func(): bell_player.queue_free())
		print("[NightTimer] 🔔 Playing 6 AM bell chime")
	else:
		print("[NightTimer] No bell chime sound configured")
	
	# Play cheer sound after delay
	if cheer_sound:
		await get_tree().create_timer(cheer_delay).timeout
		var cheer_player = AudioStreamPlayer.new()
		cheer_player.stream = cheer_sound
		cheer_player.volume_db = cheer_volume
		add_child(cheer_player)
		cheer_player.play()
		cheer_player.finished.connect(func(): cheer_player.queue_free())
		print("[NightTimer] 🎊 Playing cheer sound")
	else:
		print("[NightTimer] No cheer sound configured")

func _fade_to_black() -> void:
	"""Smoothly fade to black with time text"""
	if not fade_overlay:
		print("[NightTimer] No fade overlay found")
		return
	
	print("[NightTimer] Starting fade to black...")
	print("[NightTimer] Fade duration:", fade_out_duration, "seconds")
	
	var tween = create_tween()
	tween.set_parallel(true)  # Fade overlay and text at the same time
	
	# Fade overlay to black
	print("[NightTimer] Tweening fade overlay alpha to 1.0")
	tween.tween_property(fade_overlay, "color:a", 1.0, fade_out_duration).from(0.0)
	
	# Fade in time text (if enabled)
	if time_label:
		print("[NightTimer] Tweening time label alpha to 1.0")
		tween.tween_property(time_label, "modulate:a", 1.0, fade_out_duration * 0.7).from(0.0)
	
	print("[NightTimer] Waiting for tween to finish...")
	# Wait for fade to complete
	await tween.finished
	print("[NightTimer] Tween finished!")

func _skip_to_next_scene() -> void:
	"""Skip directly to next scene (called when player presses any key)"""
	# Clean up
	if fade_overlay:
		fade_overlay.queue_free()
	if time_label:
		time_label.queue_free()
	
	# Go to next scene immediately
	get_tree().change_scene_to_file("res://Scenes/Menu/night_complete.tscn")
