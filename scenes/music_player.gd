class_name MusicPlayer
extends Node

@onready var audio_stream_player: AudioStreamPlayer = $AudioStreamPlayer
var audio_stream_interactive: AudioStreamInteractive

func _ready() -> void:
	
	process_mode = Node.PROCESS_MODE_ALWAYS
	
	if !audio_stream_player.stream is AudioStreamInteractive:
		push_warning("this resource should be an audiostream interactive")
	
	audio_stream_interactive = audio_stream_player.stream as AudioStreamInteractive	
	
	GameState.music_player = self
	audio_stream_player.play()

func progress_music(_room_type:GameState.RoomType) -> void:
	var playback: AudioStreamPlaybackInteractive = audio_stream_player.get_stream_playback()
	playback.switch_to_clip_by_name("Intro02")


  
