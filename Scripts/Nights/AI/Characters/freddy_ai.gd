#extends AI
#
## Freddy Fazbear - Main antagonist with unique behavior
## Only moves when camera is NOT on him (except at specific locations)
## Movement: Show Stage -> Dining Area -> Restrooms -> Kitchen -> East Hall -> East Hall Corner -> Office
#
## TODO: Update these room indices to match your camera setup
#enum {
	#SHOW_STAGE,      # Starting position
	#DINING_AREA,     # First move
	#RESTROOMS,       # Second move
	#KITCHEN,         # Camera is audio-only, plays laugh
	#EAST_HALL,       # Approaching office
	#EAST_HALL_CORNER,# Right before office (visible on camera)
	#OFFICE           # Inside office (power out or successful entry)
#}
#
#var camera_is_watching: bool = false
#var power_out_mode: bool = false
#var laugh_timer: float = 0.0
#var laugh_interval: float = 5.0
#var office_attack_timer: float = 0.0
#var office_attack_delay: float = 20.0  # Seconds in office before jumpscare
#
#func _ready() -> void:
	#current_room = SHOW_STAGE
	#door_side = "right"
#
#func _process(delta: float) -> void:
	## Handle Freddy's laugh timer
	#if laugh_timer > 0:
		#laugh_timer -= delta
		#if laugh_timer <= 0:
			#_play_laugh()
	#
	## Handle power out mode
	#if power_out_mode:
		#office_attack_timer += delta
		#if office_attack_timer >= office_attack_delay:
			#_power_out_jumpscare()
#
#func move_options() -> void:
	## Freddy only moves when camera is NOT viewing him
	## Exception: East Hall Corner - he can still move
	#
	#if camera_is_watching and current_room != EAST_HALL_CORNER:
		#return  # Freddy doesn't move when watched
	#
	#match step:
		#0:  # At Show Stage
			#if has_passed_check():
				#move_to(DINING_AREA)
				#laugh_timer = laugh_interval
		#
		#1:  # At Dining Area
			#if has_passed_check():
				#move_to(RESTROOMS)
				#laugh_timer = laugh_interval
		#
		#2:  # At Restrooms
			#if has_passed_check():
				#move_to(KITCHEN)
				#laugh_timer = laugh_interval
				## TODO: Play kitchen audio when Freddy is here
		#
		#3:  # At Kitchen
			#if has_passed_check():
				#move_to(EAST_HALL)
				#laugh_timer = laugh_interval
		#
		#4:  # At East Hall
			#if has_passed_check():
				#move_to(EAST_HALL_CORNER)
				#laugh_timer = laugh_interval
		#
		#5:  # At East Hall Corner - final position
			## Freddy attacks from here
			#_attack_from_corner()
		#
		#_:
			#pass
#
#func _attack_from_corner() -> void:
	## Freddy tries to enter office
	## In FNAF 1, he attacks regardless of door state at this point
	## But door closed + no camera up = he can't enter
	#
	#if office_manager and office_manager.has_method("is_door_closed"):
		#var door_closed = office_manager.is_door_closed("right")
		#var camera_up = office_manager.is_camera_up() if office_manager.has_method("is_camera_up") else false
		#
		#if door_closed and not camera_up:
			## Door closed and camera down - safe
			#return
		#
		#if camera_up or not door_closed:
			## Camera is up or door is open - Freddy can enter
			#trigger_jumpscare()
	#else:
		## No office manager, trigger jumpscare
		#trigger_jumpscare()
#
#func on_camera_viewed(cam_room: int, viewing: bool) -> void:
	## Called when player views/leaves a camera
	## Freddy freezes when watched (except at East Hall Corner)
	#if cam_room == current_room:
		#camera_is_watching = viewing
		#if viewing:
			## Play Freddy's laugh when viewed at certain locations
			#if current_room in [DINING_AREA, RESTROOMS, EAST_HALL]:
				#_play_laugh()
#
#func _play_laugh() -> void:
	## TODO: Play Freddy's laugh sound
	## Shorter laugh for close positions, longer for far
	#laugh_timer = laugh_interval
	#pass
#
#func on_power_out() -> void:
	## Called when power runs out
	## Freddy takes control of the office
	#power_out_mode = true
	#office_attack_timer = 0.0
	#move_to(OFFICE, State.PRESENT, 1)
	## TODO: Play Freddy's music box song
	## TODO: Show Freddy's glowing eyes in office
#
#func _power_out_jumpscare() -> void:
	## Jumpscare after power out sequence
	#trigger_jumpscare()
#
#func reset_laugh_timer() -> void:
	## Can be called to reset the laugh interval
	#laugh_timer = laugh_interval
