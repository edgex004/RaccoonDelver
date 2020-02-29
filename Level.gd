extends Node2D

signal beat

const MOVEMENT_COLLISION_MASK = 1+2+4 #bit mask (2^0 + 2^1 + 2^2 = static objects)

onready var ObjCollisionShape = preload('res://Objects/ObjectCollisonShape.res')
onready var GroundTileMap : TileMap = $GroundTileMap

# Called when the node enters the scene tree for the first time.
func _ready():
	randomize() #New random seed
	$Beat.connect("timeout", self, "_on_Beat_timeout")
	var level_tiles : Array= GroundTileMap.get_used_cells()
	var max_tile_index = level_tiles.size()
	var obj_to_place : int = 10
	if GroundTileMap.tile_set:
		while(obj_to_place > 0):
			var rand_index = randi() % max_tile_index
			var cell_x_pos = float(level_tiles[rand_index].x)*GroundTileMap.cell_size.x + GroundTileMap.position.x
			var cell_y_pos = float(level_tiles[rand_index].y)*GroundTileMap.cell_size.y + GroundTileMap.position.y
			var is_pos_open = check_object_placement(Vector2(cell_x_pos, cell_y_pos))
			if is_pos_open:
				spawn_object(Vector2(cell_x_pos, cell_y_pos))
				obj_to_place -= 1


# Called every frame. 'delta' is the elapsed time since the previous frame.
func _process(delta):
	if Input.is_action_just_pressed("ui_accept"):
		print(check_object_placement(get_global_mouse_position()))


func _on_Beat_timeout():
	emit_signal("beat")


func spawn_object(_spawn_position : Vector2):
	pass

func check_object_placement(_location : Vector2) -> bool:
	# Returns true if the space cannot be moved to because something is there
	var collision_occured = false
	#Setup shape query parameters
	var params = Physics2DShapeQueryParameters.new()
	params.set_shape_rid(ObjCollisionShape.get_rid())
	# Set other parameters if needed
	params.set_collision_layer(MOVEMENT_COLLISION_MASK)
	params.collide_with_areas = true
	params.collide_with_bodies = true
	var placement_transform : Transform2D = self.get_global_transform()
	placement_transform.origin = _location
	params.set_transform(placement_transform)
	var space_state = get_world_2d().direct_space_state
	#Pick targets
	var results = space_state.intersect_shape(params, 1)
	if results:
		#line of sight to the bottom part of the target is blocked
		#result contains blocking object info
		collision_occured = true
	return collision_occured




