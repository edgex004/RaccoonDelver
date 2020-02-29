extends Node2D

signal beat

# Called when the node enters the scene tree for the first time.
func _ready():
	$Beat.connect("timeout", self, "_on_Beat_timeout")



# Called every frame. 'delta' is the elapsed time since the previous frame.
#func _process(delta):
#	pass


func _on_Beat_timeout():
	emit_signal("beat")
