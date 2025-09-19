extends Node3D

var fadein_time = 0.8
var timer = 0.0

func _ready() -> void:
	$CanvasLayer/Fadeout.color.a = 1.0
	_late_ready.call_deferred()

func _late_ready() -> void:
	if GameState.load_game_at_start:
		load_game()
	
func load_game() -> void:
	SaveGame.load_from_file()
	
func save_game() -> void:
	SaveGame.save_to_file()
	
func _process(delta: float) -> void:
	if timer < fadein_time:
		timer += delta
		$CanvasLayer/Fadeout.color.a = lerp(1.0, 0.0, timer / fadein_time)
		
