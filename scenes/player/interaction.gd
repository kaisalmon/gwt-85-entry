class_name Interaction
extends Area3D

@export var player: Player

var available_interactables: Array[Interactable] = []
var current_highlight_interactable: Interactable = null
 
func interact() -> void:	
	var next_interactable: Interactable = _get_next_interactable()
	if next_interactable != null:
		next_interactable.interact(player)
	_update_interaction_hint()

func _update_interaction_hint() -> void:
	var next_interactable: Interactable = _get_next_interactable()
	if next_interactable == current_highlight_interactable:
		return

	if is_instance_valid(current_highlight_interactable):
		current_highlight_interactable.set_highlight(false)
	
	if next_interactable == null:
		current_highlight_interactable = null
		return
	
	next_interactable.set_highlight(true)
	current_highlight_interactable = next_interactable
	
func _get_next_interactable() -> Interactable:
	var found_interactable: Interactable = null
	var invalid_interactables: Array[Interactable]
	for interactable: Interactable in available_interactables:
		if !is_instance_valid(interactable):
			invalid_interactables.append(interactable)
			continue
		if interactable.can_interact(player):
			found_interactable = interactable
	
	for invalid_interactable: Interactable in invalid_interactables:
		available_interactables.erase(invalid_interactable)
	
	return found_interactable

func _on_area_entered(area: Area3D) -> void:
	if !area is Interactable || !is_instance_valid(area):
		return
	var interactable: Interactable = area as Interactable
	if available_interactables.has(interactable):
		return

	available_interactables.append(interactable)	
	_update_interaction_hint()

func _on_area_exited(area: Area3D) -> void:
	if !area is Interactable:
		return
	var interactable: Interactable = area as Interactable
	var interactable_index: int = available_interactables.find(interactable)
	if interactable_index >= 0:
		available_interactables.remove_at(interactable_index)
	_update_interaction_hint()	
