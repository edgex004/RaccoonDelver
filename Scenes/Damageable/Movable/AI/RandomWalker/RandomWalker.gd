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
	var rand_sprite = randi() % 3
	match rand_sprite:
		0:
			get_node('Sprite').texture = preload('res://Scenes/Damageable/Movable/AI/RandomWalker/BasicEnemySkin.png')
		1:
			get_node('Sprite').texture = preload('res://Scenes/Damageable/Movable/AI/RandomWalker/Floater.png')
		2:
			get_node('Sprite').texture = preload('res://Scenes/Damageable/Movable/AI/RandomWalker/Fatty.png')


func _on_Beat_timeout():
	#print("Beat Happened...")
	var selected_dir = randi() % len(dirs)
	
	for dir in dirs:
		if dir == selected_dir:
			move_tile(dirs[dir], 1)
