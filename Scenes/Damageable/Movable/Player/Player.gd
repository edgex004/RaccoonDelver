extends "../Movable.gd"

var beat_counter = 0

var has_moved = false
var player1_inputs = {"player1_left": Vector2.LEFT,
						"player1_right": Vector2.RIGHT,
						"player1_up": Vector2.UP,
						"player1_down": Vector2.DOWN}

# Called when the node enters the scene tree for the first time.
func _ready():
	damage = 100


func _process(delta):
	if not (has_moved):
		for dir in player1_inputs.keys():
			if Input.is_action_just_pressed(dir):
				move_tile(player1_inputs[dir], tilesize)
				has_moved = true

func _on_Beat_timeout():
	var beats_dict = {0: ".", 1: "..", 2: "..."}
	print("Beat Happened" + beats_dict[beat_counter])
	beat_counter = (beat_counter + 1) % 3
	has_moved = false
