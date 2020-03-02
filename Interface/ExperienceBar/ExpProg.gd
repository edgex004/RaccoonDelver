extends TextureProgress


var is_first_player


# Called when the node enters the scene tree for the first time.
func _ready():
	is_first_player = true


func initialize(current, maximum):
	max_value = maximum
	value = current
	
func on_player_experience_gain(growth_data):
	for line in growth_data:
		#if is_first_player == line[0]:
		var target_experience = line[0]
		var max_experience = line[1]
		max_value = max_experience
#		value = target_experience
		yield(animate_value(target_experience), "completed")
		if abs(max_value - value) < 0.01:
			value = min_value
	
func animate_value(target, tween_duration = 0.05):
	$Tween.interpolate_property(self, 'value', value, target, tween_duration, 
		Tween.TRANS_SINE, Tween.EASE_IN_OUT)
	$Tween.start()
	yield($Tween, "tween_completed")
