#extends AI
#
## Foxy - Pirate Cove character with unique behavior
## Different from other animatronics - needs frequent camera checking
## Movement: Pirate Cove (stages) -> West Hall -> Left Door (runs and attacks)
#
## TODO: Update these room indices to match your camera setup
#enum {
	#PIRATE_COVE,     # Starting position (has 3 stages)
	#WEST_HALL_RUN,   # Running down hall (briefly visible)
	#LEFT_DOOR        # Attacks at door
#}
#
#enum FoxyStage {
	#STAGE_1,  # Behind curtain
	#STAGE_2,  # Peeking
	#STAGE_3,  # Leaving
	#RUNNING   # Running down hall
#}
#
#var foxy_stage: int = FoxyStage.STAGE_1
#var camera_checks_on_foxy: int = 0
#var camera_checks_away: int = 0
#var attack_cooldown: float = 0.0
#var cooldown_duration: float = 25.0  # Seconds before Foxy can run again
#
#func _ready() -> void:
	#current_room = PIRATE_COVE
	#door_side = "left"
#
#func _process(delta: float) -> void:
	#if attack_cooldown > 0:
		#attack_cooldown -= delta
#
#func move_options() -> void:
	## Foxy's movement is based on camera usage
	## Checking camera on Pirate Cove delays him
	## Not checking camera makes him progress faster
	#
	#if attack_cooldown > 0:
		#return  # Foxy is on cooldown
	#
	#match foxy_stage:
		#FoxyStage.STAGE_1:
			## Progress to stage 2
			#if has_passed_check():
				#foxy_stage = FoxyStage.STAGE_2
				#move_to(PIRATE_COVE, State.ALT_1, 0)  # Update visual state
		#
		#FoxyStage.STAGE_2:
			## Progress to stage 3
			#if has_passed_check():
				#foxy_stage = FoxyStage.STAGE_3
				#move_to(PIRATE_COVE, State.ALT_2, 0)  # Update visual state
		#
		#FoxyStage.STAGE_3:
			## Foxy leaves to run
			#if has_passed_check():
				#_start_run()
		#
		#FoxyStage.RUNNING:
			## Foxy is already running, handled by _start_run
#
#func _start_run() -> void:
	## Foxy runs down the hall
	#foxy_stage = FoxyStage.RUNNING
	#move_to(WEST_HALL_RUN, State.PRESENT, 1)
	#
	## TODO: Play Foxy running sound here
	#
	## Give player a brief moment to close door (1-2 seconds)
	#await get_tree().create_timer(1.5).timeout
	#_reach_door()
#
#func _reach_door() -> void:
	## Foxy reaches the left door
	#move_to(LEFT_DOOR, State.PRESENT, 1)
	#
	## Check if door is closed
	#if office_manager and office_manager.has_method("is_door_closed"):
		#if office_manager.is_door_closed("left"):
			## Door blocked Foxy - he bangs and leaves
			#_blocked_by_door()
		#else:
			## Door open - jumpscare!
			#trigger_jumpscare()
	#else:
		## No office manager, assume jumpscare
		#trigger_jumpscare()
#
#func _blocked_by_door() -> void:
	## Foxy was blocked by the door
	## TODO: Play door bang sound
	## TODO: Drain extra power (Foxy's door bang drains power)
	#if office_manager and office_manager.has_method("drain_power_from_foxy"):
		#office_manager.drain_power_from_foxy()
	#
	## Reset Foxy to stage 1
	#_reset_to_cove()
#
#func _reset_to_cove() -> void:
	## Foxy returns to Pirate Cove
	#foxy_stage = FoxyStage.STAGE_1
	#move_to(PIRATE_COVE, State.PRESENT, -step)
	#attack_cooldown = cooldown_duration
#
#func on_camera_viewed(cam_room: int) -> void:
	## Called when player views a camera
	## Checking Pirate Cove slows Foxy down
	#if cam_room == PIRATE_COVE:
		#camera_checks_on_foxy += 1
		## Reduce AI effectiveness when checked
		#if foxy_stage < FoxyStage.RUNNING and randf() < 0.15:
			## Small chance to regress
			#foxy_stage = max(foxy_stage - 1, FoxyStage.STAGE_1)
	#else:
		#camera_checks_away += 1
		## Not checking Foxy makes him more aggressive
		#if camera_checks_away > 10 and foxy_stage < FoxyStage.RUNNING:
			## Force progress if ignored too long
			#if has_passed_check():
				#move_options()
			#camera_checks_away = 0
