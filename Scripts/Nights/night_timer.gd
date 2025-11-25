extends Node

signal hour_changed(hour_label: String, minute: int)
signal night_won

@export var seconds_per_hour: float = 89.0  # Total seconds for 00:00 to 06:00 (6 hours)
@export var show_minutes: bool = true  # Enable minute display

var current_hour: int = 0  # 0 = 00:00 WIB, 6 = 06:00 WIB
var current_minute: int = 0  # Current minute within the hour
var elapsed: float = 0.0
var is_done: bool = false

# Calculate how many real seconds = 1 in-game minute
# 89 seconds / 6 hours / 60 minutes = ~0.247 seconds per minute
var seconds_per_minute: float = 0.0

func _ready() -> void:
	# Calculate seconds per minute based on total duration
	# We have 6 hours (00:00 to 06:00) = 360 in-game minutes
	seconds_per_minute = seconds_per_hour / 60.0
	_emit_hour()

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
	# TODO: Play 6 AM chime sound
	
	# Wait a moment then transition to night complete screen
	await get_tree().create_timer(2.0).timeout
	get_tree().change_scene_to_file("res://Scenes/Menu/night_complete.tscn")
