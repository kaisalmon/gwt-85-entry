class_name RoomExpander
extends Interactable

func _ready() -> void:
	set_highlight(false)

func can_interact(_player: Player) -> bool:
	#TODO ?
	return true

func interact(_player: Player) -> void:
	print("interacting with ", self.name)

	#TODO
	pass
	
func set_highlight(highlight_new: bool) -> void:
	print("highlighting for ", self.name, ": ", highlight_new)
	#TODO
	pass
