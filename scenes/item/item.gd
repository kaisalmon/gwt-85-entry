class_name Item
extends RigidBody3D

const BOOK_ITEM_SCENE: PackedScene = preload("res://scenes/item/book_item.tscn") as PackedScene
const CANDLE_ITEM_SCENE: PackedScene = preload("res://scenes/item/candle_item.tscn") as PackedScene
const KNIFE_ITEM_SCENE: PackedScene = preload("res://scenes/item/knife_item.tscn") as PackedScene

enum ItemType {
	BOOK,
	CANDLE,
	KNIFE
}

@export var item_type: ItemType
@export var item_interactable: ItemInteractable
@export var col_shape: CollisionShape3D
var drag_target: Node3D

static func get_scene(scene_item_type: ItemType) -> PackedScene:
	match scene_item_type:
		ItemType.BOOK:
			return BOOK_ITEM_SCENE
		ItemType.CANDLE:
			return CANDLE_ITEM_SCENE
		ItemType.KNIFE:
			return KNIFE_ITEM_SCENE
			
	push_warning("Item.get_scene(): no implementation for " + ItemType.keys()[scene_item_type] + " exists yet!")
	return null

func set_held(is_held_new: bool) -> void:
	gravity_scale = 0.0 if is_held_new else 1.0
	item_interactable.visible = !is_held_new
	item_interactable.monitorable = !is_held_new
	col_shape.disabled = is_held_new


##	
#func _integrate_forces(state: PhysicsDirectBodyState3D) -> void:
	#if !is_instance_valid(drag_target):
		#return
	#
	#var dir_vec: Vector3 = drag_target.global_position - self.global_position
	#
	#linear_velocity = linear_velocity + dir_vec * 2
	#
	#linear_velocity = (drag_target.global_position - self.global_position)

var drag_tween: Tween

func _physics_process(_delta: float) -> void:
	if !is_instance_valid(drag_target):
		return
	if global_position.distance_to(drag_target.global_position) < 0.1:
		return
		
	if is_instance_valid(drag_tween): 
		drag_tween.kill()

	drag_tween = create_tween()
	drag_tween.tween_property(self, "global_position", drag_target.global_position, 0.3)
