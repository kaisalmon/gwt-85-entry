extends Node3D

@export var all_lights_texture: Texture2D
@export var bedroom_lights_texture: Texture2D
@export var no_lights_texture: Texture2D
@export var scroll_speed = 30.0
@export var credits_control: Control
@export var fadein_duration = 1.25
@export var delay = 2.5
@export_file("*.tscn") var next_scene: String
@onready var credits_music: AudioStreamPlayer = $credits_music

var progress = 0.0
var end_sequence_timer = 0.0
var speedup = 1.0

func _ready() -> void:
	Input.mouse_mode = Input.MOUSE_MODE_VISIBLE

func _input(event: InputEvent) -> void:
	if event is InputEventMouseButton and event.pressed:
		speedup = 5.0
		if end_sequence_timer > 4.5:
			get_tree().change_scene_to_file(next_scene)
	else:
		speedup = 1.0

func _process(delta: float) -> void:
	progress += delta * speedup
	if progress < fadein_duration:
		$Fadeout.color.a = lerp(1.0, 0.0, progress / fadein_duration)
	if progress < delay:
		return
	credits_control.position.y -= delta * scroll_speed * speedup
	if credits_control.position.y + credits_control.size.y < 92:
		end_sequence_timer += delta
		var house = $House
		var material = house.get_active_material(0) as StandardMaterial3D
		if end_sequence_timer > 1.0:
			material.albedo_texture = bedroom_lights_texture
		if end_sequence_timer > 2.5:
			material.albedo_texture = no_lights_texture
		if end_sequence_timer > 3.0:
			if !credits_music.playing:
				$Fadeout.color.a = lerp(0.0, 1.0, (end_sequence_timer - 3.0) / fadein_duration)
		if end_sequence_timer > 4.5:
			if !credits_music.playing:
				get_tree().change_scene_to_file(next_scene)
