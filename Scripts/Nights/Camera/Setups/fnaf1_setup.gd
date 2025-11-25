extends Camera

# FNAF 1 Camera Setup - 11 cameras total
# This is a template for implementing all FNAF 1 cameras

# Camera room enum (11 rooms total)
enum {
	CAM_1A,  # Show Stage (Freddy, Bonnie, Chica start here)
	CAM_1B,  # Dining Area
	CAM_1C,  # Pirate Cove (Foxy's location)
	CAM_2A,  # West Hall
	CAM_2B,  # West Hall Corner
	CAM_3,   # Supply Closet
	CAM_4A,  # East Hall
	CAM_4B,  # East Hall Corner
	CAM_5,   # Backstage
	CAM_6,   # Kitchen (audio only - no visual)
	CAM_7    # Restrooms
}

# Character indices for rooms array
# Ensure this matches your AI character enum
enum Characters {
	FREDDY,
	BONNIE,
	CHICA,
	FOXY
}

func set_feed(feed_to_update: int) -> void:
	var room_state: Array = rooms[feed_to_update]
	var room_feed: Sprite2D = all_feeds[feed_to_update]
	
	# Handle camera feeds based on character positions
	# room_state format: [freddy_state, bonnie_state, chica_state, foxy_state]
	
	match feed_to_update:
		CAM_1A:  # Show Stage
			_set_show_stage_feed(room_feed, room_state)
		
		CAM_1B:  # Dining Area
			_set_dining_area_feed(room_feed, room_state)
		
		CAM_1C:  # Pirate Cove (Foxy special)
			_set_pirate_cove_feed(room_feed, room_state)
		
		CAM_2A:  # West Hall
			_set_west_hall_feed(room_feed, room_state)
		
		CAM_2B:  # West Hall Corner
			_set_west_hall_corner_feed(room_feed, room_state)
		
		CAM_3:  # Supply Closet
			_set_supply_closet_feed(room_feed, room_state)
		
		CAM_4A:  # East Hall
			_set_east_hall_feed(room_feed, room_state)
		
		CAM_4B:  # East Hall Corner
			_set_east_hall_corner_feed(room_feed, room_state)
		
		CAM_5:  # Backstage
			_set_backstage_feed(room_feed, room_state)
		
		CAM_6:  # Kitchen (audio only)
			_set_kitchen_feed(room_feed, room_state)
		
		CAM_7:  # Restrooms
			_set_restrooms_feed(room_feed, room_state)

# Individual camera feed handlers
# TODO: Add your sprite frames based on which animatronics are present

func _set_show_stage_feed(feed: Sprite2D, state: Array) -> void:
	# Show Stage - All 3 start here (Freddy, Bonnie, Chica)
	# Frames: All present, Bonnie gone, Chica gone, Both gone
	var freddy = state[Characters.FREDDY]
	var bonnie = state[Characters.BONNIE]
	var chica = state[Characters.CHICA]
	
	if freddy and bonnie and chica:
		feed.frame = 0  # All present
	elif freddy and bonnie and not chica:
		feed.frame = 1  # Chica gone
	elif freddy and not bonnie and chica:
		feed.frame = 2  # Bonnie gone
	else:
		feed.frame = 3  # Both or all gone

func _set_dining_area_feed(feed: Sprite2D, state: Array) -> void:
	# Dining Area - Freddy, Bonnie, or Chica can be here
	var freddy = state[Characters.FREDDY]
	var bonnie = state[Characters.BONNIE]
	var chica = state[Characters.CHICA]
	
	# TODO: Set frames based on which characters are present
	if not freddy and not bonnie and not chica:
		feed.frame = 0  # Empty
	elif freddy:
		feed.frame = 1  # Freddy present
	elif bonnie:
		feed.frame = 2  # Bonnie present
	elif chica:
		feed.frame = 3  # Chica present

func _set_pirate_cove_feed(feed: Sprite2D, state: Array) -> void:
	# Pirate Cove - Foxy only
	# States: Stage 1 (hidden), Stage 2 (peeking), Stage 3 (leaving), Gone
	var foxy_state = state[Characters.FOXY]
	
	match foxy_state:
		AI.State.ABSENT:
			feed.frame = 3  # Foxy gone
		AI.State.PRESENT:
			feed.frame = 0  # Stage 1 - behind curtain
		AI.State.ALT_1:
			feed.frame = 1  # Stage 2 - peeking
		AI.State.ALT_2:
			feed.frame = 2  # Stage 3 - leaving

func _set_west_hall_feed(feed: Sprite2D, state: Array) -> void:
	# West Hall - Bonnie or Foxy (running)
	var bonnie = state[Characters.BONNIE]
	var foxy = state[Characters.FOXY]
	
	if not bonnie and not foxy:
		feed.frame = 0  # Empty
	elif foxy:
		feed.frame = 1  # Foxy running (briefly visible)
	elif bonnie:
		feed.frame = 2  # Bonnie present

func _set_west_hall_corner_feed(feed: Sprite2D, state: Array) -> void:
	# West Hall Corner - Bonnie only
	var bonnie = state[Characters.BONNIE]
	
	if bonnie:
		feed.frame = 0  # Bonnie staring at camera
	else:
		feed.frame = 1  # Empty

func _set_supply_closet_feed(feed: Sprite2D, state: Array) -> void:
	# Supply Closet - Bonnie only
	var bonnie = state[Characters.BONNIE]
	
	if bonnie:
		feed.frame = 0  # Bonnie present
	else:
		feed.frame = 1  # Empty

func _set_east_hall_feed(feed: Sprite2D, state: Array) -> void:
	# East Hall - Chica or Freddy
	var freddy = state[Characters.FREDDY]
	var chica = state[Characters.CHICA]
	
	if not freddy and not chica:
		feed.frame = 0  # Empty
	elif freddy:
		feed.frame = 1  # Freddy present
	elif chica:
		feed.frame = 2  # Chica present

func _set_east_hall_corner_feed(feed: Sprite2D, state: Array) -> void:
	# East Hall Corner - Chica or Freddy
	var freddy = state[Characters.FREDDY]
	var chica = state[Characters.CHICA]
	
	if not freddy and not chica:
		feed.frame = 0  # Empty
	elif freddy:
		feed.frame = 1  # Freddy staring
	elif chica:
		feed.frame = 2  # Chica staring

func _set_backstage_feed(feed: Sprite2D, state: Array) -> void:
	# Backstage - Bonnie only
	var bonnie = state[Characters.BONNIE]
	
	if bonnie:
		feed.frame = 0  # Bonnie present (with endoskeleton)
	else:
		feed.frame = 1  # Empty (just endoskeleton)

func _set_kitchen_feed(feed: Sprite2D, state: Array) -> void:
	# Kitchen - Audio only (no visual feed)
	# Always shows static/audio only indicator
	feed.frame = 0
	
	# TODO: Play kitchen audio sounds when Chica or Freddy are here
	var freddy = state[Characters.FREDDY]
	var chica = state[Characters.CHICA]
	
	if freddy or chica:
		# Play pots/pans audio
		pass

func _set_restrooms_feed(feed: Sprite2D, state: Array) -> void:
	# Restrooms - Chica or Freddy
	var freddy = state[Characters.FREDDY]
	var chica = state[Characters.CHICA]
	
	if not freddy and not chica:
		feed.frame = 0  # Empty
	elif freddy:
		feed.frame = 1  # Freddy present
	elif chica:
		feed.frame = 2  # Chica present
