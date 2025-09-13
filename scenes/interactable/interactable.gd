class_name Interactable
extends Area3D

func can_interact(_player: Player) -> bool:
	return true
	

func interact(_player: Player) -> void:
	push_warning("interactable is a base class and is not intended to be used. Inherit from Interactable and overwrite 'interact(..)'")
