extends Permanent
class_name FloorDoor

func is_class(type): return type == "FloorDoor" or .is_class(type)
func    get_class(): return "FloorDoor"

var is_open

# Declare member variables here. Examples:
# var a = 2
# var b = "text"


# Called when the node enters the scene tree for the first time.
func _ready():
	set_open(false)
	pass # Replace with function body.


# Called every frame. 'delta' is the elapsed time since the previous frame.
#func _process(delta):
#	pass

func set_open(open:bool):
	is_open = open
	if open :
		$Open.show()
		$Closed.hide()
	else:
		$Open.hide()
		$Closed.show()
