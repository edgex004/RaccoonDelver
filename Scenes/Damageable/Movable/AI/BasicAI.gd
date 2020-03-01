extends "res://Scenes/Damageable/Movable/Movable.gd"


# Leveling system variables
var exp_on_kill_lin_coef = 1.5
var exp_on_kill_pow_coef = 1.25
var exp_on_kill_base = 10
var exp_on_kill_scaler = 1
# export var level = 1 (defined in Moveable)


# Called when the node enters the scene tree for the first time.
func _ready():
	set_level(1)


func set_level(set_level): # note getter defined in Moveable
	level = set_level
	experience_on_kill = round((exp_on_kill_lin_coef * level + pow(level, exp_on_kill_pow_coef) + 
							exp_on_kill_base) * exp_on_kill_scaler)
