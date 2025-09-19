class_name MusicPlayer
extends Node

@onready var audio_stream_player: AudioStreamPlayer = $AudioStreamPlayer
var audio_stream_interactive: AudioStreamInteractive

var master_bus_index = AudioServer.get_bus_index("Master")
var music_bus_index = AudioServer.get_bus_index("Music")
var sfx_bus_index = AudioServer.get_bus_index("SFX")
var ambience_bus_index = AudioServer.get_bus_index("Ambience")
var open_ibrary_door: bool = false
func _ready() -> void:
	Util.set_sample_type_if_web(audio_stream_player)
	process_mode = Node.PROCESS_MODE_ALWAYS
	
	if !audio_stream_player.stream is AudioStreamInteractive:
		push_warning("this resource should be an audiostream interactive")
	
	audio_stream_interactive = audio_stream_player.stream as AudioStreamInteractive	
	
	GameState.music_player = self
	audio_stream_player.play()
	GameState.door_count_music_increase.connect(progress_music)

func progress_music(_numdoors: int,_room_type:GameState.RoomType) -> void:
	var playback: AudioStreamPlaybackInteractive = audio_stream_player.get_stream_playback()
	if _room_type == GameState.RoomType.LIBRARY:
		playback.switch_to_clip_by_name("library (silence)")
		open_ibrary_door = true
	elif!open_ibrary_door:
		var transition_name: String = "Intro 0"+ str(_numdoors) 
		playback.switch_to_clip_by_name(transition_name)

func _input(event):
	if event.is_action_pressed ("ui_mute"):
		AudioServer.set_bus_mute(master_bus_index, !AudioServer.is_bus_mute(master_bus_index))
		print("audio toggle")

func _on_master_fader_value_changed(value: float) -> void:
	AudioServer.set_bus_volume_db(AudioServer.get_bus_index("Master"), linear_to_db(value))

func _on_sfx_fader_value_changed(value: float) -> void:
	AudioServer.set_bus_volume_db(AudioServer.get_bus_index("SFX"), linear_to_db(value))

func _on_music_fader_value_changed(value: float) -> void:
	AudioServer.set_bus_volume_db(AudioServer.get_bus_index("Music"), linear_to_db(value))

func _on_ambience_fader_value_changed(value: float) -> void:
	AudioServer.set_bus_volume_db(AudioServer.get_bus_index("Ambience"), linear_to_db(value))
	
