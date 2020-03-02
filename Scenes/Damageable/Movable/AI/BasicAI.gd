extends "res://Scenes/Damageable/Movable/Movable.gd"


# Leveling system variables
var exp_on_kill_lin_coef = 1.5
var exp_on_kill_pow_coef = 1.25
var exp_on_kill_base = 10
var exp_on_kill_scaler = 1
# export var level = 1 (defined in Moveable)

# Damage variables
var damage_lin_coef = 1
var damage_pow_coef = 1
var damage_base = 1
var damage_scaler = 1

# Health variables
var health_lin_coef = 1
var health_pow_coef = 1
var health_base = 1
var health_scaler = 1

# Called when the node enters the scene tree for the first time.
func _ready():
	set_level(1)


func set_level(set_level): # note getter defined in Moveable
	level = set_level
	experience_on_kill = round((exp_on_kill_lin_coef * level + pow(level, exp_on_kill_pow_coef) + 
							exp_on_kill_base) * exp_on_kill_scaler)
	damage = round((damage_lin_coef * (level-1) + pow(level-1, damage_pow_coef) + 
					damage_base) * damage_scaler)
	health_max = round((health_lin_coef * (level-1) + pow(level-1, health_pow_coef) + 
					health_base) * health_scaler)
	health = health_max
	print("My damage: " + str(damage))
