extends "../Damageable.gd"

const MOVEMENT_COLLISION_MASK = 1+2+4 #bit mask (2^0 + 2^1 + 2^2 = static objects)

var my_size


# Declare member variables here. Examples:
# var a = 2
# var b = "text"


# Called when the node enters the scene tree for the first time.
func _ready():
	get_parent().connect("beat", self, "_on_Beat_timeout")


# Called every frame. 'delta' is the elapsed time since the previous frame.
#func _process(delta):
#	pass


func move_tile(dir_vector, movement_size):
	var cur_pos = get_position()
	var desired_pos = cur_pos + dir_vector * movement_size
	set_position(desired_pos)

func check_for_collision(cast_from : Vector2, cast_to : Vector2) -> bool:
	# Returns true if the space cannot be moved to because something is there
	var collision_occured = false
	var space_state = get_world_2d().direct_space_state
	#Create the ray casts (can collide with bodies or areas)
	var los_result = space_state.intersect_ray(cast_from, cast_to, [self], MOVEMENT_COLLISION_MASK, true, true)
	if los_result:
		#line of sight to the bottom part of the target is blocked
		#result contains blocking object info
		collision_occured = true
	return collision_occured
