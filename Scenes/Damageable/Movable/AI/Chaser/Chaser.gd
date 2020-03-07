extends "res://Scenes/Damageable/Movable/AI/BasicAI.gd"


var player1 = null
var player2 = null

const BEAT_CYCLE = 2

var beat_counter = 0

var dirs = {0: Vector2.LEFT, 
			1: Vector2.UP,
			2: Vector2.RIGHT,
			3: Vector2.DOWN}

# Called when the node enters the scene tree for the first time.
func _ready():
	exp_on_kill_scaler = 0.85
	
	damage_coefs = {'linear': 4, 'pow': 1.25, 'base': 15, 'scaler': 1}
	health_coefs = {'linear': 15, 'pow': 2.5, 'base': 15, 'scaler': 1}
	
	set_level(1)

func _process(delta):
	$Sprite.texture = $Viewport.get_texture()

func _on_Beat_timeout():
	# Don't take an action if we're already dead
	was_hit = false
	
	if not is_alive:
		return
	
	if not beat_counter % BEAT_CYCLE:
		var target_player = null
		var my_pos = get_position()
		# find the closest player
		if player1 and player2:
			var dist_to_player1 = (player1.get_position() - my_pos).length()
			var dist_to_player2 = (player2.get_position() - my_pos).length()
			if dist_to_player1 < dist_to_player2:
				target_player = player1
			else:
				target_player = player2
		elif player1:
			target_player = player1
		elif player2:
			target_player = player2
		else:
			pass # Do nothing
		if target_player:
			var target_pos = target_player.get_position()
			var dir_to_target = my_pos.direction_to(target_pos)
			var selected_dir = Vector2.ZERO
			#print("Dir to tar" + str(dir_to_target))
			
			if abs(dir_to_target.x) > abs(dir_to_target.y):
				selected_dir = sign(dir_to_target.x) * Vector2.RIGHT
			elif abs(dir_to_target.x) < abs(dir_to_target.y):
				selected_dir = sign(dir_to_target.y) * Vector2.DOWN
			else:
				# add rand_mover to most likely force a move if the dir is zero
				var rand_mover = rand_range(-0.001, 0.001)
				if randi() % 2:
					selected_dir = sign(dir_to_target.x+rand_mover) * Vector2.RIGHT
				else:
					selected_dir = sign(dir_to_target.y+rand_mover) * Vector2.DOWN
			#print("Init dir: " + str(selected_dir))
			
			# Check if we are going to collide with something
			var space_state = get_world_2d().direct_space_state
			var move_pos = my_pos + selected_dir * tilesize
			var result = space_state.intersect_ray(my_pos, move_pos, [self], 
			MOVEMENT_COLLISION_MASK, true, true)
			if result:
				# if we're going to hit the player, actually do it
				
				if not result['collider'].get_collision_mask() == PLAYER_COL_MASK:
					# if we were going to hit a wall, move on the opposite axis
					var rand_mover = rand_range(-0.001, 0.001)
					# add rand_mover to most likely force a move if the dir is zero
					if selected_dir.x == 0:
						selected_dir = sign(dir_to_target.x+rand_mover) * Vector2.RIGHT
					else:
						selected_dir = sign(dir_to_target.y+rand_mover) * Vector2.DOWN
			# make the  move
			move_tile(selected_dir, 1)
			set_model_facing(selected_dir)
	beat_counter = (beat_counter + 1) % BEAT_CYCLE

func _on_Area2D_area_entered(area):
	if not player1:
		player1 = area
	else:
		player2 = area



func _on_Area2D_area_exited(area):
	if area == player1:
		player1 = null
	else:
		player2 = null


func set_model_facing(_direction : Vector2):
	$Viewport/Chaser.set_facing(-_direction)
