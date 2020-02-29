extends Node2D

const PLAYER = preload("res://Scenes/Damageable/Movable/Player/Player.tscn")
const DAMAGEABLE = preload("res://Scenes/Damageable/Damageable.tscn")
const RANDOM_WALKER = preload("res://Scenes/Damageable/Movable/AI/RandomWalker/RandomWalker.tscn")
signal beat

# Called when the node enters the scene tree for the first time.
func _ready():
	$Beat.connect("timeout", self, "_on_Beat_timeout")
	spawnPlayer(464,272)
	spawnDamageable(624,432)
	spawnRandomWalker(688, 176)

# Called every frame. 'delta' is the elapsed time since the previous frame.
#func _process(delta):
#	pass

func _on_Beat_timeout():
	emit_signal("beat")

func spawnPlayer(x,y):
	var player = PLAYER.instance()
	add_child(player)
	player.set_position( Vector2( x, y ))
	connect("beat", player, "_on_Beat_timeout")


func spawnDamageable(x,y):
	var obj = DAMAGEABLE.instance()
	add_child(obj)
	obj.set_position( Vector2( x, y ))
	
func spawnRandomWalker(x,y):
	var obj = RANDOM_WALKER.instance()
	add_child(obj)
	obj.set_position( Vector2( x, y ))
	connect("beat", obj, "_on_Beat_timeout")
