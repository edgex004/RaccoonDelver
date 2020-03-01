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
