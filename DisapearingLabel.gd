extends RichTextLabel


# Declare member variables here. Examples:
# var a = 2
# var b = "text"
var move_time = 1

# Called when the node enters the scene tree for the first time.
func _ready():
	set_position(Vector2(-5,0))
	var cur_pos = get_position()
	var desired_pos = cur_pos + Vector2(0,-32)
	print("cur_pos = " + str(cur_pos))
	print("desired_pos = " + str(desired_pos))
	var TweenNode = Tween.new()
	TweenNode.interpolate_property(self, "rect_position", cur_pos, desired_pos, move_time, Tween.TRANS_LINEAR, Tween.EASE_IN)
	TweenNode.connect("tween_all_completed", self, "queue_free")
	add_child(TweenNode)
	TweenNode.start()
	pass # Replace with function body.


# Called every frame. 'delta' is the elapsed time since the previous frame.
#func _process(delta):
#	pass
