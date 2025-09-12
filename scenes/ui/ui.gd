class_name UI
extends CanvasLayer

@export_category("internal nodes")
@export var pause_overlay: ColorRect
@export var magic_value_label: Label

var default_mouse_mode: Input.MouseMode = Input.MOUSE_MODE_CAPTURED


func _ready() -> void:
	process_mode = ProcessMode.PROCESS_MODE_ALWAYS
	GameState.ui = self
	set_paused(false)
	set_magic_amount(0)

func set_paused(is_paused_new: bool) -> void:
	get_tree().paused = is_paused_new
	pause_overlay.visible = is_paused_new
	
func _input(event: InputEvent) -> void:
	if event.is_action_pressed("pause"):
		set_paused(!get_tree().paused)
		Input.mouse_mode = Input.MOUSE_MODE_VISIBLE if get_tree().paused else default_mouse_mode
		
func set_magic_amount(magic_amount_new: int) -> void:
	magic_value_label.text = str(magic_amount_new)
