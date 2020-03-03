extends TextureProgress


var is_first_player


# Called when the node enters the scene tree for the first time.
func _ready():
	is_first_player = true


func initialize(current, maximum):
	max_value = maximum
	value = current
	
func on_player_health_change(health_data):
	var target_health = health_data[0]
	var max_health = health_data[1]
	max_value = max_health
#		value = target_experience
	yield(animate_value(target_health), "completed")
	
func animate_value(target, tween_duration = 0.05):
	$Tween.interpolate_property(self, 'value', value, target, tween_duration, 
		Tween.TRANS_SINE, Tween.EASE_IN_OUT)
	$Tween.start()
	yield($Tween, "tween_completed")
