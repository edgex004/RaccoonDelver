extends PopupDialog


# Declare member variables here. Examples:
# var a = 2
# var b = "text"
var model_name
var direction = PI/2
var rot_radius = .1
var x_direction = -rot_radius
var z_direction = rot_radius

var page = 0

var page_text = ["Delve into the deep, dark dungeon and fight fiendish foes with your raccoon brethren.",
				"Move to the beat as you explore the dungeon and attack your enemies with the arrow keys (first player) or WADS (second player) or connect and use controllers. \n\nAttack by running into your enemies, while they try to run into you!",
				"Find potions and items to aid you in your quest! Use Shift to cycle items and Space to use them (Q and E for player 2).\n\nOn controllers, the shoulder buttons cycle and the action button activates the item.",
				"Attack your foe with your raccoon friend simultaneously for a critical hit!\n\nFind the key to delve deeper into the dungeon to continue your journey!"]

# Called when the node enters the scene tree for the first time.
func _ready():
	connect("about_to_show", self, "Dialog_about_to_show")
	connect("popup_hide", self, "Dialog_about_to_hide")
	$VBoxContainer/CenterContainer/Button.connect("pressed", self,"next")
	$Tween.connect("tween_all_completed", self, "on_tween_complete")

# Called every frame. 'delta' is the elapsed time since the previous frame.
func next():
	if page < 3:
		page += 1
		$VBoxContainer/HBoxContainer/RichTextLabel.set_text(page_text[page])
	else:
		hide()

func set_model(name: String):
#	my_texture = texture
#	$VBoxContainer/HBoxContainer/CenterContainer/ViewportContainer/Viewport/ItemDisplay.add_child(texture)
#	var obj = get_node("VBoxContainer/HBoxContainer/CenterContainer/ViewportContainer/Viewport/" + name )
	var obj = get_node("VBoxContainer/HBoxContainer/CenterContainer/ViewportContainer/Viewport/" + name )
	if (is_instance_valid(obj)):
		obj.show()
		var obj2 = get_node("VBoxContainer/HBoxContainer/CenterContainer/ViewportContainer/Viewport/" + name +"/Body")
		$VBoxContainer/HBoxContainer/CenterContainer/ViewportContainer.show()
		model_name = name
		$Tween.interpolate_property(obj2, "rotation:y", obj2.rotation.y, direction, 5/2, Tween.TRANS_LINEAR, Tween.EASE_IN_OUT)
		$Tween.interpolate_property(obj2, "translation:x", 0,-rot_radius, 5/2, Tween.TRANS_SINE, Tween.EASE_IN_OUT)
		$Tween.interpolate_property(obj2, "translation:z", -rot_radius,0 , 5/2, Tween.TRANS_SINE, Tween.EASE_IN_OUT)
		$Tween.start()
#	if texture: $VBoxContainer/HBoxContainer/CenterContainer/ViewportContainer.show()
#	else: $VBoxContainer/HBoxContainer/CenterContainer/ViewportContainer.hide()


func Dialog_about_to_show():
	page = 0
	$VBoxContainer/HBoxContainer/RichTextLabel.set_text(page_text[page])
	
func Dialog_about_to_hide():
	$Tween.stop_all()
	$VBoxContainer/HBoxContainer/RichTextLabel.set_text("")
	$VBoxContainer/HBoxContainer/CenterContainer/ViewportContainer.hide()
	direction = PI/2
	rot_radius = .1
	if (!model_name): return
	var obj = get_node("VBoxContainer/HBoxContainer/CenterContainer/ViewportContainer/Viewport/" + model_name )
	if (is_instance_valid(obj)):
		obj.hide()
		model_name = null

func on_tween_complete():
	var obj2 = get_node("VBoxContainer/HBoxContainer/CenterContainer/ViewportContainer/Viewport/" + model_name +"/Body")
	var cur_pos = obj2.get_translation()
	var x_temp = cur_pos.x + x_direction
	var z_temp = cur_pos.z + z_direction
	var x_ease = Tween.EASE_IN
	var z_ease = Tween.EASE_IN
	if abs(x_temp) > rot_radius+.01:
		x_direction *= -1
		x_temp += 2*x_direction
		x_ease = Tween.EASE_OUT
	if abs(z_temp) > rot_radius+.01:
		z_direction *= -1
		z_temp += 2*z_direction
		z_ease = Tween.EASE_OUT
	direction+=PI/2
	$Tween.interpolate_property(obj2, "rotation:y", obj2.rotation.y, direction, 5/2, Tween.TRANS_LINEAR, Tween.EASE_OUT_IN)
	$Tween.interpolate_property(obj2, "translation:x", cur_pos.x, x_temp, 5/2, Tween.TRANS_LINEAR, x_ease)
	$Tween.interpolate_property(obj2, "translation:z", cur_pos.z, z_temp, 5/2, Tween.TRANS_LINEAR, z_ease)
	$Tween.start()
	
