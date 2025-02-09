extends "res://Scenes/Damageable/Movable/AI/BasicAI.gd"



# Called when the node enters the scene tree for the first time.
func _ready():
	exp_on_kill_scaler = 0.75
	
	damage_coefs = {'linear': 5, 'pow': 1.35, 'base': 30, 'scaler': 1}
	health_coefs = {'linear': 10, 'pow': 2.35, 'base': 5, 'scaler': 1}
	
	set_level(1)

func _process(delta):
	$Sprite.texture = $Viewport.get_texture()

func _on_Beat_timeout():
	was_hit = false
	# Don't take an action if we're already dead
	if not is_alive:
		return	#Move along the chosen direction
	move_tile(queued_move, 1)
	if check_for_collision(queued_move, 1):
		if randf() < 0.5:
			#Hunt the player
			var is_p1_alive = false
			var is_p2_alive = false
			#Check if either player exists
			if Globals.player_one and is_instance_valid(Globals.player_one) and Globals.player_one.is_alive:
				is_p1_alive = true
			elif Globals.player_two and is_instance_valid(Globals.player_two) and Globals.player_two.is_alive:
				is_p2_alive = true
			#Select the closest target
			var target_player : Player
			if is_p1_alive and is_p2_alive:
				if Globals.player_one.global_position.distance_to(self.global_position) <= Globals.player_two.global_position.distance_to(self.global_position):
					target_player = Globals.player_one
				else:
					target_player = Globals.player_two
			elif is_p1_alive:
				target_player = Globals.player_one
			elif is_p2_alive:
				target_player = Globals.player_two
			#Look for a direction to travel to the target
			if target_player:
				var target_pos = target_player.get_position()
				var dir_to_target = self.position.direction_to(target_pos)
				var primary_dir = Vector2.RIGHT
				var secondary_dir = Vector2.LEFT
				if abs(dir_to_target.x) > abs(dir_to_target.y):
					primary_dir = sign(dir_to_target.x) * Vector2.RIGHT
					secondary_dir = sign(dir_to_target.y) * Vector2.DOWN
				elif abs(dir_to_target.x) < abs(dir_to_target.y):
					secondary_dir = sign(dir_to_target.x) * Vector2.RIGHT
					primary_dir = sign(dir_to_target.y) * Vector2.DOWN
				var primary_dir_obj = check_for_collision(primary_dir, 1)
				if !primary_dir_obj or primary_dir_obj is Player:
					queued_move = primary_dir
					set_model_facing(queued_move)
					return
				var secondary_dir_obj = check_for_collision(secondary_dir, 1)
				if !secondary_dir_obj or secondary_dir_obj is Player:
					queued_move = secondary_dir
					set_model_facing(queued_move)
					return
		
		#Chosen path is blocked, so find a new direction
		var num_of_dirs = len(DIRECTIONS)
		var selected_dir = randi() % num_of_dirs
		
		for i in range(4):
			#Search for a direction that is not blocked
			selected_dir += i
			if selected_dir >= num_of_dirs:
				selected_dir = 0
			var collision_result = check_for_collision(DIRECTIONS[selected_dir], 1)
			if !collision_result:
				#Found an unblocked direction
				queued_move = DIRECTIONS[selected_dir]
				set_model_facing(queued_move)
				break

func set_model_facing(_direction : Vector2):
	$Viewport/Floater.set_facing(_direction)
