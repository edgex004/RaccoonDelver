extends Damageable

const MOVEMENT_COLLISION_MASK = 1+2+4 #bit mask (2^0 + 2^1 + 2^2 = static objects)

onready var move_tween = $MoveTween
export var move_time = 0.1 # seconds

var my_size
var damage = 40

# Declare member variables here. Examples:
# var a = 2
# var b = "text"


# Called when the node enters the scene tree for the first time.
func _ready():
	pass


# Called every frame. 'delta' is the elapsed time since the previous frame.
#func _process(delta):
#	pass


func move_tile(dir_vector, movement_size):
	var cur_pos = get_position()
	var desired_tile_x = tile_x + dir_vector.x * movement_size
	var desired_tile_y = tile_y + dir_vector.y * movement_size
	var desired_pos = get_node('/root/Level')._get_tile_pos(Vector2(desired_tile_x,desired_tile_y),get_node('/root/Level').GroundTileMap)
	if (!check_for_collision(desired_tile_x,desired_tile_y)):
		#set_position(desired_pos)
		move_tween.interpolate_property(self, "position", 
		cur_pos, desired_pos, move_time, Tween.TRANS_SINE, Tween.EASE_IN)
		move_tween.start()
		get_node('/root/Level').swap_tile(tile_x, tile_y, desired_tile_x,desired_tile_y)

func check_for_collision(x:int, y:int) -> bool:
	# Returns true if the space cannot be moved to because something is there
	var collider = get_node('/root/Level').get_object(x,y)
	if (collider == null): return false
	var space_state = get_world_2d().direct_space_state
	if is_instance_valid(collider) and 'is_alive' in collider and collider.is_alive and collider.has_method('take_damage'):
		collider.take_damage(damage, self)
	return true
