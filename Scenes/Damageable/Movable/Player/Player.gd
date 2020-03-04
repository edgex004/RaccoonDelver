extends "../Movable.gd"
class_name Player

func is_class(type): return type == "Player" or .is_class(type)
func    get_class(): return "Player"

const DISAPEAR_LABEL = preload("res://Scenes/DisapearingLabel/DisapearingLabel.tscn")

var beat_counter = 0
var is_first_player : bool = true

# Levelling stats
# export var level = 1 (defined in Moveable)
export var experience = 0

# Experience required equation: a * level + level ^ b + base
var exp_req_lin_coef = 7.5
var exp_req_pow_coef = 2.25
var exp_req_base = 50
var experience_required = _get_experience_required(level + 1)
var experience_total = 0

# Damage variables
var damage_lin_coef = 10
var damage_base = 10

# Health variables
var health_lin_coef = 10
var health_base = 100

var max_items = 3
var items = []
var previous_items = []
var item_guis
var selected_item = 0

signal player_experience_gained(growth_data)
signal health_change(health_data)
signal hit_floor_door

var has_moved = false
var player1_inputs = {"player1_left": Vector2.LEFT,
						"player1_right": Vector2.RIGHT,
						"player1_up": Vector2.UP,
						"player1_down": Vector2.DOWN}
var player2_inputs = {"player2_left": Vector2.LEFT,
						"player2_right": Vector2.RIGHT,
						"player2_up": Vector2.UP,
						"player2_down": Vector2.DOWN}

# Called when the node enters the scene tree for the first time.
func _ready():
	update_player_stats()
	health = health_max
	for i in range(max_items): items.push_back(null)
	item_guis[0].set_selected(true)

func pick_up_item(item: Node) -> bool:
	if not item.type in previous_items:
		$Dialog.set_texture( item.type_texture())
		$Dialog.set_text(item.type_description())
		$Dialog.popup()
		previous_items.push_back(item.type)
	#Returns true if item was picked up. Base type does not pick up.
	for i in range(items.size()-1):
		if items[i] == null:
			items[i]=item
			item.get_parent().remove_child(item)
			if i > item_guis.size() - 1:
				item.hide()
				add_child(item)
			else:
				item_guis[i].add_child(item)
				item.show()
				item.set_position(item_guis[i].get_rect().size/2)
			get_node('/root/Level').set_tile(item.tile_x,item.tile_y, null)
			var label = DISAPEAR_LABEL.instance()
			label.set_size(Vector2(64,16))
			label.add_text(item.type_string() + "!")
			add_child(label)
			return true
	return false
	
func open_door(door: Node):
	# If your player/monster can do this, override
	if door.is_open:
		emit_signal("hit_floor_door")
	else:
		for i in range(items.size()):
			if is_instance_valid(items[i]) and items[i].type == Globals.ItemType.key:
				door.set_open(true)
				items[i].queue_free()
				items[i]=null
				break
	pass
	
func _process(delta):
	if !is_alive: return
	var next_item = "player1_next_item"
	if not is_first_player:
		next_item = "player2_next_item"
	if Input.is_action_just_pressed(next_item):
		for index in item_guis: index.set_selected(false)
		selected_item = (selected_item + 1) % max_items
		item_guis[selected_item].set_selected(true)
	if not (has_moved):
		var input_map = player1_inputs
		var use_item = "player1_use_item"
		if not is_first_player:
			input_map = player2_inputs
			use_item = "player2_use_item"
		for dir in input_map.keys():
			if Input.is_action_pressed(dir):
				move_tile(input_map[dir], 1)
				has_moved = true
		if Input.is_action_pressed(use_item) and is_instance_valid(items[selected_item]):
			if(items[selected_item].use(self)): 
				items[selected_item].queue_free()
				items[selected_item]=null
			has_moved = true

func _on_Beat_timeout():
	var beats_dict = {0: ".", 1: "..", 2: "..."}
	print("Beat Happened" + beats_dict[beat_counter])
	beat_counter = (beat_counter + 1) % 3
	has_moved = false


func _get_experience_required(level):
	return round(pow(level, exp_req_pow_coef) + level * exp_req_lin_coef + exp_req_base)
	
func gain_experience(value):
	experience += value
	experience_total += value
	var growth_data = []
	while experience >= experience_required:
		experience -= experience_required
		growth_data.append([experience_required, experience_required])
		level_up()
	growth_data.append([experience, experience_required])
	emit_signal("player_experience_gained", growth_data)

func level_up():
	level += 1
	experience_required = _get_experience_required(level + 1)
	#var stats = ['damage', 'health_max']
	#var random_stat = stats[randi() % stats.size()]
	#set(random_stat, get(random_stat) + 1)
	update_player_stats()
	#restore health to full on leveling
	health = health_max
	update_health_status()

func update_player_stats():
	health_max = health_base + health_lin_coef * (level-1)
	damage = damage_base + damage_lin_coef * (level-1)

func update_health_status():
	emit_signal("health_change", [health, health_max])
