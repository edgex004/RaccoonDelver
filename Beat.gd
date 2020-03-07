extends Timer

var BPM = 100.0
var MUSIC_BPM = 120.0
var MAX_BPM = 240.0
var END_SONG_TOL_SEC = 2
var should_swallow_beats = false

var player_timer
signal beat_timeout
signal player_beat_timeout

# Declare member variables here. Examples:
# var a = 2
# var b = "text"
func set_up_music(bpm_adjustment: float = 0):
	BPM+=bpm_adjustment
	BPM=min(BPM,MAX_BPM)
	$Music.set_pitch_scale(BPM/MUSIC_BPM)
	$Music.play()
	connect("timeout", self,"on_beat_timeout")
	wait_time = 60.0 / BPM
	player_timer.wait_time = wait_time/4

# Called when the node enters the scene tree for the first time.
func _ready():
	player_timer = Timer.new()
	player_timer.one_shot = true
	player_timer.connect("timeout", self, "_on_player_Beat_timeout")
	add_child(player_timer)

	

func set_paused(is_paused: bool):
	should_swallow_beats = is_paused

# Called every frame. 'delta' is the elapsed time since the previous frame.
#func _process(delta):
#	pass

func on_beat_timeout():
	if(!should_swallow_beats): emit_signal("beat_timeout")
	if($Music.stream.get_length() - $Music.get_playback_position() < END_SONG_TOL_SEC ):
		$Music.play()
	player_timer.start()


func _on_player_Beat_timeout():
	if(!should_swallow_beats): emit_signal("player_beat_timeout")
