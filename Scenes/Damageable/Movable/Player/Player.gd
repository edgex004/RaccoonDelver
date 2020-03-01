extends "../Movable.gd"
class_name Player

var beat_counter = 0
var is_first_player : bool = true

# Levelling stats
# export var level = 1 (defined in Moveable)
export var experience = 0

# Experience required equation: a * level + level ^ b + base
var exp_req_lin_coef = 7.5
var exp_req_pow_coef = 2.25
var exp_req_base = 50
var experience_required = _get_experience_required(level + 1)
var experience_total = 0

var has_moved = false
var player1_inputs = {"player1_left": Vector2.LEFT,
						"player1_right": Vector2.RIGHT,
						"player1_up": Vector2.UP,
						"player1_down": Vector2.DOWN}
var player2_inputs = {"player2_left": Vector2.LEFT,
						"player2_right": Vector2.RIGHT,
						"player2_up": Vector2.UP,
						"player2_down": Vector2.DOWN}

# Called when the node enters the scene tree for the first time.
func _ready():
	damage = 100


func _process(delta):
	if not (has_moved):
		var input_map = player1_inputs
		if not is_first_player:
			input_map = player2_inputs
		for dir in input_map.keys():
			if Input.is_action_just_pressed(dir):
				move_tile(input_map[dir], 1)
				has_moved = true

func _on_Beat_timeout():
	var beats_dict = {0: ".", 1: "..", 2: "..."}
	print("Beat Happened" + beats_dict[beat_counter])
	beat_counter = (beat_counter + 1) % 3
	has_moved = false


func _get_experience_required(level):
	return round(pow(level, exp_req_pow_coef) + level * exp_req_lin_coef + exp_req_base)
	
func gain_experience(value):
	experience += value
	experience_total += value
	print("Cur exp: " + str(experience) + ". Req exp: " + str(experience_required))
	while experience >= experience_required:
		experience -= experience_required
		level_up()

func level_up():
	level += 1
	experience_required = _get_experience_required(level + 1)
	#var stats = ['damage', 'health_max']
	#var random_stat = stats[randi() % stats.size()]
	#set(random_stat, get(random_stat) + 1)
	damage = damage + 20
	health = health_max
	$ProgressBar.hide()
