extends CanvasLayer

@export var new_game_deletes_old_save: bool = true

@export_file("*.tscn") var start_game_scene_path: String
@export_category("internal nodes")
@export var start_menu_mc: MarginContainer
@export var continue_button: Button
@export var quit_button: Button
@export var settings_ui: SettingsUI

@onready var click: AudioStreamPlayer = $click
@onready var hover: AudioStreamPlayer = $hover

var starting_game = false
var new_game_timer = 0.0
var timer = 0.0
var fadeout_duration = 0.8

func _ready() -> void:
	process_mode = ProcessMode.PROCESS_MODE_ALWAYS
	get_tree().paused = false
	settings_ui.visible = false
	start_menu_mc.visible = true
	continue_button.visible = SaveGame.is_savegame_available
	quit_button.visible = !Util.is_web_build()
	
func _process(delta: float) -> void:
	timer += delta
	if starting_game:
		new_game_timer -= delta
		$Fadeout.color.a = lerp(0.0, 1.0, (fadeout_duration - new_game_timer) / fadeout_duration)
		if new_game_timer <= 0.0:
			get_tree().change_scene_to_file(start_game_scene_path)
	else:
		$Fadeout.color.a = lerp(0.0, 1.0, (fadeout_duration - timer) / fadeout_duration)


func _on_new_game_button_pressed() -> void:
	click.play()
	if new_game_deletes_old_save:
		SaveGame.delete_savegame()
	
	starting_game = true
	GameState.load_game_at_start = false
	new_game_timer = fadeout_duration
	
func _on_continue_button_pressed() -> void:
	click.play()
	starting_game = true
	new_game_timer = fadeout_duration
	GameState.load_game_at_start = true

func _on_settings_button_pressed() -> void:
	click.play()
	settings_ui.visible = true
	start_menu_mc.visible = false
	
func _on_credits_button_pressed() -> void:
	click.play()
	pass # Replace with function body.

func _on_quit_button_pressed() -> void:
	click.play()
	get_tree().quit()

func _on_settings_ui_back_pressed() -> void:
	click.play()
	settings_ui.visible = false
	start_menu_mc.visible = true


func _on_continue_button_mouse_entered() -> void:
	hover.play()
	pass # Replace with function body.


func _on_new_game_button_mouse_entered() -> void:
	hover.play()
	pass # Replace with function body.


func _on_settings_button_mouse_entered() -> void:
	hover.play()
	pass # Replace with function body.


func _on_credits_button_mouse_entered() -> void:
	hover.play()
	pass # Replace with function body.


func _on_quit_button_mouse_entered() -> void:
	hover.play()
	pass # Replace with function body.
