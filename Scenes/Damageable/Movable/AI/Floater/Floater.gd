extends "res://Scenes/Damageable/Movable/AI/BasicAI.gd"

const DIRECTIONS = {0: Vector2.LEFT, 
			1: Vector2.UP,
			2: Vector2.RIGHT,
			3: Vector2.DOWN}

var locked_dir : Vector2

# Called when the node enters the scene tree for the first time.
func _ready():
	damage = 10
	exp_on_kill_scaler = 0.75
	set_level(1)


func _on_Beat_timeout():
	if check_for_collision(locked_dir, 1):
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
					move_tile(primary_dir, 1)
					locked_dir = primary_dir
					return
				var secondary_dir_obj = check_for_collision(secondary_dir, 1)
				if !secondary_dir_obj or secondary_dir_obj is Player:
					move_tile(secondary_dir, 1)
					locked_dir = secondary_dir
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
				locked_dir = DIRECTIONS[selected_dir]
				break
	#Move along the chosen direction
	move_tile(locked_dir, 1)
