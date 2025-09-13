class_name ItemConsumer
extends Interactable

## Consumes items and converts them to magic
## Used for the cauldron.

func _ready() -> void:
	pass

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
	
