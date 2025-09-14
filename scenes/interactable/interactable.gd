class_name Interactable
extends Area3D

func can_interact(_player: Player) -> bool:
	return true

func interact(_player: Player) -> void:
	push_warning(self.name + ": interactable is a base class and is not intended to be used. Inherit from Interactable and overwrite 'interact(..)'")

func stop_interact(_player: Player) -> void:
	#push_warning(self.name + ": interactable is a base class and is not intended to be used. Inherit from Interactable and overwrite 'stop_interact(..)'")
	pass

func set_highlight(_player: Player, _highlight_new: bool) -> void:
	push_warning(self.name + ": interactable is a base class and is not intended to be used. Inherit from Interactable and overwrite 'highlight(..)'")
