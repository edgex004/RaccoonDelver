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
		obj.take_damage(10,self)
	turns_left-=1
