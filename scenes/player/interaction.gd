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
		current_highlight_interactable.set_highlight(player, false)
	
	if next_interactable == null:
		current_highlight_interactable = null
		return
	
	next_interactable.set_highlight(player, true)
	current_highlight_interactable = next_interactable
	
func _get_next_interactable() -> Interactable:
	var found_interactable: Interactable = null
	
	remove_invalid_interactables()
	available_interactables.sort_custom(sort_by_dist.bind(global_position))
	
	for interactable: Interactable in available_interactables:
		if interactable.can_interact(player):
			found_interactable = interactable

	return found_interactable

func sort_by_dist(ia1: Interactable, ia2: Interactable, pos_reference: Vector3) -> int:
	return ia1.global_position.distance_to(pos_reference) < ia2.global_position.distance_to(pos_reference)

func remove_invalid_interactables() -> void:
	for idx: int in available_interactables.size():
		var reverse_index: int = available_interactables.size() - 1 - idx
		if !is_instance_valid(available_interactables[reverse_index]):
			available_interactables.remove_at(reverse_index)

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
