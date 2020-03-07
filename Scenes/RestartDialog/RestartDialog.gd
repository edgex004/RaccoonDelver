extends PopupDialog

var should_show_continue = false

# Called when the node enters the scene tree for the first time.
func _ready():
	$VBoxContainer/HBoxContainer2/CenterContainer4/Restart.connect("pressed", self,"restart")
	$VBoxContainer/HBoxContainer2/CenterContainer3/Exit.connect("pressed", self,"exit")
	$VBoxContainer/HBoxContainer2/CenterContainer5/Continue.connect("pressed", self,"should_continue")
	connect("about_to_show", self,"dialog_about_to_show")
	$Tween.connect("tween_all_completed", self, "on_tween_complete")

func restart():
	get_tree().change_scene("res://Level.tscn")
	
func exit():
	get_tree().change_scene("res://Scenes/FirstStartDialog/FirstStartDialog.tscn")

func should_continue():
	$VBoxContainer/HBoxContainer2/CenterContainer5/Continue.hide()
	should_show_continue = false
	hide()
	get_node('/root/Level/Beat').set_paused(false)

	
func dialog_about_to_show():
	if should_show_continue:
		$VBoxContainer/HBoxContainer2/CenterContainer5/Continue.show()
