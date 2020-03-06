extends Spatial

export (float) var turn_time = .15 # seconds

func set_facing(_direction : Vector2):
	var facing_angle = _direction.angle()
	$TurnTween.interpolate_property($Body, "rotation:y", 
	$Body.rotation.y, (PI/2 - facing_angle), turn_time, Tween.TRANS_SINE, Tween.EASE_IN)
	$TurnTween.start()
