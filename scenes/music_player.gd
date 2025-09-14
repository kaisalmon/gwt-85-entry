class_name MusicPlayer
extends Node

@onready var audio_stream_player: AudioStreamPlayer = $AudioStreamPlayer
var audio_stream_interactive: AudioStreamInteractive

func _ready() -> void:
	if !audio_stream_player.stream is AudioStreamInteractive:
		push_warning("this resource should be an audiostream interactive")
	
	audio_stream_interactive = audio_stream_player.stream as AudioStreamInteractive	


func _input(event: InputEvent) -> void:
	if event is InputEventKey && (event as InputEventKey).keycode == KEY_SPACE:
		var playback: AudioStreamPlaybackInteractive = audio_stream_player.get_stream_playback()
		playback.switch_to_clip_by_name("Room01")
		test_something()
		
		
func test_something() -> void:
	print("test")
	pass

  
