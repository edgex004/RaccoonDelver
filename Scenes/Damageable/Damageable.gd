extends Area2D
class_name Damageable 

func is_class(type): return type == "Damageable" or .is_class(type)
func    get_class(): return "Damageable"

const DAMAGE_LABEL = preload("res://Scenes/DisapearingLabel/DisapearingLabel.tscn")
const ITEM = preload("res://Scenes/Item/Item.tscn")

var tilesize = 32
var tile_x
var tile_y

var is_alive = true

var health = 5.0
var health_max = 100.0
var experience_on_kill = 0

const BACKGROUND_COL_MASK = 1 # 2^0
const PLAYER_COL_MASK = 2 # 2^1
const ENEMY_COL_MASK = 4 # 2^2

var treasures = []
var treasure_rates = []

var was_hit : bool = false

# Called when the node enters the scene tree for the first time.
func _ready():
	$HealthBar.hide()


# Called every frame. 'delta' is the elapsed time since the previous frame.
#func _process(delta):
#	pass
func take_damage(base_damage, source):
	var my_col_mask = get_collision_mask()
	var source_col_mask
	if not source.is_class("Attack"):
		source_col_mask = source.get_collision_mask()

	if source.is_class("Attack") or not ((my_col_mask == source_col_mask) or (
		(my_col_mask == BACKGROUND_COL_MASK) and (source_col_mask == ENEMY_COL_MASK))):
		
		var damage = base_damage
		var critical_hit : bool = false
		if my_col_mask == ENEMY_COL_MASK:
			print("Taking damage. Was_hit = " + str(was_hit))
			if was_hit:
				damage = base_damage * 2
				critical_hit = true
			else:
				was_hit = true
			print("My col mask: " + str(my_col_mask) + ". Base damage: " + str(base_damage) + ". Final damage: " + str(damage))
		
		health -= damage
		update_health_status()
		var label = DAMAGE_LABEL.instance()
		label.set_size(Vector2(32,16))
		label.add_text( "-" + str(damage))
		if critical_hit:
			print("setting color")
			label.set("custom_colors/default_color", Color( 0.75, 0, 0, 1))
		add_child(label)
		
		print("damaged by: " + str(source.get_class()))
		print("IAMA: " + str(self.get_class()))
		print("My health = " + str(health))
		if health <= 0:
			is_alive = false
			# Send experience to the attacker
			if source.has_method('gain_experience'):
				source.gain_experience(experience_on_kill)
			
			get_node('/root/Level').set_tile(tile_x,tile_y,null)
			
#			$Damage.connect("finished", self, "queue_free") # This doesn't work if the damage SFX are commented out 
			
			if (treasures.size() > 0) and not is_instance_valid(get_node('/root/Level').get_item(tile_x,tile_y)):
				assert (treasures.size() == treasure_rates.size())
				var num = randf()
				var sum = 0
				for i in range(treasure_rates.size()):
					sum += treasure_rates[i]
					if num < sum:
						var dropped_item = ITEM.instance()
						dropped_item.type = treasures[i]
						get_node('/root/Level').set_tile(tile_x,tile_y,dropped_item,true)
						get_node('/root/Level/YSort').add_child(dropped_item)
						break
			queue_free()
func place_tile(x:int, y:int):
	tile_x = x
	tile_y = y
	show()

func update_health_status():
	pass
