extends Area2D

var tilesize = 32
var tile_x
var tile_y

var is_alive = true

var health = 100

const BACKGROUND_COL_MASK = 1 # 2^0
const PLAYER_COL_MASK = 2 # 2^1
const ENEMY_COL_MASK = 4 # 2^2


# Called when the node enters the scene tree for the first time.
func _ready():
	var rand_sprite = randi() % 3
	match rand_sprite:
		0:
			get_node('Sprite').texture = preload('res://Objects/Object2.png')
		1:
			get_node('Sprite').texture = preload('res://Objects/Object3.png')
		2:
			get_node('Sprite').texture = preload('res://Objects/Object4.png')


# Called every frame. 'delta' is the elapsed time since the previous frame.
#func _process(delta):
#	pass
func take_damage(damage, source):
	var my_col_mask = get_collision_mask()
	var source_col_mask = source.get_collision_mask()
	
	if not ((my_col_mask == source_col_mask) or (
		(my_col_mask == BACKGROUND_COL_MASK) and (source_col_mask == ENEMY_COL_MASK))):
		health -= damage
		print("My health = " + str(health))
		if health <= 0:
			is_alive = false
			get_node('/root/Level').set_tile(tile_x,tile_y,null)
			queue_free()
