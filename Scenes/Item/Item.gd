extends Node2D
class_name Item

const ATTACK = preload("res://Scenes/Attack/Attack.tscn")

func is_class(type): return type == "Item" or .is_class(type)
func    get_class(): return "Item"

var type
var tile_x
var tile_y

# Declare member variables here. Examples:
# var a = 2
# var b = "text"


# Called when the node enters the scene tree for the first time.
func _ready():
	$Sprite.texture = type_texture()
	pass # Replace with function body.


# Called every frame. 'delta' is the elapsed time since the previous frame.
#func _process(delta):
#	pass

func use(user:Node) -> bool:
	if (!user): return false
	match type:
		Globals.ItemType.key: return false
		Globals.ItemType.chest: return false
		Globals.ItemType.potion:
			if (user.is_class("Player")):
				user.health = user.health_max
				user.update_health_status()
				queue_free()
			return true
		Globals.ItemType.fire:
			for x_i in range(user.tile_x-1,user.tile_x+2,1):
				for y_i in range(user.tile_y-1,user.tile_y+2,1):
					if x_i == user.tile_x and y_i == user.tile_y: continue
					var attack = ATTACK.instance()
					attack.tile_x = x_i
					attack.tile_y = y_i
					get_node('/root/Level').add_child(attack)
					queue_free()
			return true
	return false

func type_string() -> String:
	match type:
		Globals.ItemType.key: return "Key"
		Globals.ItemType.chest: return "Chest"
		Globals.ItemType.potion: return "Potion"
		Globals.ItemType.fire: return "Greek Fire"
	return ""
	
func type_description() -> String:
	match type:
		Globals.ItemType.key: return "A Key! This is the key that can open the next door. Run into the door to use the key."
		Globals.ItemType.chest: return "There could be anything in this chest. It could even be another chest. "
		Globals.ItemType.potion: return "Potent pick-me-up potion promises perfect pulminatory points."
		Globals.ItemType.fire: return "Greek Fire burns green and is hot to the touch."
	return ""

func type_texture() -> Texture:
	match type:
		Globals.ItemType.key:
			return preload("res://Scenes/Item/Key.svg")
		Globals.ItemType.chest:
			return preload("res://Scenes/Item/Chest.svg")
		Globals.ItemType.potion:
			return preload("res://Scenes/Item/Potion.png")
		Globals.ItemType.fire:
			return preload("res://Scenes/Item/GreekFire.png")
	return null
