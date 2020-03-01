extends "res://Scenes/Damageable/Movable/AI/BasicAI.gd"


var dirs = {0: Vector2.LEFT, 
			1: Vector2.UP,
			2: Vector2.RIGHT,
			3: Vector2.DOWN}

#var screensize

func _ready():
	#screensize = get_viewport().get_size()
	#set_position(screensize/2)
	damage = 10


func _on_Beat_timeout():
	#print("Beat Happened...")
	var selected_dir = randi() % len(dirs)
	
	for dir in dirs:
		if dir == selected_dir:
			move_tile(dirs[dir], 1)
