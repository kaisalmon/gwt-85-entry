class_name ItemProvider
extends Interactable

@export var produced_item: Item.ItemType

func _ready() -> void:
	pass

func can_interact(_player: Player) -> bool:
	#TODO ?
	return true

func interact(player: Player) -> void:
	print(player.name, ": interacting with ", self.name)
	
	if is_instance_valid(player.held_item):
		print("player can't pick up '", Item.ItemType.keys()[produced_item], "' from '", self.name, "' because he currently holds '", player.held_item)
		return
	
	var new_item: Item = Item.get_scene(produced_item).instantiate() as Item
	player.set_item(new_item)
	
func set_highlight(highlight_new: bool) -> void:
	print("highlighting for ", self.name, ": ", highlight_new)

	#TODO
	pass
