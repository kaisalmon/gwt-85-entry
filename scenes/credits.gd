extends Node3D

@export var all_lights_texture: Texture2D
@export var bedroom_lights_texture: Texture2D
@export var no_lights_texture: Texture2D
@export var scroll_speed = 20.0
@export var credits_control: Control
@export var fadein_duration = 1.25
@export var delay = 2.5
@export_file("*.tscn") var next_scene: String
@onready var credits_music: AudioStreamPlayer = $credits_music

var progress = 0.0
var end_sequence_timer = 0.0
var speedup = 1.0
var fadeout_timer = 0.0
var fadeout_started = false


func _ready() -> void:
	Input.mouse_mode = Input.MOUSE_MODE_VISIBLE

func _input(event: InputEvent) -> void:
	#speedup = 1.0
	if event.is_action_pressed("interact"):
		speedup = 8.0
	elif event.is_action_released("interact"):
		speedup = 1.0

func _process(delta: float) -> void:
	progress += delta * speedup
	if progress < fadein_duration:
		$Fadeout.color.a = lerp(1.0, 0.0, progress / fadein_duration)
	if progress < delay:
		return
	credits_control.position.y -= delta * scroll_speed * speedup
	if credits_control.position.y + credits_control.size.y < 92:
		end_sequence_timer += delta * speedup
		var house = $House
		var material = house.get_active_material(0) as StandardMaterial3D
		if end_sequence_timer > 1.0:
			material.albedo_texture = bedroom_lights_texture
		if end_sequence_timer > 2.5:
			material.albedo_texture = no_lights_texture
		if end_sequence_timer > 3.0:
			if not fadeout_started:
				if !credits_music.playing or speedup > 1.0:
					fadeout_started = true
		if fadeout_started:
			fadeout_timer += delta
			$Fadeout.color.a = lerp(0.0, 1.0, (fadeout_timer) / fadein_duration)
			if fadeout_timer > fadein_duration + 1.0:
				get_tree().change_scene_to_file(next_scene)
