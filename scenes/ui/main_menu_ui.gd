extends CanvasLayer

@export var new_game_deletes_old_save: bool = true

@export_file("*.tscn") var start_game_scene_path: String
@export_file("*.tscn") var credits_path: String
@export_category("internal nodes")
@export var start_menu_mc: MarginContainer
@export var continue_button: Button
@export var quit_button: Button
@export var settings_ui: SettingsUI

@onready var click: AudioStreamPlayer = $click
@onready var hover: AudioStreamPlayer = $hover

var starting_game = false
var starting_credits = false
var fadeout_timer = 0.0
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
		fadeout_timer -= delta
		$Fadeout.color.a = lerp(0.0, 1.0, (fadeout_duration - fadeout_timer) / fadeout_duration)
		
		var is_on_web = Util.is_web_build()
		if not is_on_web:
			if fadeout_timer <= 0.0:
				get_tree().change_scene_to_file(start_game_scene_path)
		else:
			if fadeout_timer <= -4.0:
				get_tree().change_scene_to_file(start_game_scene_path)
			if fadeout_timer <= -3.0:
				$WebWarning.modulate.a = lerp($WebWarning.modulate.a, 0.0, 0.1)
			elif fadeout_timer <= 0.0:
				$WebWarning.modulate.a = lerp($WebWarning.modulate.a, 1.0, 0.1)

	elif starting_credits:
		fadeout_timer -= delta
		$Fadeout.color.a = lerp(0.0, 1.0, (fadeout_duration - fadeout_timer) / fadeout_duration)
		if fadeout_timer <= 0.0:
			get_tree().change_scene_to_file(credits_path)
			
	else:
		$Fadeout.color.a = lerp(0.0, 1.0, (fadeout_duration - timer) / fadeout_duration)


func _on_new_game_button_pressed() -> void:
	click.play()
	if new_game_deletes_old_save:
		SaveGame.delete_savegame()
	
	starting_game = true
	GameState.load_game_at_start = false
	fadeout_timer = fadeout_duration
	
func _on_continue_button_pressed() -> void:
	click.play()
	starting_game = true
	fadeout_timer = fadeout_duration
	GameState.load_game_at_start = true

func _on_settings_button_pressed() -> void:
	click.play()
	settings_ui.visible = true
	start_menu_mc.visible = false
	
func _on_credits_button_pressed() -> void:
	click.play()
	starting_credits = true
	fadeout_timer = fadeout_duration

func _on_quit_button_pressed() -> void:
	click.play()
	get_tree().quit()

func _on_settings_ui_back_pressed() -> void:
	click.play()
	settings_ui.visible = false
	start_menu_mc.visible = true

func _on_continue_button_mouse_entered() -> void:
	hover.play()

func _on_new_game_button_mouse_entered() -> void:
	hover.play()

func _on_settings_button_mouse_entered() -> void:
	hover.play()

func _on_credits_button_mouse_entered() -> void:
	hover.play()

func _on_quit_button_mouse_entered() -> void:
	hover.play()


func _on_controls_button_mouse_entered() -> void:
	hover.play()


func _on_controls_button_pressed() -> void:
	click.play()
	#TODO
