class_name UI
extends CanvasLayer

@export_category("internal nodes")
@export var pause_overlay: ColorRect
@export var magic_value_label: Label

var default_mouse_mode: Input.MouseMode = Input.MOUSE_MODE_CAPTURED

@onready var magic_value_label_soft: Label = $MagicView/HBoxContainer/MagicValueLabelSoft
@onready var magic_value_label_crispy: Label = $MagicView/HBoxContainer/MagicValueLabelCrispy
@onready var magic_value_label_hollow: Label = $MagicView/HBoxContainer/MagicValueLabelHollow
@onready var magic_value_label_bulky: Label = $MagicView/HBoxContainer/MagicValueLabelBulky
@onready var magic_value_label_sturdy: Label = $MagicView/HBoxContainer/MagicValueLabelSturdy

var visual_magic_amounts: Dictionary[Recipe.MagicType, int] = {
	Recipe.MagicType.SOFT: 0,
	Recipe.MagicType.CRISPY: 0,
	Recipe.MagicType.HOLLOW: 0,
	Recipe.MagicType.BULKY: 0,
	Recipe.MagicType.STURDY: 0
}

func _ready() -> void:
	process_mode = ProcessMode.PROCESS_MODE_ALWAYS
	GameState.ui = self
	set_paused(false)

	for type: Recipe.MagicType in Recipe.MagicType.values():
		set_magic_amount(type, 0)

func set_paused(is_paused_new: bool) -> void:
	get_tree().paused = is_paused_new
	pause_overlay.visible = is_paused_new
	
func _input(event: InputEvent) -> void:
	if event.is_action_pressed("pause"):
		set_paused(!get_tree().paused)
		Input.mouse_mode = Input.MOUSE_MODE_VISIBLE if get_tree().paused else default_mouse_mode
		
func set_magic_amount(_type: Recipe.MagicType, _magic_amount_new: int) -> void:
	# TODO: store the actual mechanical amounts, either here or in player or in game state
	pass
	
func get_label_by_type(magic_type: Recipe.MagicType) -> Label:
	match magic_type:
		Recipe.MagicType.SOFT:
			return magic_value_label_soft
		Recipe.MagicType.CRISPY:
			return magic_value_label_crispy
		Recipe.MagicType.HOLLOW:
			return magic_value_label_hollow
		Recipe.MagicType.BULKY:
			return magic_value_label_bulky
		Recipe.MagicType.STURDY:
			return magic_value_label_sturdy			
	push_warning("no implementation found for UI.get_label_by_type() with type: ", Recipe.MagicType.keys()[magic_type])
	return null

func increment_visual_magic_amount(type: Recipe.MagicType, amount: int) -> void:
	if not visual_magic_amounts.has(type):
		push_warning("no entry found in visual_magic_amounts for type: ", Recipe.MagicType.keys()[type])
		return
	visual_magic_amounts[type] += amount
	get_label_by_type(type).text = str(visual_magic_amounts[type])
