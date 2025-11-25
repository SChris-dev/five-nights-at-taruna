extends Node2D
class_name Camera

@export var rooms: Array[Array]

@export var ai_manager: Node  # Reference to the AI manager node

var current_feed: int = 0
var all_feeds: Array[Sprite2D]
var all_buttons: Array[TextureButton]
var room_labels: Array[Label] = []

@onready var animtree: AnimationTree = $AnimationTree

func _ready() -> void:
	_initialize_buttons()
	_initialize_feeds()

func _initialize_buttons() -> void:
	# Adds the camera feeds and buttons into arrays so they can be synced up in 'func _on_click_cam'
	all_feeds.append_array($CamRooms.get_children())
	all_buttons.append_array($CamButtons.get_children())

func _initialize_feeds() -> void:
	# Gets the camera feed id's, then sets them up with the right frame
	update_feeds(type_convert(range(all_feeds.size()), TYPE_PACKED_INT32_ARRAY))
	# Set initial current feed and notify AI characters
	current_feed = 0
	_notify_ai_camera_viewed(current_feed)

func set_feed(_feed_to_update: int) -> void:
	pass

func update_feeds(feeds_to_update: Array[int]) -> void:
	for i in feeds_to_update:
		print("[Camera] Updating feed", i, "(current_feed:", current_feed, ")")
		set_feed(i)
		# Notify AI characters when a feed is viewed/updated
		_notify_ai_camera_viewed(i)
		if current_feed == i:
			print("[Camera] Playing static for current feed", i)
			play_static()

func switch_feed(new_feed: int) -> void:
	# This handles camera switching, but blocks it when clicking the same camera button
	if current_feed != new_feed:
		play_static()

		all_feeds[current_feed].visible = false
		all_buttons[current_feed].disabled = false

		all_feeds[new_feed].visible = true
		all_buttons[new_feed].disabled = true

		# Notify AI characters about camera view change (old feed first, then new feed)
		_notify_ai_camera_viewed(current_feed)
		current_feed = new_feed
		_notify_ai_camera_viewed(new_feed)
	elif current_feed == 0:
		# Special case: initial camera setup, notify about current feed
		_notify_ai_camera_viewed(current_feed)

func open_camera() -> void:
	# Called when player opens the camera system
	_notify_ai_camera_opened()

func close_camera() -> void:
	# Called when player closes the camera system
	_notify_ai_camera_closed()

func _notify_ai_camera_opened() -> void:
	# Notify all AI characters that camera was opened
	if ai_manager:
		for child in ai_manager.get_children():
			if child.has_method("on_camera_opened"):
				child.on_camera_opened()

func _notify_ai_camera_closed() -> void:
	# Notify all AI characters that camera was closed
	if ai_manager:
		for child in ai_manager.get_children():
			if child.has_method("on_camera_closed"):
				child.on_camera_closed()

func _notify_ai_camera_viewed(cam_room: int) -> void:
	# Notify all AI characters that a specific camera was viewed
	if ai_manager:
		for child in ai_manager.get_children():
			if child.has_method("on_camera_viewed"):
				child.on_camera_viewed(cam_room)

func play_static() -> void:
	animtree["parameters/OneShot/request"] = AnimationNodeOneShot.ONE_SHOT_REQUEST_FIRE
	animtree.advance(0) # this fixes a problem where the static plays 1 frame too late

func create_room_labels(room_names: Array[String]) -> void:
	# Create a Label for each camera feed showing the room name
	for i in range(all_feeds.size()):
		if i >= room_names.size():
			break
			
		var label = Label.new()
		label.name = "RoomLabel_" + str(i)
		label.text = room_names[i]
		
		# Style the label
		label.add_theme_font_size_override("font_size", 18)
		label.add_theme_color_override("font_color", Color(0.9, 0.9, 0.9, 0.85))
		label.add_theme_color_override("font_outline_color", Color(0, 0, 0, 1))
		label.add_theme_constant_override("outline_size", 4)
		
		# Position in top-left corner with some padding
		label.position = Vector2(400, 300)
		label.z_index = 20  # Ensure it's above camera feeds
		
		# Add to the camera feed sprite
		all_feeds[i].add_child(label)
		room_labels.append(label)
	
	print("[Camera] Created ", room_labels.size(), " room name labels")
