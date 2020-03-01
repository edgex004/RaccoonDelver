extends Timer

var BPM = 100.0
var MUSIC_BPM = 120.0
var END_SONG_TOL_SEC = 2

# Declare member variables here. Examples:
# var a = 2
# var b = "text"


# Called when the node enters the scene tree for the first time.
func _ready():
	$Music.set_pitch_scale(BPM/MUSIC_BPM)
#	$Music.set_pitch_scale(3)
	$Music.play()
	connect("timeout", self,"on_beat_timeout")
	wait_time = 60.0 / BPM



# Called every frame. 'delta' is the elapsed time since the previous frame.
#func _process(delta):
#	pass

func on_beat_timeout():
	if($Music.stream.get_length() - $Music.get_playback_position() < END_SONG_TOL_SEC ):
		$Music.play()
