extends PopupDialog


# Declare member variables here. Examples:
# var a = 2
# var b = "text"
var model_name
var direction = PI/2
var rot_radius = .1
var x_direction = -rot_radius
var z_direction = rot_radius

# Called when the node enters the scene tree for the first time.
func _ready():
	connect("about_to_show", self, "Dialog_about_to_show")
	connect("popup_hide", self, "Dialog_about_to_hide")
	$Tween.connect("tween_all_completed", self, "on_tween_complete")

# Called every frame. 'delta' is the elapsed time since the previous frame.
func _process(delta):
	if Input.is_action_just_pressed("player1_use_item") or Input.is_action_just_pressed("player2_use_item"):
		hide()

func set_text(text: String):
	$VBoxContainer/HBoxContainer/RichTextLabel.set_text(text)

func set_model(name: String):
#	my_texture = texture
#	$VBoxContainer/HBoxContainer/CenterContainer/ViewportContainer/Viewport/ItemDisplay.add_child(texture)
#	var obj = get_node("VBoxContainer/HBoxContainer/CenterContainer/ViewportContainer/Viewport/" + name )
	var obj = get_node("VBoxContainer/HBoxContainer/CenterContainer/ViewportContainer/Viewport/" + name )
	if (is_instance_valid(obj)):
		obj.show()
		var obj2 = get_node("VBoxContainer/HBoxContainer/CenterContainer/ViewportContainer/Viewport/" + name +"/Item")
		obj2.set_rotation_degrees(Vector3(10,0,0))
		$VBoxContainer/HBoxContainer/CenterContainer/ViewportContainer.show()
		model_name = name
#		$Tween.interpolate_property(self,"rotation_degrees",
#		360,
##		Vector3(rad2deg(facingAngle.x),
##			rad2deg(facingAngle.y),
##			rad2deg(facingAngle.z)),
#		Vector3(0,0,0),
#		2,
#		Tween.TRANS_LINEAR,
#		Tween.EASE_IN_OUT)

		$Tween.interpolate_property(obj2, "rotation:y", obj2.rotation.y, direction, 5/2, Tween.TRANS_LINEAR, Tween.EASE_IN_OUT)
		$Tween.interpolate_property(obj2, "translation:x", 0,-rot_radius, 5/2, Tween.TRANS_SINE, Tween.EASE_IN_OUT)
		$Tween.interpolate_property(obj2, "translation:z", -rot_radius,0 , 5/2, Tween.TRANS_SINE, Tween.EASE_IN_OUT)
		$Tween.start()
#	if texture: $VBoxContainer/HBoxContainer/CenterContainer/ViewportContainer.show()
#	else: $VBoxContainer/HBoxContainer/CenterContainer/ViewportContainer.hide()
	
func Dialog_about_to_show():
	get_node("/root/Level/Beat").set_paused(true)

func Dialog_about_to_hide():
	$Tween.stop_all()
	get_node("/root/Level/Beat").set_paused(false)
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
	var obj2 = get_node("VBoxContainer/HBoxContainer/CenterContainer/ViewportContainer/Viewport/" + model_name +"/Item")
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
	
