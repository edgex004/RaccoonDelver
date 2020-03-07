extends Popup

# Called when the node enters the scene tree for the first time.
func _ready():
#	$ColorRect/VBoxContainer/Vboxcontainer/CenterContainer4/Players.connect("pressed", self,"restart")
	$ColorRect/VBoxContainer/Vboxcontainer/CenterContainer3/Exit.connect("pressed", self,"exit")
	$ColorRect/VBoxContainer/Vboxcontainer/CenterContainer5/Start.connect("pressed", self,"start")
	$ColorRect/VBoxContainer/Vboxcontainer/CenterContainer6/Instructions.connect("pressed", self, "instructions")

	$ColorRect/VBoxContainer/Vboxcontainer/CenterContainer7/Credits.connect("pressed", self, "credits")
	popup(Rect2(0,0,1024,600))
	pass

func start():
	get_tree().change_scene("res://Level.tscn")
	
func exit():
	get_tree().quit()

func instructions():
		$InstructionDialog.set_model( "Raccoon")
		$InstructionDialog.popup()
		
func credits():
		$CreditsDialog.set_model( "Floater")
		$CreditsDialog.popup()

