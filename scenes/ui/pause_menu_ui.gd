class_name PauseMenuUI 
extends Control

signal unpause_requested

@export_file("*.tscn") var main_menu_scene_path: String
@export_category("internal nodes")
@export var settings_ui: SettingsUI
@export var pause_menu_vbc: VBoxContainer
@export var quit_button: Button
@onready var click: AudioStreamPlayer = $click
@onready var hover: AudioStreamPlayer = $hover

func _ready() -> void:
	quit_button.visible = !Util.is_web_build()
	pass

func show_pause_menu() -> void:
	pause_menu_vbc.visible = true
	settings_ui.visible = false

func _on_resume_button_pressed() -> void:
	click.play()
	unpause_requested.emit()

func _on_settings_button_pressed() -> void:
	click.play()
	pause_menu_vbc.visible = false
	settings_ui.visible = true

func _on_main_menu_button_pressed() -> void:
	click.play()
	Util.reset_paused_audio_effect()
	get_tree().change_scene_to_file(main_menu_scene_path)

func _on_quit_button_pressed() -> void:
	click.play()
	get_tree().quit()

func _on_settings_ui_back_pressed() -> void:
	click.play()
	show_pause_menu()
	


func _on_resume_button_mouse_entered() -> void:
	hover.play()
	pass # Replace with function body.


func _on_settings_button_mouse_entered() -> void:
	hover.play()
	pass # Replace with function body.


func _on_main_menu_button_mouse_entered() -> void:
	hover.play()
	pass # Replace with function body.


func _on_quit_button_mouse_entered() -> void:
	hover.play()
	pass # Replace with function body.
