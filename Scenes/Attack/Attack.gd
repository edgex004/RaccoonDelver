extends Node2D

func is_class(type): return type == "Attack" or .is_class(type)
func    get_class(): return "Attack"

var tile_x
var tile_y


var max_burnout = 5.0

var turns_left = 5
# Declare member variables here. Examples:
# var a = 2
# var b = "text"


# Called when the node enters the scene tree for the first time.
func _ready():
	Globals.debug_attack("Fire at" + str(tile_x) +  " " + str(tile_y))
	set_position(get_node('/root/Level').map_tile_to_global(tile_x,tile_y))
	turns_left = int(randf() * max_burnout)
	get_node('/root/Level/Beat').connect("beat_timeout", self, "cause_damage")
	pass # Replace with function body.


# Called every frame. 'delta' is the elapsed time since the previous frame.
#func _process(delta):
#	pass

func cause_damage():
	Globals.debug_attack("Fire attacking")
	if turns_left < 0: return queue_free()
	var obj = get_node('/root/Level').get_object(tile_x,tile_y)
	if is_instance_valid(obj) and obj.is_class("Damageable"):
		obj.take_damage(get_fire_damage(),self)
	turns_left-=1

func get_fire_damage():
	var player_count = 0
	var sum_player_levels = 0
	if Globals.player_one and is_instance_valid(Globals.player_one) and Globals.player_one.is_alive:
		player_count += 1
		sum_player_levels += Globals.player_one.level
	if Globals.player_two and is_instance_valid(Globals.player_two) and Globals.player_two.is_alive:
		player_count += 1
		sum_player_levels += Globals.player_two.level
	var average_level
	if not player_count == 0:
		average_level = sum_player_levels/player_count
	else: 
		average_level = 1
	return round(10 + 5 * (average_level-1) + pow(average_level-1,2.1))
