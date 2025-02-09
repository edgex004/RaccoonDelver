extends Damageable

func is_class(type): return type == "Movable" or .is_class(type)
func    get_class(): return "Movable"

const MOVEMENT_COLLISION_MASK = 1+2+4 #bit mask (2^0 + 2^1 + 2^2 = static objects)

onready var move_tween = $MoveTween

var damage_coefs = {'linear': 1, 'pow': 1, 'base': 1, 'scaler': 1}
var health_coefs = {'linear': 1, 'pow': 1, 'base': 1, 'scaler': 1}

export (float) var move_time = .075 # seconds
export (float) var damage = 40
const JUMP_HEIGHT = 7 # in pixels
const ATTACK_DIST = 9

var my_size
var scale_direction

# Leveling stats
export var level = 1

# Declare member variables here. Examples:
# var a = 2
# var b = "text"


# Called when the node enters the scene tree for the first time.
func _ready():
#	$SizeTween.connect("tween_completed", self, "tween_completed")
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
		#check for item
		var item = get_node('/root/Level').get_item(desired_tile_x,desired_tile_y)
		if item and is_instance_valid(item) and item.is_class("Item"):
			pick_up_item(item)
		#set_position(desired_pos)
		run_movement_tween(cur_pos, desired_pos)
#			move_tween.interpolate_property(self, "position", 
#			cur_pos, desired_pos, move_time, Tween.TRANS_SINE, Tween.EASE_IN)
#			move_tween.start()
		get_node('/root/Level').swap_tile(tile_x, tile_y, desired_tile_x,desired_tile_y, false)
	else:
		if blocking_object and is_instance_valid(blocking_object):
			if 'is_alive' in blocking_object and blocking_object.is_alive and blocking_object.has_method('take_damage'):
				chest_bump_blocker(dir_vector)
				blocking_object.take_damage(damage, self)
			elif (blocking_object.is_class("FloorDoor")):
				open_door(blocking_object)
	if Globals.verbose_movements:
		var label = DAMAGE_LABEL.instance()
		label.set_size(Vector2(48,16))
		label.add_text( str(tile_x) + " " + str(tile_y))
		add_child(label)

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


func run_movement_tween(cur_pos, desired_pos):
	if cur_pos.y == desired_pos.y:
		#Moving in the x, jump on the y
		var x_temp = (desired_pos.x - cur_pos.x) / 2 + cur_pos.x
		var y_temp = cur_pos.y - JUMP_HEIGHT
		move_tween.interpolate_property(self, "position:x", 
			cur_pos.x, x_temp, move_time/2, Tween.TRANS_LINEAR, Tween.EASE_OUT)
		move_tween.interpolate_property(self, "position:y", 
			cur_pos.y, y_temp, move_time/2, Tween.TRANS_SINE, Tween.EASE_OUT)
		move_tween.start()
		yield(move_tween, "tween_completed")
		move_tween.interpolate_property(self, "position:x", 
			x_temp, desired_pos.x, move_time/2, Tween.TRANS_LINEAR, Tween.EASE_IN)
		move_tween.interpolate_property(self, "position:y", 
			y_temp, desired_pos.y, move_time/2, Tween.TRANS_BOUNCE, Tween.EASE_IN)
		move_tween.start()
	else:
		# Moving in the y, jump on the x
		var y_temp = (desired_pos.y - cur_pos.y) / 2 + cur_pos.y
		var x_temp = cur_pos.x - JUMP_HEIGHT
		move_tween.interpolate_property(self, "position:x", 
			cur_pos.x, x_temp, move_time/2, Tween.TRANS_SINE, Tween.EASE_OUT)
		move_tween.interpolate_property(self, "position:y", 
			cur_pos.y, y_temp, move_time/2, Tween.TRANS_LINEAR, Tween.EASE_OUT)
		move_tween.start()
		yield(move_tween, "tween_completed")
		move_tween.interpolate_property(self, "position:x", 
			x_temp, desired_pos.x, move_time/2, Tween.TRANS_BOUNCE, Tween.EASE_IN)
		move_tween.interpolate_property(self, "position:y", 
			y_temp, desired_pos.y, move_time/2, Tween.TRANS_LINEAR, Tween.EASE_IN)
		move_tween.start()

func chest_bump_blocker(dir_vector : Vector2):
	var cur_pos = get_position()
	move_tween.interpolate_property(self, "position:x", 
			cur_pos.x, cur_pos.x + dir_vector.x * ATTACK_DIST, 
			move_time/2, Tween.TRANS_CUBIC, Tween.EASE_OUT)
	move_tween.interpolate_property(self, "position:y", 
		cur_pos.y, cur_pos.y + dir_vector.y * ATTACK_DIST,
		 move_time/2, Tween.TRANS_CUBIC, Tween.EASE_OUT)
	move_tween.start()
	yield(move_tween, "tween_completed")
	move_tween.interpolate_property(self, "position:x", 
			cur_pos.x + dir_vector.x * ATTACK_DIST, cur_pos.x, 
			move_time/2, Tween.TRANS_CUBIC, Tween.EASE_OUT)
	move_tween.interpolate_property(self, "position:y", 
		cur_pos.y + dir_vector.y * ATTACK_DIST, cur_pos.y,
		 move_time/2, Tween.TRANS_CUBIC, Tween.EASE_OUT)
	move_tween.start()

func calc_unit_stats():
	damage = round((damage_coefs['linear'] * (level-1) + pow(level-1, damage_coefs['pow']) + 
					damage_coefs['base']) * damage_coefs['scaler'])
	health_max = round((health_coefs['linear'] * (level-1) + pow(level-1, health_coefs['pow']) + 
					health_coefs['base']) * health_coefs['scaler'])
	#print("My class: " + self.get_class() + ", Level: " + str(level) + ", Damage: " + str(damage) + ", Health: " + str(health_max))
