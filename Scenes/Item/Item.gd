extends Node2D
class_name Item

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
	match type:
		Globals.ItemType.key:
			$Sprite.texture = preload("res://Scenes/Item/Key.svg")
		Globals.ItemType.chest:
			$Sprite.texture = preload("res://Scenes/Item/Chest.svg")
	pass # Replace with function body.


# Called every frame. 'delta' is the elapsed time since the previous frame.
#func _process(delta):
#	pass
