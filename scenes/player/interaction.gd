class_name Interaction
extends Area3D

@export var player: Player
@export_category("internal nodes")
@export var visibilty_ray_cast_3d: RayCast3D 
@export var recheck_interaction: Timer

var available_interactables: Array[Interactable] = []
var current_highlight_interactable: Interactable = null

var interactable_in_use: Interactable = null

var _is_dirty: bool = false

func interact() -> void:	
	var next_interactable: Interactable = _get_next_interactable()
	if next_interactable != null:
		next_interactable.interact(player)
		interactable_in_use = next_interactable
	_update_interaction_hint()

func stop_interact() -> void:
	if !is_instance_valid(interactable_in_use):
		return

	interactable_in_use.stop_interact(player)

func _update_interaction_hint() -> void:
	var next_interactable: Interactable = _get_next_interactable()
	_is_dirty = false
	recheck_interaction.start()
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
	remove_invalid_interactables()
	available_interactables.sort_custom(sort_by_dist.bind(global_position))
	var available_interactables_size: int = available_interactables.size()
	if available_interactables_size == 0:
		return null
		
	var start_index: int = 0
		
	if available_interactables[0] == interactable_in_use:
		start_index = 1
		if (available_interactables[0].can_interact(player)):
			return interactable_in_use
	
		if available_interactables_size == 1:
			return null
	
	#visibilty_ray_cast_3d.force_raycast_update()
	var collider: Object = visibilty_ray_cast_3d.get_collider()
	
	var collision_dist_sq: float = 999
	
	if collider != null:
		collision_dist_sq = global_position.distance_squared_to(visibilty_ray_cast_3d.get_collision_point())
		#print("collision! from ", global_position, " looking at ", visibilty_ray_cast_3d.get_collision_point())
	
	for i: int in available_interactables_size:
		if i < start_index:
			continue
		var interactable: Interactable = available_interactables[i]
		if interactable.can_interact(player):
			if collider == null:
				#print("interactable ", interactable.name, " found with no collider")
				return interactable
				
			if global_position.distance_squared_to(interactable.global_position) < collision_dist_sq:
				#print("interactable ", interactable.name, " is closer, with pos: ", interactable.global_position)
				return interactable
	return null

func sort_by_dist(ia1: Interactable, ia2: Interactable, pos_reference: Vector3) -> int:
	return ia1.global_position.distance_squared_to(pos_reference) < ia2.global_position.distance_squared_to(pos_reference)

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

func set_dirty() -> void:
	_is_dirty = true
	if recheck_interaction.is_stopped():
		#print("rechecking interaction by isdirty..")
		_update_interaction_hint()

func _on_recheck_interaction_timeout() -> void:
	if !_is_dirty:
		#print("no need to recheck, nothing is dirty..")
		
		return
	
	#print("rechecking interaction..")
	_update_interaction_hint()
	
