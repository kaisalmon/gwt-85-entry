class_name ItemProvider
extends Interactable

@export var produced_item: Item.ItemType

@onready var debug_label_3d: Label3D = $DebugLabel3D

@onready var pickup: AudioStreamPlayer = $pickup


func _ready() -> void:
	debug_label_3d.text = Item.ItemType.keys()[produced_item]
	set_highlight(false)

func can_interact(_player: Player) -> bool:
	return true

func interact(player: Player) -> void:
	print(player.name, ": interacting with ", self.name)
	
	if is_instance_valid(player.held_item):
		print("player can't pick up '", Item.ItemType.keys()[produced_item], "' from '", self.name, "' because he currently holds '", player.held_item)
		# TODO: should we allow the player to remove items from his hand if its from the same type?
		return
	
	var new_item: Item = Item.get_scene(produced_item).instantiate() as Item
	player.set_item(new_item)
	
	pickup.play()
	
func set_highlight(highlight_new: bool) -> void:
	#print("highlighting for ", self.name, ": ", highlight_new)
	debug_label_3d.visible = highlight_new
