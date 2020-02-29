extends "../Damageable.gd"

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
	var desired_pos = cur_pos + dir_vector * movement_size
	if (!check_for_collision(cur_pos,desired_pos)):
		#set_position(desired_pos)
		move_tween.interpolate_property(self, "position", 
		cur_pos, desired_pos, move_time, Tween.TRANS_SINE, Tween.EASE_IN)
		move_tween.start()

func check_for_collision(cast_from : Vector2, cast_to : Vector2) -> bool:
	# Returns true if the space cannot be moved to because something is there
	var collision_occured = false
	var space_state = get_world_2d().direct_space_state
	#Create the ray casts (can collide with bodies or areas)
	var results = space_state.intersect_ray(cast_from, cast_to, [self], MOVEMENT_COLLISION_MASK, true, true)
	if results:
		#line of sight to the bottom part of the target is blocked
		#result contains blocking object info
		
		if results is Array:
			for collison_result in results:
			#Getting the unit directly
				var unit = collison_result['collider']
				if 'is_alive' in unit:
					if !unit.is_alive:
						#Ignore dead troops
						continue
				#Apply damage
				if unit.has_method('take_damage'):
					unit.take_damage(damage, self)
		else:
			var unit = results['collider']
			if 'is_alive' in unit:
				if unit.is_alive:
					#Apply damage
					if unit.has_method('take_damage'):
						unit.take_damage(damage, self)
				#else do nothing (ignore dead troops)
		collision_occured = true
	return collision_occured
