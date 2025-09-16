extends CanvasLayer

@export_file("*.tscn") var start_game_scene_path: String
@export_category("internal nodes")
@export var start_menu_mc: MarginContainer
@export var quit_button: Button
@export var settings_ui: SettingsUI

func _ready() -> void:
	settings_ui.visible = false
	start_menu_mc.visible = true
	
func _on_new_game_button_pressed() -> void:
	get_tree().change_scene_to_file(start_game_scene_path)
		
func _on_settings_button_pressed() -> void:
	settings_ui.visible = true
	start_menu_mc.visible = false
	
func _on_credits_button_pressed() -> void:
	pass # Replace with function body.

func _on_quit_button_pressed() -> void:
	get_tree().quit()


func _on_settings_ui_back_pressed() -> void:
	settings_ui.visible = false
	start_menu_mc.visible = true
