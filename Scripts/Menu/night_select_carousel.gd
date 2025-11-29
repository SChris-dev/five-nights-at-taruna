extends Control

# Carousel-style night selection menu

var current_night: int = 1
var max_nights: int = 6

# Night data: [title, description, background_image_path]
var night_data: Array = [
	["NIGHT 1", "Malam pertama di sekolah.\nSemua akan baik-baik saja.", "res://Graphics/Menu/night_select/NIGHT_1.png"],
	["NIGHT 2", "Sepertinya aku tidak sendirian.\nTetaplah waspada dan bersiaga.", "res://Graphics/Menu/night_select/NIGHT_2.png"],
	["NIGHT 3", "Kenapa mereka ingin menyerangku?\nUntung saja pintu ini cukup kuat untuk menahan mereka.", "res://Graphics/Menu/night_select/NIGHT_3.png"],
	["NIGHT 4", "Hemat Energi.\nTanpa energi, pintu ini tidak bisa menahan mereka.", "res://Graphics/Menu/night_select/NIGHT_4.png"],
	["NIGHT 5", "Malam terakhirku kerja.\nSemoga gajiku sepadan.", "res://Graphics/Menu/night_select/NIGHT_5.png"],
	["NIGHT 6", "Aku kembali sekali lagi.\nMereka terlihat sangat marah.", "res://Graphics/Menu/night_select/NIGHT_6.png"]
]

# UI References
@onready var night_title: Label = $CarouselContainer/NightCard/MarginContainer/VBoxContainer/NightTitle
@onready var night_description: Label = $CarouselContainer/NightCard/MarginContainer/VBoxContainer/NightDescription
@onready var card_background: TextureRect = $CarouselContainer/NightCard/CardBackground
@onready var night_indicator: Label = $NightIndicator
@onready var left_arrow: Button = $LeftArrow
@onready var right_arrow: Button = $RightArrow
@onready var play_button: Button = $CarouselContainer/NightCard/MarginContainer/VBoxContainer/PlayButton

func _ready() -> void:
	# Start at the highest unlocked night or night 1
	current_night = max(1, min(GlobalData.max_night_unlocked, max_nights))
	_update_display()
	
	# Add hover animations to buttons
	_setup_button_animations()

func _update_display(slide_direction: int = 0) -> void:
	# slide_direction: -1 = left, 0 = none, 1 = right
	
	# Update night info
	var night_index = current_night - 1
	
	# Update indicator immediately (doesn't affect visuals)
	night_indicator.text = "%d / %d" % [current_night, max_nights]
	
	# Update arrow states
	left_arrow.disabled = (current_night <= 1)
	right_arrow.disabled = (current_night >= max_nights)
	
	# Animate card with slide effect (content updates inside animation)
	_animate_card_transition(night_index, slide_direction)

func _animate_card_transition(night_index: int, slide_direction: int) -> void:
	var card = $CarouselContainer/NightCard
	var container = $CarouselContainer
	
	# Get the data for this night
	var title = night_data[night_index][0]
	var description = night_data[night_index][1]
	var bg_path = night_data[night_index][2]
	
	# Check if night is unlocked
	var is_unlocked = (night_index + 1) <= GlobalData.max_night_unlocked
	
	if slide_direction == 0:
		# Initial load - set content immediately then fade in
		night_title.text = title
		night_description.text = description
		
		# Load background image
		if ResourceLoader.exists(bg_path):
			card_background.texture = load(bg_path)
		
		# Update button state
		play_button.disabled = not is_unlocked
		play_button.text = "LOCKED" if not is_unlocked else "PLAY"
		
		# Use self_modulate for panel so it doesn't affect children
		card.self_modulate.a = 0.0
		card_background.modulate.a = 0.0
		
		# Reset modulate on all text elements to ensure they're fully visible
		night_title.modulate = Color(1, 1, 1, 1)
		night_description.modulate = Color(0.8, 0.8, 0.8, 1)  # Slightly gray as designed
		play_button.modulate = Color(1, 1, 1, 1)
		
		var tween = create_tween()
		tween.set_parallel(true)
		tween.set_ease(Tween.EASE_OUT)
		tween.set_trans(Tween.TRANS_CUBIC)
		
		tween.tween_property(card, "self_modulate:a", 1.0, 0.5)
		tween.tween_property(card_background, "modulate:a", 0.25, 0.6).set_delay(0.1)
	else:
		# Slide animation
		var slide_offset = 300 * slide_direction
		
		# Slide out current content
		var tween_out = create_tween()
		tween_out.set_parallel(true)
		tween_out.set_ease(Tween.EASE_IN)
		tween_out.set_trans(Tween.TRANS_BACK)
		
		tween_out.tween_property(card, "position:x", -slide_offset, 0.3)
		tween_out.tween_property(card, "self_modulate:a", 0.0, 0.25)
		tween_out.tween_property(card_background, "modulate:a", 0.0, 0.2)
		
		# Wait for slide out, THEN update content
		await tween_out.finished
		
		# NOW update all content (text, image, button state)
		night_title.text = title
		night_description.text = description
		
		# Load background image
		if ResourceLoader.exists(bg_path):
			card_background.texture = load(bg_path)
		
		# Update button state
		play_button.disabled = not is_unlocked
		play_button.text = "LOCKED" if not is_unlocked else "PLAY"
		
		# Reset modulate on all text elements to ensure they're fully visible
		night_title.modulate = Color(1, 1, 1, 1)
		night_description.modulate = Color(0.8, 0.8, 0.8, 1)  # Slightly gray as designed
		play_button.modulate = Color(1, 1, 1, 1)
		
		# Reset position for slide in
		card.position.x = slide_offset
		
		var tween_in = create_tween()
		tween_in.set_parallel(true)
		tween_in.set_ease(Tween.EASE_OUT)
		tween_in.set_trans(Tween.TRANS_BACK)
		
		tween_in.tween_property(card, "position:x", 0, 0.4)
		tween_in.tween_property(card, "self_modulate:a", 1.0, 0.35)
		tween_in.tween_property(card_background, "modulate:a", 0.25, 0.4).set_delay(0.1)

func _on_left_arrow_pressed() -> void:
	if current_night > 1:
		current_night -= 1
		_update_display(-1)  # Slide left

func _on_right_arrow_pressed() -> void:
	if current_night < max_nights:
		current_night += 1
		_update_display(1)  # Slide right

func _on_play_pressed() -> void:
	if current_night <= GlobalData.max_night_unlocked:
		# Start the selected night
		GlobalData.start_night(current_night, false)
		get_tree().change_scene_to_file("res://Scenes/Menu/night_intro.tscn")

func _on_back_pressed() -> void:
	get_tree().change_scene_to_file("res://Scenes/Menu/main_menu.tscn")

func _setup_button_animations() -> void:
	# Connect hover events for arrow buttons
	left_arrow.mouse_entered.connect(_on_button_hover.bind(left_arrow, true))
	left_arrow.mouse_exited.connect(_on_button_hover.bind(left_arrow, false))
	right_arrow.mouse_entered.connect(_on_button_hover.bind(right_arrow, true))
	right_arrow.mouse_exited.connect(_on_button_hover.bind(right_arrow, false))
	
	# Connect hover events for back button
	var back_button = $BackButton
	if back_button:
		back_button.mouse_entered.connect(_on_button_hover.bind(back_button, true))
		back_button.mouse_exited.connect(_on_button_hover.bind(back_button, false))
	
	# Start pulsing animation for play button
	_start_play_button_pulse()

func _on_button_hover(button: Control, is_hovering: bool) -> void:
	"""Simple hover effect matching main menu style"""
	if button is Button and button.disabled:
		return
	
	# Scale from 1.0 to 1.04 (subtle like main menu's 0.5 to 0.52)
	var target_scale = Vector2(0.52, 0.52) if is_hovering else Vector2(0.5, 0.5)
	var target_modulate = Color(1.2, 1.2, 1.2, 1.0) if is_hovering else Color(1.0, 1.0, 1.0, 1.0)
	
	# Animate scale and brightness
	var tween = create_tween()
	tween.set_parallel(true)
	tween.set_trans(Tween.TRANS_BACK)
	tween.set_ease(Tween.EASE_OUT)
	tween.tween_property(button, "scale", target_scale, 0.2)
	tween.tween_property(button, "modulate", target_modulate, 0.2)

func _start_play_button_pulse() -> void:
	if play_button and not play_button.disabled:
		var tween = create_tween()
		tween.set_loops()
		tween.set_ease(Tween.EASE_IN_OUT)
		tween.set_trans(Tween.TRANS_SINE)
		tween.tween_property(play_button, "scale", Vector2(1.05, 1.05), 1.0)
		tween.tween_property(play_button, "scale", Vector2(1.0, 1.0), 1.0)
