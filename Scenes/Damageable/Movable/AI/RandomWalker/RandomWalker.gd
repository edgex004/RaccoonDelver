extends "res://Scenes/Damageable/Movable/AI/BasicAI.gd"


# Declare member variables here. Examples:
# var a = 2
# var b = "text"

var dirs = {0: Vector2.LEFT, 
			1: Vector2.UP,
			2: Vector2.RIGHT,
			3: Vector2.DOWN}

#var screensize

# Called when the node enters the scene tree for the first time.
func _ready():
	#screensize = get_viewport().get_size()
	#set_position(screensize/2)
	pass # Replace with function body.


func _on_Beat_timeout():
	print("Beat Happened...")
	var pos = get_position()
	var selected_dir = randi() % len(dirs)
	
	for dir in dirs:
		if dir == selected_dir:
			move_tile(dirs[dir], tilesize)
