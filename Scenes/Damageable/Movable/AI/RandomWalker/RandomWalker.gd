extends "res://Scenes/Damageable/Movable/AI/BasicAI.gd"


var dirs = {0: Vector2.LEFT, 
			1: Vector2.UP,
			2: Vector2.RIGHT,
			3: Vector2.DOWN}

#var screensize

func _ready():
	damage = 10
	exp_on_kill_scaler = 0.65
	set_level(1)


func _on_Beat_timeout():
	#print("Beat Happened...")
	var num_of_dirs = len(dirs)
	var selected_dir = randi() % num_of_dirs
	for i in range(4):
		#Search for a direction that is not blocked
		selected_dir += i
		if selected_dir >= num_of_dirs:
			selected_dir = 0
		var collision_result = check_for_collision(dirs[selected_dir], 1)
		if !collision_result:
			#Found an unblocked direction
			move_tile(dirs[selected_dir], 1)
			break
