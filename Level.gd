extends Node2D

const PLAYER = preload("res://Scenes/Damageable/Movable/Player/Player.tscn")
const DAMAGEABLE = preload("res://Scenes/Damageable/Damageable.tscn")
const RANDOM_WALKER = preload("res://Scenes/Damageable/Movable/AI/RandomWalker/RandomWalker.tscn")
signal beat

const MOVEMENT_COLLISION_MASK = 1+2+4 #bit mask (2^0 + 2^1 + 2^2 = static objects)

onready var ObjCollisionShape = preload('res://Objects/ObjectCollisonShape.res')
onready var GroundTileMap : TileMap = $GroundTileMap

# Called when the node enters the scene tree for the first time.
func _ready():
	randomize() #New random seed
	$Beat.connect("timeout", self, "_on_Beat_timeout")
	var objects_to_spawn = 30
	var num_of_gamepads = Input.get_connected_joypads().size()
	var players_to_spawn = 1
	if num_of_gamepads > 0:
		print('found a gamepad')
		players_to_spawn = 2
	var enemies_to_spawn = 10
	spawn_random_objects(objects_to_spawn, enemies_to_spawn, players_to_spawn)

# Called every frame. 'delta' is the elapsed time since the previous frame.
func _process(delta):
	pass

func _on_Beat_timeout():
	emit_signal("beat")

func spawnPlayer(_spawn_position : Vector2, is_first_player : bool):
	var player = PLAYER.instance()
	add_child(player)
	player.set_position( _spawn_position)
	player.is_first_player = is_first_player
	connect("beat", player, "_on_Beat_timeout")


func spawnDamageable(_spawn_position : Vector2):
	var obj = DAMAGEABLE.instance()
	add_child(obj)
	obj.set_position( _spawn_position)
	
func spawnRandomWalker(_spawn_position : Vector2):
	var obj = RANDOM_WALKER.instance()
	add_child(obj)
	obj.set_position( _spawn_position)
	connect("beat", obj, "_on_Beat_timeout")

func spawn_random_objects(obj_to_place : int, num_of_enemies : int = 0, num_of_players : int = 1 ) -> void:
	if !GroundTileMap.tile_set:
		return
	#Get all tiles
	var open_tiles : Array = GroundTileMap.get_used_cells()
	for tile in GroundTileMap.get_used_cells():
		#Check if tiles are a wall or near a wall
		var is_pos_blocked = check_object_placement_blocked( _get_tile_pos(tile, GroundTileMap) )
		if is_pos_blocked:
			#Remove walls from the set
			open_tiles.erase(tile)
			assert(open_tiles.find(tile) < 0) #Make sure there are not duplicates 
	#Place objects in the remaining open spaces as "islands"
	while(obj_to_place > 0 and open_tiles.size() > 0):
		var rand_index = randi() % open_tiles.size()
		var selected_tile = open_tiles[rand_index]
		var obj_spawn_position = _get_tile_pos(selected_tile, GroundTileMap)
		#assert(not check_object_placement_blocked(selected_tile))
		spawnDamageable(obj_spawn_position)
		#Clear the space and any surrounding spaces 
		open_tiles.erase(selected_tile)
		open_tiles.erase(selected_tile-Vector2(1,0))
		open_tiles.erase(selected_tile-Vector2(-1,0))
		open_tiles.erase(selected_tile-Vector2(0,1))
		open_tiles.erase(selected_tile-Vector2(0,-1))
		open_tiles.erase(selected_tile-Vector2(1,1))
		open_tiles.erase(selected_tile-Vector2(1,-1))
		open_tiles.erase(selected_tile-Vector2(-1,1))
		open_tiles.erase(selected_tile-Vector2(-1,-1))
		obj_to_place -= 1
	assert(open_tiles.size() > num_of_players + num_of_enemies)
	# Spawn player
	for i in range(num_of_players):
		var rand_index = randi() % open_tiles.size()
		var selected_tile = open_tiles[rand_index]
		var player_spawn_position = _get_tile_pos(selected_tile, GroundTileMap)
		if i > 0:
			spawnPlayer(player_spawn_position, true)
		else:
			spawnPlayer(player_spawn_position, false)
		open_tiles.erase(selected_tile)
	#Spawn enemies
	for i in range(num_of_enemies):
		var rand_index = randi() % open_tiles.size()
		var selected_tile = open_tiles[rand_index]
		var enemy_spawn_position = _get_tile_pos(selected_tile, GroundTileMap)
		spawnRandomWalker(enemy_spawn_position)
		open_tiles.erase(selected_tile)

func _get_tile_pos(_tile_cords : Vector2, _tile_map : TileMap) -> Vector2:
	var cell_x_pos : float = float(_tile_cords.x*_tile_map.cell_size.x) + _tile_map.position.x + float(_tile_map.cell_size.x)/2.0
	var cell_y_pos : float = float(_tile_cords.y*_tile_map.cell_size.y) + _tile_map.position.y + float(_tile_map.cell_size.y)/2.0
	return Vector2(cell_x_pos, cell_y_pos)

func check_object_placement_blocked(_location : Vector2) -> bool:
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
