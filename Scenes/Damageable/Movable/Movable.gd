extends Damageable

const MOVEMENT_COLLISION_MASK = 1+2+4 #bit mask (2^0 + 2^1 + 2^2 = static objects)

onready var move_tween = $MoveTween

export (float) var move_time = 0.1 # seconds
export (float) var damage = 40

var my_size


# Leveling stats
export var level = 1

# Declare member variables here. Examples:
# var a = 2
# var b = "text"


# Called when the node enters the scene tree for the first time.
func _ready():
	pass


# Called every frame. 'delta' is the elapsed time since the previous frame.
#func _process(delta):
#	pass

func pick_up_item(item: Node):
	# If your player/monster can do this, override
	pass
	
func open_door(door: Node):
	# If your player/monster can do this, override
	pass

func move_tile(dir_vector : Vector2, movement_size : int = 1):
	var cur_pos = get_position()
	var desired_tile_x = tile_x + dir_vector.x * movement_size
	var desired_tile_y = tile_y + dir_vector.y * movement_size
	var desired_pos = get_node('/root/Level').map_tile_to_global(desired_tile_x,desired_tile_y)
	var blocking_object = check_for_collision(dir_vector, movement_size)
	if (!blocking_object):
		#set_position(desired_pos)
		move_tween.interpolate_property(self, "position", 
		cur_pos, desired_pos, move_time, Tween.TRANS_SINE, Tween.EASE_IN)
		move_tween.start()
		get_node('/root/Level').swap_tile(tile_x, tile_y, desired_tile_x,desired_tile_y)
	else:
		if blocking_object and is_instance_valid(blocking_object):
			if 'is_alive' in blocking_object and blocking_object.is_alive and blocking_object.has_method('take_damage'):
				blocking_object.take_damage(damage, self)
			elif (blocking_object.is_class("FloorDoor")):
				open_door(blocking_object)
			elif (blocking_object.is_class("Item")):
				pick_up_item(blocking_object)

func check_for_collision(dir_vector : Vector2, movement_size : int = 1):
	#Returns the blocking object
	if movement_size <= 0:
		return null
	for n in range(movement_size):
		var moved = n + 1
		var desired_tile_x = tile_x + dir_vector.x * moved
		var desired_tile_y = tile_y + dir_vector.y * moved
		var blocking_object = get_node('/root/Level').get_object(desired_tile_x,desired_tile_y)
		if blocking_object:
			return blocking_object

func get_level():
	return level
