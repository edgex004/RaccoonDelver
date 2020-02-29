extends Node2D


var tilesize = 32



# Called when the node enters the scene tree for the first time.
func _ready():
	get_parent().connect("beat", self, "_on_Beat_timeout")


# Called every frame. 'delta' is the elapsed time since the previous frame.
#func _process(delta):
#	pass


func _on_Beat_timeout():
	print("Beat Happened...")
