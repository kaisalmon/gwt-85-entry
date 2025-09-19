extends Node3D

var fadein_time = 0.8
var timer = 0.0

func _ready() -> void:
	$CanvasLayer/Fadeout.color.a = 1.0
	_late_ready.call_deferred()
	GameState.new_door_unlocked.connect(show_ending)

func _late_ready() -> void:
	var has_loaded = false
	if GameState.load_game_at_start:
		has_loaded = load_game()
	if !has_loaded:
		show_intro()
	
func load_game() -> bool:
	return SaveGame.load_from_file()
	
func save_game() -> void:
	SaveGame.save_to_file()
	
func _process(delta: float) -> void:
	if timer < fadein_time:
		timer += delta
		$CanvasLayer/Fadeout.color.a = lerp(1.0, 0.0, timer / fadein_time)
		
func show_intro() -> void:
	GameState.ui.show_text(tr("dialogue.intro.1"))
	await GameState.ui.current_text_finished
	await get_tree().create_timer(1.0).timeout
	GameState.ui.show_text(tr("dialogue.intro.2"))


func show_ending(_numdoors: int, room_type:GameState.RoomType) -> void:
	if room_type == GameState.RoomType.LIBRARY:
		await get_tree().create_timer(5.0).timeout
		GameState.ui.show_text(tr("dialogue.ending.1"))
		await GameState.ui.current_text_finished
		await get_tree().create_timer(1.0).timeout
		GameState.ui.show_text(tr("dialogue.ending.2"))
