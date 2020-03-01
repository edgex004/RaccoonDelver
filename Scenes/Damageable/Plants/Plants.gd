extends Damageable


# Declare member variables here. Examples:
# var a = 2
# var b = "text"


# Called when the node enters the scene tree for the first time.
func _ready():
	var rand_sprite = randi() % 3
	match rand_sprite:
		0:
			get_node('Sprite').texture = preload('res://Objects/Object2.png')
		1:
			get_node('Sprite').texture = preload('res://Objects/Object3.png')
		2:
			get_node('Sprite').texture = preload('res://Objects/Object4.png')


# Called every frame. 'delta' is the elapsed time since the previous frame.
#func _process(delta):
#	pass
