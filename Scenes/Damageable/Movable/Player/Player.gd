extends "../Movable.gd"

# Declare member variables here. Examples:
# var a = 2
# var b = "text"
var has_moved = false
var player1_inputs = {"player1_left": Vector2.LEFT,
						"player1_right": Vector2.RIGHT,
						"player1_up": Vector2.UP,
						"player1_down": Vector2.DOWN}

# Called when the node enters the scene tree for the first time.
func _ready():
	pass


# Called every frame. 'delta' is the elapsed time since the previous frame.
#func _process(delta):
#	pass

func _on_Beat_timeout():
	print("Beat Happened...")
	has_moved = false
	
func _unhandled_input(event):
	if not (has_moved):
		for dir in player1_inputs.keys():
			if event.is_action_pressed(dir):
				move_tile(player1_inputs[dir], tilesize)
				has_moved = true
