extends Control

# Night selection menu (unlocked nights)

# TODO: Create buttons for each night and connect them to _on_night_button_pressed

func _ready() -> void:
	_update_night_buttons()

func _update_night_buttons() -> void:
	# Enable/disable night buttons based on progress
	for i in range(1, 8):
		var button_name = "Night%dButton" % i
		if has_node(button_name):
			var button = get_node(button_name)
			if i == 7:
				# Custom Night only unlocked after beating Night 6
				button.disabled = GlobalData.nights_completed < 6
			else:
				# Regular nights unlock progressively
				button.disabled = i > GlobalData.max_night_unlocked

func _on_night_button_pressed(night: int) -> void:
	if night == 7:
		# Go to custom night menu
		get_tree().change_scene_to_file("res://Scenes/Menu/custom_night.tscn")
	else:
		# Start the selected night
		GlobalData.start_night(night, false)
		get_tree().change_scene_to_file("res://Scenes/Menu/night_intro.tscn")

func _on_back_pressed() -> void:
	get_tree().change_scene_to_file("res://Scenes/Menu/main_menu.tscn")
