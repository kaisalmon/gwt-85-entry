class_name Item
extends RigidBody3D

const BOOK_ITEM_SCENE: PackedScene = preload("res://scenes/item/book_item.tscn") as PackedScene
const CANDLE_ITEM_SCENE: PackedScene = preload("res://scenes/item/candle_item.tscn") as PackedScene
const KNIFE_ITEM_SCENE: PackedScene = preload("res://scenes/item/knife_item.tscn") as PackedScene

const FADEOUT_START_SPEED: float = 10
const FADEOUT_FINAL_SPEED: float = 50

enum ItemType {
	BOOK,
	CANDLE,
	KNIFE
}

@export var item_type: ItemType
@export var fadeout_time: float = 4.0
@export_category("internal nodes")

@export var item_interactable: ItemInteractable
@export var col_shape: CollisionShape3D
@export var despawn_timer: Timer
var fadeout_tween: Tween = null
var drag_target: Node3D
var is_held: bool = false
var drag_tween: Tween
var fadeout_factor: float = 0
var item_interactable_offset: Vector3

func set_held(is_held_new: bool) -> void:
	is_held = is_held_new
	gravity_scale = 0.0 if is_held_new else 1.0
	item_interactable.visible = !is_held_new
	item_interactable.monitorable = !is_held_new
	#col_shape.disabled = is_held_new
	set_collision_layer_value(1, !is_held_new)
	item_interactable_offset = item_interactable.debug_label_3d.position
	
	if is_held_new:
		set_visible_custom(true)
		fadeout_factor = 0.0
		despawn_timer.stop()
		if is_instance_valid(fadeout_tween):
			fadeout_tween.kill()
	else:
		update_label_pos()
		despawn_timer.start()

func _physics_process(_delta: float) -> void:
	#update_drag_tween()
	update_fadeout()
	update_label_pos()
#
#func update_drag() -> void:
	#if !is_instance_valid(drag_target):
		#return
	#if global_position.distance_to(drag_target.global_position) < 0.1:
		#return
		#
	#if is_instance_valid(drag_tween):
		#drag_tween.kill()
#
	#drag_tween = create_tween()
	#drag_tween.tween_property(self, "global_position", drag_target.global_position, 0.3)


#func update_drag_tween() -> void:
	#if !is_instance_valid(drag_target):
		#return
	#if global_position.distance_to(drag_target.global_position) < 0.1:
		#return
		#
	#tween_to_position(drag_target, 0.3)
#func _integrate_forces(state: PhysicsDirectBodyState3D) -> void:
	#pass

func update_fadeout() -> void:
	if is_zero_approx(fadeout_factor):
		return

	var used_fadeout_speed: float = lerp(FADEOUT_START_SPEED, FADEOUT_FINAL_SPEED, fadeout_factor)
	var is_visible_currently: bool = sin(fadeout_factor * used_fadeout_speed) > 0.0
	
	set_visible_custom(is_visible_currently)
	
func update_label_pos() -> void:
	if is_held:
		return
		
	item_interactable.global_rotation = Vector3.ZERO
	item_interactable.debug_label_3d.global_position = item_interactable.global_position + item_interactable_offset
		
func _on_despawn_timer_timeout() -> void:
	if is_instance_valid(fadeout_tween):
		fadeout_tween.kill()
	fadeout_factor = 0.0
	fadeout_tween = get_tree().create_tween()
	fadeout_tween.tween_property(self, "fadeout_factor", 1.0, fadeout_time)
	fadeout_tween.finished.connect(on_fadeout_tween_finished)
	
func on_fadeout_tween_finished() -> void:
	if is_held:
		return
	
	queue_free()

func tween_to_position(target_pos_node: Node3D, duration: float = 0.3) -> Tween:
	if is_instance_valid(drag_tween):
		drag_tween.kill()

	drag_tween = create_tween()
	drag_tween.tween_property(self, "global_position", target_pos_node.global_position, duration)
	return drag_tween

## using a method wrapper in case we want to use something else for fading out later
func set_visible_custom(is_visible_new: bool) -> void:
	visible = is_visible_new

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

func print_debug() -> void:
	var info: String = "DEBUG: ITEM '" + self.name + "'"
	info += "col_shape.disabled: " + str(col_shape.disabled) + "\n"
	info += "collisions: [1] l:" + str(get_collision_layer_value(1)) + " | m:" + str(get_collision_mask_value(1))
	info += "//  [2]: l: " + str(get_collision_layer_value(2))  + " | m:" + str(get_collision_mask_value(2))
	info += "//  [3]: l: " + str(get_collision_layer_value(3))  + " | m:" + str(get_collision_mask_value(3))
	info += "//  [4]: l: " + str(get_collision_layer_value(4))  + " | m:" + str(get_collision_mask_value(4)) + "\n" 
	
	print(info)
