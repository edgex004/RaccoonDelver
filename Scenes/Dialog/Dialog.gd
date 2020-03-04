extends PopupDialog


# Declare member variables here. Examples:
# var a = 2
# var b = "text"

# Called when the node enters the scene tree for the first time.
func _ready():
	connect("about_to_show", self, "Dialog_about_to_show")
	connect("popup_hide", self, "Dialog_about_to_hide")


# Called every frame. 'delta' is the elapsed time since the previous frame.
func _process(delta):
	if Input.is_action_just_pressed("player1_use_item") or Input.is_action_just_pressed("player2_use_item"):
		hide()

func set_text(text: String):
	$VBoxContainer/HBoxContainer/RichTextLabel.set_text(text)

func set_texture(texture: Texture):
	$VBoxContainer/HBoxContainer/CenterContainer/TextureRect.set_texture(texture)
	if texture: $VBoxContainer/HBoxContainer/CenterContainer/TextureRect.show()
	else: $VBoxContainer/HBoxContainer/CenterContainer/TextureRect.hide()
	
func Dialog_about_to_show():
	get_node("/root/Level/Beat").set_paused(true)

func Dialog_about_to_hide():
	get_node("/root/Level/Beat").set_paused(false)
	$VBoxContainer/HBoxContainer/RichTextLabel.set_text("")
	$VBoxContainer/HBoxContainer/CenterContainer/TextureRect.hide()
