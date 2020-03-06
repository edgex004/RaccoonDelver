extends Node2D

const PLAYER = preload("res://Scenes/Damageable/Movable/Player/Player.tscn")
const RANDOM_WALKER = preload("res://Scenes/Damageable/Movable/AI/RandomWalker/RandomWalker.tscn")
const CHASER = preload("res://Scenes/Damageable/Movable/AI/Chaser/Chaser.tscn")
const FLOATER = preload("res://Scenes/Damageable/Movable/AI/Floater/Floater.tscn")
const PERMANENT = preload("res://Scenes/Permanent/Permanent.tscn")
const FLOORDOOR = preload("res://Scenes/Permanent/FloorDoor/FloorDoor.tscn")
const PLANT = preload('res://Scenes/Damageable/Plants/Plant.tscn')
const ITEM = preload('res://Scenes/Item/Item.tscn')
const MOVEMENT_COLLISION_MASK = 1+2+4 #bit mask (2^0 + 2^1 + 2^2 = static objects)

signal enviro_beat
signal enemy_beat
signal player_beat

onready var ObjCollisionShape = preload('res://Objects/ObjectCollisonShape.res')
onready var GroundTileMap : TileMap = $GroundTileMap
onready var Player1ExpBar = $CanvasLayer/Interface/Player1_GUI/Player1Bars/HBoxContainer/VBoxContainer/Player1ExpContainer/ExperienceBar
onready var Player1HpBar = $CanvasLayer/Interface/Player1_GUI/Player1Bars/HBoxContainer/VBoxContainer/Player1HPContainer/HealthBar
onready var Player1Item1 = $CanvasLayer/Interface/Player1_GUI/Player1Bars/HBoxContainer/P1Item1
onready var Player1Item2 = $CanvasLayer/Interface/Player1_GUI/Player1Bars/HBoxContainer/P1Item2
onready var Player1Item3 = $CanvasLayer/Interface/Player1_GUI/Player1Bars/HBoxContainer/P1Item3
onready var Player1GUI = $CanvasLayer/Interface/Player1_GUI
onready var Player2ExpBar = $CanvasLayer/Interface/Player2_GUI/Player2Bars/HBoxContainer/VBoxContainer/Player2ExpContainer/ExperienceBar
onready var Player2HpBar = $CanvasLayer/Interface/Player2_GUI/Player2Bars/HBoxContainer/VBoxContainer/Player2HPContainer/HealthBar
onready var Player2Item1 = $CanvasLayer/Interface/Player2_GUI/Player2Bars/HBoxContainer/P2Item1
onready var Player2Item2 = $CanvasLayer/Interface/Player2_GUI/Player2Bars/HBoxContainer/P2Item2
onready var Player2Item3 = $CanvasLayer/Interface/Player2_GUI/Player2Bars/HBoxContainer/P2Item3
onready var Player2GUI = $CanvasLayer/Interface/Player2_GUI

var obj_to_place_store
var num_of_enemies_store
var num_of_players_store
var StateMap = Array()
var ItemMap = Array()

var current_level_value = 1
const DEBUG_MODE = false

# Called when the node enters the scene tree for the first time.
func _ready():
	print("setup")
	Globals.current_level = self
	# hide player 2 GUI until we need it
	Player2GUI.visible = false

	randomize() #New random seed
	$Beat.connect("beat_timeout", self, "_on_Beat_timeout")
	$Beat.connect("player_beat_timeout", self, "_on_player_Beat_timeout")

	var objects_to_spawn = 30
	var num_of_gamepads = Input.get_connected_joypads().size()
	var players_to_spawn = 1
	if num_of_gamepads > 0:
		print('found a gamepad')
		players_to_spawn = 2
	var enemies_to_spawn = 10
	spawn_random_objects(objects_to_spawn, enemies_to_spawn, players_to_spawn, current_level_value)

# Called every frame. 'delta' is the elapsed time since the previous frame.
func _process(delta):
	pass

func _on_Beat_timeout():
	emit_signal("enviro_beat")
	emit_signal("enemy_beat")
	var timer = Timer.new()
	timer.one_shot = true
	timer.wait_time = $Beat.wait_time/4
	timer.connect("timeout", self, "_on_player_Beat_timeout")
	add_child(timer)
	timer.start()


func _on_player_Beat_timeout():
	print("player beat")
	emit_signal("player_beat")

func spawnPlayer(x : int, y : int, is_first_player : bool):
	if (StateMap[x][y] == null):
		var player = PLAYER.instance()
		player.is_first_player = is_first_player
		connect("player_beat", player, "_on_Beat_timeout")
		player.connect("hit_floor_door", self, "next_level")
		if is_first_player:
			Globals.player_one = player
			player.connect("player_experience_gained", Player1ExpBar, 
				"on_player_experience_gain")
			Player1ExpBar.initialize(player.experience, player.experience_required)
			player.connect("health_change", Player1HpBar, "on_player_health_change")
			Player1HpBar.initialize(player.health, player.health_max)
			player.item_guis = [Player1Item1,Player1Item2,Player1Item3]
		else: 
			Globals.player_two = player
			Player2GUI.visible = true
			Player2ExpBar.is_first_player = false
			player.connect("player_experience_gained", Player2ExpBar, 
				"on_player_experience_gain")
			Player2ExpBar.initialize(player.experience, player.experience_required)
			player.connect("health_change", Player2HpBar, "on_player_health_change")
			Player2HpBar.initialize(player.health, player.health_max)
			player.item_guis = [Player2Item1,Player2Item2,Player2Item3]
		set_tile(x,y,player)
		get_node("YSort").add_child(player)
		player.set_position( _get_tile_pos(Vector2(x,y), GroundTileMap) )
		
		if DEBUG_MODE:
			for i in range(current_level_value-1):
				player.level_up()
		


func spawnDamageable(x : int, y : int):
	if (StateMap[x][y] == null):
		var obj = PLANT.instance()
		set_tile(x,y,obj)
		get_node("YSort").add_child(obj)


func spawnEnemy(x : int, y : int, _resource, desired_level: int = 1):
	if (StateMap[x][y] == null):
		var obj = _resource.instance()
		set_tile(x,y,obj)
		get_node("YSort").add_child(obj)
		connect("enemy_beat", obj, "_on_Beat_timeout")
		obj.set_level(desired_level)

func spawnExit(x : int, y : int):
	if (StateMap[x][y] == null):
		var obj = FLOORDOOR.instance()
		set_tile(x,y,obj)
		get_node("YSort").add_child(obj)

func spawnItem(x : int, y : int, type):
	if (ItemMap[x][y] == null):
		var obj = ITEM.instance()
		obj.type = type
		set_tile(x,y,obj, true)
		get_node("YSort").add_child(obj)

func next_level():
	current_level_value += 1
	get_node("Beat").set_up_music(5)
	var old_players = clear_map()
	spawn_random_objects(obj_to_place_store, num_of_enemies_store, num_of_players_store, current_level_value, old_players)

func clear_map() -> Array:
	# Clears the map but returns the array of players so they can move on to the next level
	var players = []
	for x in range(StateMap.size()):
		for y in range(StateMap[x].size()):
			if is_instance_valid(StateMap[x][y]):
				if StateMap[x][y].is_class("Player"):
					players.append(StateMap[x][y])
				else:
					StateMap[x][y].queue_free()
			if is_instance_valid(ItemMap[x][y]):
				ItemMap[x][y].queue_free()
			StateMap[x][y] = null
			ItemMap[x][y] = null
	return players

func spawn_random_objects(obj_to_place : int, num_of_enemies : int = 0, num_of_players : int = 1 , level: int = 1 , players: Array = []) -> void:
	obj_to_place_store = obj_to_place
	num_of_enemies_store = num_of_enemies
	num_of_players_store = num_of_players
	if !GroundTileMap.tile_set:
		return
	#Get all tiles
	var open_tiles : Array = GroundTileMap.get_used_cells()
	for pos in open_tiles:
		if 1 + pos.x > StateMap.size():
			for i in range(1 + pos.x-StateMap.size()):
				StateMap.append([])
		if 1 + pos.y > StateMap[pos.x].size():
			for i in range(1 + pos.y-StateMap[pos.x].size()):
				StateMap[pos.x].append(null)
		if( GroundTileMap.get_cell(pos.x, pos.y) != 6 ):
			StateMap[pos.x][pos.y] = PERMANENT.instance()
	ItemMap = StateMap.duplicate(true)
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
	assert(open_tiles.size() > num_of_players + num_of_enemies + 2)
	# Spawn player
	for i in range(num_of_players):
		var rand_index = randi() % open_tiles.size()
		var selected_tile = open_tiles[rand_index]
		var is_first_player = (i == 0)
		if i+1 > players.size():
			spawnPlayer(selected_tile.x, selected_tile.y, is_first_player)
		else:
			set_tile(selected_tile.x, selected_tile.y,players[i])
		open_tiles.erase(selected_tile)
	#Spawn enemies
	var enemy_info = get_enemy_info(level)
	#print("Enemy info: " + str(enemy_info))
	for i in range(enemy_info['Enemy Count']):
		var rand_index = randi() % open_tiles.size()
		var selected_tile = open_tiles[rand_index]
		var rand_chance = randf()
		var level_span = enemy_info['Max Level'] - enemy_info['Min Level']
		var enemy_level
		if not level_span <= 0:
			enemy_level = (randi() % (level_span+1)) + enemy_info['Min Level']
		else:
			enemy_level = enemy_info['Min Level']
		if rand_chance < enemy_info['Chaser']:
			spawnEnemy(selected_tile.x, selected_tile.y, CHASER, enemy_level)
		elif rand_chance < (enemy_info['Chaser'] + enemy_info['Floater']):
			spawnEnemy(selected_tile.x, selected_tile.y, FLOATER, enemy_level)
		else:
			spawnEnemy(selected_tile.x, selected_tile.y, RANDOM_WALKER, enemy_level)
		open_tiles.erase(selected_tile)
	
	var rand_index = randi() % open_tiles.size()
	var selected_tile = open_tiles[rand_index]
	spawnExit(selected_tile.x, selected_tile.y)
	open_tiles.erase(selected_tile)
	
	rand_index = randi() % open_tiles.size()
	selected_tile = open_tiles[rand_index]
	spawnItem(selected_tile.x, selected_tile.y, Globals.ItemType.key)
	open_tiles.erase(selected_tile)

func _get_tile_pos(_tile_cords : Vector2, _tile_map : TileMap) -> Vector2:
	var cell_x_pos : float = float(_tile_cords.x*_tile_map.cell_size.x) + _tile_map.position.x + float(_tile_map.cell_size.x)/2.0
	var cell_y_pos : float = float(_tile_cords.y*_tile_map.cell_size.y) + _tile_map.position.y + float(_tile_map.cell_size.y)/2.0
	return Vector2(cell_x_pos, cell_y_pos)

func check_object_placement_blocked(_location : Vector2, should_cover_items: bool = false) -> bool:
	return (StateMap[_location.x][_location.y] != null) and (should_cover_items or ItemMap[_location.x][_location.y] != null)

func get_object(x:int,y:int) -> Node:
	if ( x < 0 or y < 0 ): return null
	if ( x + 1 > StateMap.size() or y+1 > StateMap[x].size()): return null
	return StateMap[x][y]
	
func get_item(x:int,y:int) -> Node:
	if ( x < 0 or y < 0 ): return null
	if ( x + 1 > ItemMap.size() or y+1 > ItemMap[x].size()): return null
	return ItemMap[x][y]

func set_tile(x:int,y:int,val:Node, is_item:bool=false,move_sprite:bool = true, hide_tile:bool=false) -> bool:
	var Map
	if is_item: Map = ItemMap
	else: Map = StateMap
	if ( x < 0 or y < 0 ): return false
	if ( x + 1 > Map.size() or y+1 > Map[x].size()): return false
	Map[x][y] = val
	if Globals.verbose_movements:
		var val_name = "nan"
		if is_instance_valid(val): val_name = val.get_class()
		var debug_map = ""
		print("mapping "+val_name+" "+str(x)+" "+str(y))
		for y_i in range(max(0,y-2),min(Map[0].size(),y+3),1):
			for x_i in range(max(0,x-2),min(Map.size(),x+3),1):
	#			print(str(x_i)+" "+str(y_i))
				var obj
				if is_item: obj = get_item(x_i,y_i)
				else: obj = get_object(x_i,y_i)
				if not is_instance_valid(obj): debug_map += "."
				else: debug_map += obj.get_class()[0]
			debug_map += "\n"
		print (debug_map)
	if (is_instance_valid(val)):
		val.tile_x = x
		val.tile_y = y
		if move_sprite: val.set_position( _get_tile_pos(Vector2(x,y), GroundTileMap) )
		if hide_tile: val.hide()
		else: val.show()
	return true

func swap_tile(from_x:int, from_y:int, to_x:int, to_y:int, move_sprite = true) -> bool:
	# Swaps two tiles in the state map. Does not touch the item map.
	if ( from_x < 0 or from_y < 0 ): return false
	if ( from_x + 1 > StateMap.size() or from_y+1 > StateMap[from_x].size()): return false
	if ( to_x < 0 or to_y < 0 ): return false
	if ( to_x + 1 > StateMap.size() or to_y+1 > StateMap[to_x].size()): return false
	var from = get_object(from_x,from_y)
	var to = get_object(to_x,to_y)
	return set_tile(to_x,to_y,from,false,move_sprite) and set_tile(from_x,from_y,to,false,move_sprite)

func map_tile_to_global(x:int, y:int) -> Vector2:
	return _get_tile_pos(Vector2(x,y),GroundTileMap)


func get_enemy_info(level):
	var floater_chance = 0
	if level <= 11: 
		floater_chance = clamp(0.075*(level +1), 0, 0.40)
	else: 
		floater_chance = clamp(0.65-0.03*(level + 1), 0.25, 0.40)
	var chaser_chance = clamp(0.075*(level - 1), 0, 0.40)
	var player_count = 0
	var sum_player_levels = 0
	if Globals.player_one and is_instance_valid(Globals.player_one) and Globals.player_one.is_alive:
		player_count += 1
		sum_player_levels += Globals.player_one.level
	if Globals.player_two and is_instance_valid(Globals.player_two) and Globals.player_two.is_alive:
		player_count += 1
		sum_player_levels += Globals.player_two.level
	var min_enemy_count = int(min(15, 8+(level-1) * 1))
	var max_enemy_count = int(min(20, 10+(level-1) * 1))
	return {'Floater': floater_chance, 'Chaser': chaser_chance, 
			'Min Level': max(1,int(sum_player_levels/player_count)), 
			'Max Level': max(int(sum_player_levels/player_count+1), level), 
			'Enemy Count': randi() % (max_enemy_count - min_enemy_count) + min_enemy_count}
