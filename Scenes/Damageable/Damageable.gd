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

	pass # Replace with function body.


# Called every frame. 'delta' is the elapsed time since the previous frame.
#func _process(delta):
#	pass
func take_damage(damage, source):
	var my_col_mask = get_collision_mask()
	var source_col_mask = source.get_collision_mask()

	if not ((my_col_mask == source_col_mask) or (
		(my_col_mask == BACKGROUND_COL_MASK) and (source_col_mask == ENEMY_COL_MASK))):
		health -= damage
		$Damage.play()
		print("My health = " + str(health))
		if health <= 0:
			is_alive = false
			get_node('/root/Level').set_tile(tile_x,tile_y,null)
			$Damage.connect("finished", self, "queue_free")
