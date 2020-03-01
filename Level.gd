extends Node2D

const PLAYER = preload("res://Scenes/Damageable/Movable/Player/Player.tscn")
const DAMAGEABLE = preload("res://Scenes/Damageable/Damageable.tscn")
const RANDOM_WALKER = preload("res://Scenes/Damageable/Movable/AI/RandomWalker/RandomWalker.tscn")
const PERMANENT = preload("res://Scenes/Permanent/Permanent.tscn")
signal beat

const MOVEMENT_COLLISION_MASK = 1+2+4 #bit mask (2^0 + 2^1 + 2^2 = static objects)

onready var ObjCollisionShape = preload('res://Objects/ObjectCollisonShape.res')
onready var GroundTileMap : TileMap = $GroundTileMap

var StateMap = Array()

# Called when the node enters the scene tree for the first time.
func _ready():
	var used_cells = GroundTileMap.get_used_cells()
	for pos in used_cells:
		if 1 + pos.x > StateMap.size():
			for i in range(1 + pos.x-StateMap.size()):
				StateMap.append([])
		if 1 + pos.y > StateMap[pos.x].size():
			for i in range(1 + pos.y-StateMap[pos.x].size()):
				StateMap[pos.x].append(null)
		if( GroundTileMap.get_cell(pos.x, pos.y) != 6 ):
			StateMap[pos.x][pos.y] = PERMANENT.instance()
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

func spawnPlayer(x : int, y : int, is_first_player : bool):
	if (StateMap[x][y] == null):
		var player = PLAYER.instance()
		set_tile(x,y,player)
		add_child(player)
		player.set_position( _get_tile_pos(Vector2(x,y), GroundTileMap) )
		player.is_first_player = is_first_player
		connect("beat", player, "_on_Beat_timeout")


func spawnDamageable(x : int, y : int):
	if (StateMap[x][y] == null):
		var obj = DAMAGEABLE.instance()
		set_tile(x,y,obj)
		add_child(obj)
		obj.set_position( _get_tile_pos(Vector2(x,y), GroundTileMap) )

func spawnRandomWalker(x : int, y : int):
	if (StateMap[x][y] == null):
		var obj = RANDOM_WALKER.instance()
		set_tile(x,y,obj)
		add_child(obj)
		obj.set_position( _get_tile_pos(Vector2(x,y), GroundTileMap) )
		connect("beat", obj, "_on_Beat_timeout")


func spawn_random_objects(obj_to_place : int, num_of_enemies : int = 0, num_of_players : int = 1 ) -> void:
	if !GroundTileMap.tile_set:
		return
	#Get all tiles
	var open_tiles : Array = GroundTileMap.get_used_cells()
	for tile in GroundTileMap.get_used_cells():
		#Check if tiles are a wall or near a wall
		var is_pos_blocked = check_object_placement_blocked(tile)
		if is_pos_blocked:
			#Remove walls from the set
			open_tiles.erase(tile)
			assert(open_tiles.find(tile) < 0) #Make sure there are not duplicates 
	#Place objects in the remaining open spaces as "islands"
	while(obj_to_place > 0 and open_tiles.size() > 0):
		var rand_index = randi() % open_tiles.size()
		var selected_tile = open_tiles[rand_index]
		#assert(not check_object_placement_blocked(selected_tile))
		spawnDamageable(selected_tile.x, selected_tile.y)
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
		if i > 0:
			spawnPlayer(selected_tile.x, selected_tile.y, true)
		else:
			spawnPlayer(selected_tile.x, selected_tile.y, false)
		open_tiles.erase(selected_tile)
	#Spawn enemies
	for i in range(num_of_enemies):
		var rand_index = randi() % open_tiles.size()
		var selected_tile = open_tiles[rand_index]
		spawnRandomWalker(selected_tile.x, selected_tile.y)
		open_tiles.erase(selected_tile)

func _get_tile_pos(_tile_cords : Vector2, _tile_map : TileMap) -> Vector2:
	var cell_x_pos : float = float(_tile_cords.x*_tile_map.cell_size.x) + _tile_map.position.x + float(_tile_map.cell_size.x)/2.0
	var cell_y_pos : float = float(_tile_cords.y*_tile_map.cell_size.y) + _tile_map.position.y + float(_tile_map.cell_size.y)/2.0
	return Vector2(cell_x_pos, cell_y_pos)

func check_object_placement_blocked(_location : Vector2) -> bool:
	return StateMap[_location.x][_location.y] != null

func get_object(x:int,y:int) -> Node:
	if ( x < 0 or y < 0 ): return null
	if ( x + 1 > StateMap.size() or y+1 > StateMap[x].size()): return null
	return StateMap[x][y]

func set_tile(x:int,y:int,val:Node) -> bool:
	if ( x < 0 or y < 0 ): return false
	if ( x + 1 > StateMap.size() or y+1 > StateMap[x].size()): return false
	StateMap[x][y] = val
	if (is_instance_valid(val)):
		val.tile_x = x
		val.tile_y = y
	return true

func swap_tile(from_x:int, from_y:int, to_x:int, to_y:int) -> bool:
	if ( from_x < 0 or from_y < 0 ): return false
	if ( from_x + 1 > StateMap.size() or from_y+1 > StateMap[from_x].size()): return false
	if ( to_x < 0 or to_y < 0 ): return false
	if ( to_x + 1 > StateMap.size() or to_y+1 > StateMap[to_x].size()): return false
	var from = get_object(from_x,from_y)
	var to = get_object(to_x,to_y)
	return set_tile(to_x,to_y,from) and set_tile(from_x,from_y,to)
