extends Button


# Declare member variables here. Examples:
# var a = 2
# var b = "text"


# Called when the node enters the scene tree for the first time.
func _ready():
	set_players( Globals.num_players )
	pass # Replace with function body.

func _pressed():
	if Globals.num_players==1:
		set_players(2)
	else:
		set_players(1)

func set_players(num: int):
	if num == 1 : 
		set_text("Players: 1")
	else:
		set_text("Players: 2")
	Globals.num_players = num
# Called every frame. 'delta' is the elapsed time since the previous frame.
#func _process(delta):
#	pass
