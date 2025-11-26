extends Node

## Audio Manager
## Centralized system for managing all game audio except jumpscares
## Handles phone calls, ambience, UI sounds, and character audio cues

signal phone_call_started
signal phone_call_ended
signal ambient_sound_played(sound_name: String)

# ===== PHONE CALL SYSTEM =====
@export_group("Phone Call System")
@export var phone_call_night_1: AudioStream
@export var phone_call_night_2: AudioStream
@export var phone_call_night_3: AudioStream
@export var phone_call_night_4: AudioStream
@export var phone_call_night_5: AudioStream
@export var phone_call_night_6: AudioStream
@export var phone_call_night_7: AudioStream
@export var phone_call_delay: float = 3.0  # Delay before phone call starts
@export var phone_call_volume: float = 0.0  # dB

# ===== AMBIENT SOUND SYSTEM =====
@export_group("Ambient Sound System")
@export var ambient_sounds: Array[AudioStream] = []  # Random ambient sounds
@export var ambient_min_interval: float = 10.0  # Minimum time between ambient sounds
@export var ambient_max_interval: float = 30.0  # Maximum time between ambient sounds
@export var ambient_volume: float = -10.0  # dB
@export var ambient_enabled: bool = true

# ===== UI SOUNDS =====
@export_group("UI Sounds")
@export var sound_door_toggle: AudioStream  # Door opening/closing
@export var sound_light_toggle: AudioStream  # Light on/off
@export var sound_camera_open: AudioStream  # Camera tablet opening
@export var sound_camera_close: AudioStream  # Camera tablet closing
@export var sound_camera_switch: AudioStream  # Switching camera feed
@export var sound_button_click: AudioStream  # Generic button click
@export var sound_button_hover: AudioStream  # Button hover
@export var sound_static: AudioStream  # Camera static/glitch
@export var ui_volume: float = -5.0  # dB

# ===== CHARACTER AUDIO CUES =====
@export_group("Character Audio Cues")
@export var character_sounds: Dictionary = {}  # Key: character_name, Value: Array[AudioStream]
@export var character_volume: float = -8.0  # dB

# ===== POWER OUT SEQUENCE =====
@export_group("Power Out Audio")
@export var sound_power_out: AudioStream  # When power runs out
@export var sound_freddy_music_box: AudioStream  # Freddy's music box during power out
@export var power_out_volume: float = -5.0  # dB

# Audio players (created dynamically)
var phone_player: AudioStreamPlayer
var ambient_player: AudioStreamPlayer
var ui_player: AudioStreamPlayer  # For one-shot sounds (doors, buttons, camera)
var light_player: AudioStreamPlayer  # Separate player for looping light sound
var character_player: AudioStreamPlayer
var power_out_player: AudioStreamPlayer
var music_box_player: AudioStreamPlayer

# State tracking
var phone_call_playing: bool = false
var ambient_timer: float = 0.0
var next_ambient_time: float = 0.0

func _ready() -> void:
	_setup_audio_players()
	_randomize_next_ambient_time()
	
	# Start phone call if it's the beginning of a night
	if GlobalData.current_night > 0:
		call_deferred("_start_phone_call")

func _setup_audio_players() -> void:
	"""Create all audio stream players"""
	
	# Phone call player
	phone_player = AudioStreamPlayer.new()
	phone_player.name = "PhonePlayer"
	phone_player.bus = "Master"
	phone_player.volume_db = phone_call_volume
	add_child(phone_player)
	phone_player.finished.connect(_on_phone_call_finished)
	
	# Ambient sound player
	ambient_player = AudioStreamPlayer.new()
	ambient_player.name = "AmbientPlayer"
	ambient_player.bus = "Master"
	ambient_player.volume_db = ambient_volume
	add_child(ambient_player)
	
	# UI sound player (one-shot sounds)
	ui_player = AudioStreamPlayer.new()
	ui_player.name = "UIPlayer"
	ui_player.bus = "Master"
	ui_player.volume_db = ui_volume
	add_child(ui_player)
	
	# Light sound player (looping sounds)
	light_player = AudioStreamPlayer.new()
	light_player.name = "LightPlayer"
	light_player.bus = "Master"
	light_player.volume_db = ui_volume
	add_child(light_player)
	
	# Character sound player
	character_player = AudioStreamPlayer.new()
	character_player.name = "CharacterPlayer"
	character_player.bus = "Master"
	character_player.volume_db = character_volume
	add_child(character_player)
	
	# Power out player
	power_out_player = AudioStreamPlayer.new()
	power_out_player.name = "PowerOutPlayer"
	power_out_player.bus = "Master"
	power_out_player.volume_db = power_out_volume
	add_child(power_out_player)
	
	# Music box player (for Freddy during power out)
	music_box_player = AudioStreamPlayer.new()
	music_box_player.name = "MusicBoxPlayer"
	music_box_player.bus = "Master"
	music_box_player.volume_db = power_out_volume
	add_child(music_box_player)
	
	print("[AudioManager] Audio system initialized")

func _process(delta: float) -> void:
	# Handle ambient sound timer
	if ambient_enabled and not phone_call_playing:
		ambient_timer += delta
		
		if ambient_timer >= next_ambient_time:
			_play_random_ambient()
			ambient_timer = 0.0
			_randomize_next_ambient_time()

# ===== PHONE CALL METHODS =====

func _start_phone_call() -> void:
	"""Start the phone call for the current night"""
	if phone_call_playing:
		return
	
	var night = GlobalData.current_night
	var call_audio: AudioStream = null
	
	# Select the appropriate phone call based on night
	match night:
		1: call_audio = phone_call_night_1
		2: call_audio = phone_call_night_2
		3: call_audio = phone_call_night_3
		4: call_audio = phone_call_night_4
		5: call_audio = phone_call_night_5
		6: call_audio = phone_call_night_6
		7: call_audio = phone_call_night_7
	
	if call_audio:
		await get_tree().create_timer(phone_call_delay).timeout
		play_phone_call(call_audio)
	else:
		print("[AudioManager] No phone call configured for night", night)

func play_phone_call(audio: AudioStream) -> void:
	"""Play a phone call audio"""
	if not phone_player or not audio:
		return
	
	phone_call_playing = true
	phone_player.stream = audio
	phone_player.play()
	emit_signal("phone_call_started")
	print("[AudioManager] Playing phone call")

func stop_phone_call() -> void:
	"""Stop the current phone call"""
	if phone_player and phone_player.playing:
		phone_player.stop()
		phone_call_playing = false
		emit_signal("phone_call_ended")
		print("[AudioManager] Phone call stopped")

func _on_phone_call_finished() -> void:
	phone_call_playing = false
	emit_signal("phone_call_ended")
	print("[AudioManager] Phone call finished")

# ===== AMBIENT SOUND METHODS =====

func _play_random_ambient() -> void:
	"""Play a random ambient sound"""
	if ambient_sounds.is_empty() or not ambient_player:
		return
	
	if ambient_player.playing:
		return  # Don't overlap ambient sounds
	
	var random_sound = ambient_sounds[randi() % ambient_sounds.size()]
	ambient_player.stream = random_sound
	ambient_player.play()
	
	print("[AudioManager] Playing ambient sound")
	emit_signal("ambient_sound_played", str(random_sound))

func _randomize_next_ambient_time() -> void:
	"""Set the next ambient sound time randomly"""
	next_ambient_time = randf_range(ambient_min_interval, ambient_max_interval)

func set_ambient_enabled(enabled: bool) -> void:
	"""Enable or disable ambient sounds"""
	ambient_enabled = enabled
	if not enabled and ambient_player:
		ambient_player.stop()

# ===== UI SOUND METHODS =====

func play_door_sound() -> void:
	"""Play door toggle sound (one-shot)"""
	if sound_door_toggle:
		_play_ui_sound(sound_door_toggle, false)

func play_light_on_sound() -> void:
	"""Start playing light sound (looping)"""
	if sound_light_toggle and light_player:
		# Configure for looping
		light_player.stream = sound_light_toggle
		# Check if the stream supports looping
		if sound_light_toggle is AudioStreamWAV:
			sound_light_toggle.loop_mode = AudioStreamWAV.LOOP_FORWARD
		elif sound_light_toggle is AudioStreamOggVorbis:
			sound_light_toggle.loop = true
		light_player.play()
		print("[AudioManager] Light sound started (looping)")

func play_light_off_sound() -> void:
	"""Stop playing light sound"""
	if light_player and light_player.playing:
		light_player.stop()
		print("[AudioManager] Light sound stopped")

func play_camera_open_sound() -> void:
	"""Play camera opening sound"""
	if sound_camera_open:
		_play_ui_sound(sound_camera_open, false)

func play_camera_close_sound() -> void:
	"""Play camera closing sound"""
	if sound_camera_close:
		_play_ui_sound(sound_camera_close, false)

func play_camera_switch_sound() -> void:
	"""Play camera switch sound"""
	if sound_camera_switch:
		_play_ui_sound(sound_camera_switch, false)

func play_button_click_sound() -> void:
	"""Play button click sound"""
	if sound_button_click:
		_play_ui_sound(sound_button_click, false)

func play_button_hover_sound() -> void:
	"""Play button hover sound"""
	if sound_button_hover:
		_play_ui_sound(sound_button_hover, false)

func play_static_sound() -> void:
	"""Play static/glitch sound"""
	if sound_static:
		_play_ui_sound(sound_static, false)

func _play_ui_sound(audio: AudioStream, wait_for_finish: bool = false) -> void:
	"""Internal method to play UI sounds. Can overlap if wait_for_finish is false."""
	if not ui_player:
		return
	
	# If we should wait and something is playing, don't play
	if wait_for_finish and ui_player.playing:
		return
	
	# For one-shot sounds, just play them (allows overlapping)
	ui_player.stream = audio
	ui_player.play()

# ===== CHARACTER AUDIO CUE METHODS =====

func play_character_sound(character_name: String, sound_index: int = -1) -> void:
	"""Play a character audio cue. If sound_index is -1, play random sound for that character"""
	if not character_sounds.has(character_name):
		print("[AudioManager] No sounds configured for character:", character_name)
		return
	
	var sounds: Array = character_sounds[character_name]
	if sounds.is_empty():
		return
	
	var sound_to_play: AudioStream
	if sound_index >= 0 and sound_index < sounds.size():
		sound_to_play = sounds[sound_index]
	else:
		sound_to_play = sounds[randi() % sounds.size()]
	
	if character_player and sound_to_play:
		character_player.stream = sound_to_play
		character_player.play()
		print("[AudioManager] Playing sound for character:", character_name)

func stop_character_sound() -> void:
	"""Stop any playing character sound"""
	if character_player:
		character_player.stop()

# ===== POWER OUT METHODS =====

func play_power_out_sequence() -> void:
	"""Play the power out sound and start music box"""
	if sound_power_out and power_out_player:
		power_out_player.stream = sound_power_out
		power_out_player.play()
		print("[AudioManager] Playing power out sound")
	
	# Start Freddy's music box after a delay
	if sound_freddy_music_box:
		await get_tree().create_timer(2.0).timeout
		play_freddy_music_box()

func play_freddy_music_box() -> void:
	"""Play Freddy's music box during power out"""
	if sound_freddy_music_box and music_box_player:
		music_box_player.stream = sound_freddy_music_box
		music_box_player.play()
		print("[AudioManager] Playing Freddy's music box")

func stop_music_box() -> void:
	"""Stop Freddy's music box"""
	if music_box_player:
		music_box_player.stop()

# ===== UTILITY METHODS =====

func set_master_volume(volume_db: float) -> void:
	"""Set the master volume"""
	AudioServer.set_bus_volume_db(AudioServer.get_bus_index("Master"), volume_db)

func get_master_volume() -> float:
	"""Get the master volume"""
	return AudioServer.get_bus_volume_db(AudioServer.get_bus_index("Master"))

func is_phone_call_playing() -> bool:
	"""Check if a phone call is currently playing"""
	return phone_call_playing

func is_any_audio_playing() -> bool:
	"""Check if any audio is currently playing"""
	return (phone_player and phone_player.playing) or \
		   (ambient_player and ambient_player.playing) or \
		   (ui_player and ui_player.playing) or \
		   (character_player and character_player.playing) or \
		   (power_out_player and power_out_player.playing) or \
		   (music_box_player and music_box_player.playing)
