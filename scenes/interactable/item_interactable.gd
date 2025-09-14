class_name ItemInteractable 
extends Interactable

@export var debug_label_3d: Label3D
@export var item_source: Item
@export var pickup_audio_stream_player: AudioStreamPlayer 
@export var despawn_timer: Timer

func _ready() -> void:
	debug_label_3d.text = Item.ItemType.keys()[item_source.item_type]
	set_highlight(false)

func can_interact(_player: Player) -> bool:
	return true

func interact(player: Player) -> void:
	print(player.name, ": interacting with ", self.name)
	
	if is_instance_valid(player.held_item):
		print("player can't pick up '", Item.ItemType.keys()[item_source.item_type], "' from '", self.name, "' because he currently holds '", player.held_item)
		# TODO: should we allow the player to remove items from his hand if its from the same type?
		return
	
	player.set_item_in_hand(item_source, true)
	pickup_audio_stream_player.play()
	
func set_highlight(highlight_new: bool) -> void:
	#print("highlighting for ", self.name, ": ", highlight_new)
	debug_label_3d.visible = highlight_new
