extends Area2D

var tilesize = 32

var is_alive = true

var health = 100


# Called when the node enters the scene tree for the first time.
func _ready():
	pass # Replace with function body.


# Called every frame. 'delta' is the elapsed time since the previous frame.
#func _process(delta):
#	pass
func take_damage(damage, source):
	health -= damage
	print("My health = " + str(health))
	if health <= 0:
		is_alive = false
		queue_free()
