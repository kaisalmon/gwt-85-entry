extends Node3D
class_name  ManaOrb 
@export var screen_depth = 1
@export var target_speed = 3.0
@export var acceleration = 5.0
@export var initial_velocity = Vector3.UP * 0.6
@export var initial_speed_variance = 1
@export var is_valid_orb: bool = true

var screen_space_target: Vector2 = Vector2.ZERO
var velocity: Vector3 = Vector3.ZERO
var deposited: bool = false
var magic_type: Recipe.MagicType = Recipe.MagicType.SOFT
var delay = 0.0

func _ready() -> void:
	velocity = initial_velocity + Vector3(
		randf_range(-initial_speed_variance, initial_speed_variance),
		randf_range(-initial_speed_variance, initial_speed_variance),
		randf_range(-initial_speed_variance, initial_speed_variance)
	)
	
func set_magic_type(new_magic_type: Recipe.MagicType) -> void:
	var ui: UI = GameState.ui
	var label: Label = ui.get_label_by_type(new_magic_type)
	var global_position_2d: Vector2 = label.get_global_position() + label.get_size() * 0.5
	screen_space_target = global_position_2d
	self.magic_type = new_magic_type

func get_world_space_target() -> Vector3:
	var camera: Camera3D = get_viewport().get_camera_3d()
	if camera == null:
		push_warning("the current viewport does not have a camera3d")
		return Vector3.ZERO
	return camera.project_position(screen_space_target, screen_depth)

func _process(delta: float) -> void:
	if !is_valid_orb:
		return
		
	if delay > 0.0:
		delay -= delta
		return

	var target: Vector3 = get_world_space_target()
	var to_target: Vector3 = target - global_transform.origin
	velocity = velocity.move_toward(to_target.normalized() * target_speed, delta * acceleration)
	global_transform.origin += velocity * delta

	if to_target.length() < 0.2:
		position = position.move_toward(target, delta * 5.0)
		var xscale = self.scale.x
		xscale -= delta * 2.0
		self.scale = Vector3.ONE * xscale
		if xscale <= 0.0:
			queue_free()
		
		if xscale < 0.5 and not deposited:
			var ui: UI = GameState.ui
			ui.increment_visual_magic_amount(magic_type, 1)
			deposited = true
