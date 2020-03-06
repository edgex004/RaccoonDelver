extends Damageable








func _ready():
	var rand_sprite = randi() % 37
	var sprite_resource = "res://Scenes/Damageable/Plants/CreepyPlant%04d.png" % rand_sprite
	get_node('Sprite').texture = load(sprite_resource)






