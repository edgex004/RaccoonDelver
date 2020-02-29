extends Area2D


var tilesize = 32
var my_size
var has_moved = false
var player1_inputs = {"player1_left": Vector2.LEFT,
						"player1_right": Vector2.RIGHT,
						"player1_up": Vector2.UP,
						"player1_down": Vector2.DOWN}

# Called when the node enters the scene tree for the first time.
func _ready():
	my_size = get_node("Sprite").get_texture().get_size() / 2

# Called every frame. 'delta' is the elapsed time since the previous frame.
#func _process(delta):
#	pass


func _unhandled_input(event):
	if not (has_moved):
		for dir in player1_inputs.keys():
			if event.is_action_pressed(dir):
				move_tile(player1_inputs[dir], tilesize)
				#has_moved = true # leaving inactive for now until beat timer is added

func move_tile(dir_vector, movement_size):
	var cur_pos = get_position()
	var desired_pos = cur_pos + dir_vector * movement_size
	set_position(desired_pos)
