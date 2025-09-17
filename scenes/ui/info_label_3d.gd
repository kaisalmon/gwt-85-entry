class_name InfoLabel3D
extends Label3D

signal wiggle_finished

@export var wiggle_color: Color = Color.DARK_RED

var start_position: Vector3
var text_tween: Tween = null
var default_text_color: Color = Color.WHITE
var is_wiggle_active: bool = false

func _ready() -> void:
	start_position = global_position

func wiggle_text(direction_vec: Vector3) -> void:
	if is_instance_valid(text_tween):
		text_tween.stop()
	
	is_wiggle_active = true
	text_tween = create_tween()
	text_tween.tween_method(tween_wiggle.bind(start_position, direction_vec), 0.0, 1.0, 0.5)
	text_tween.finished.connect(finish_wiggle)
	
func tween_wiggle(progress: float, start_pos: Vector3, direction_vec: Vector3) -> void:
	var displacement: float = sin(progress * 10) * 0.1
	global_position = start_pos + (direction_vec * displacement * (1-progress))
	modulate = wiggle_color.lerp(default_text_color, progress)
	
func finish_wiggle() -> void:
	global_position = start_position
	wiggle_finished.emit()
	is_wiggle_active = false
