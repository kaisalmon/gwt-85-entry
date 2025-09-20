class_name Player
extends CharacterBody3D

@export var move_speed: float = 7.0
@export var acceleration: float = 15.0
@export var deacceleration: float = 35.0
@export_range(0.0, 0.6, 0.01) var walk_y_variance: float = 0.1
@export var mouse_sensitivity: float = 0.005
@export_range(0, 90, 1, "radians_as_degrees") var max_down_angle: float = 60
@export_range(0, 90, 1, "radians_as_degrees") var max_up_angle: float = 60
@export_range(0.0, 0.6, 0.01) var head_bobbing_y_offset: float = 0.05
@export var head_bobbing_speed: float = 14
@export var gravity: float = 9.8
@export_category("internal nodes")
@export var look_pivot: Node3D
@export var interaction: Interaction
@export var item_hold_position: Marker3D
@onready var footsteps: AudioStreamPlayer3D = $PlayerAudio/footsteps

var current_room: GameState.RoomType

var base_y_pos: float
var move_time: float = 0.0
var current_y_offset: float = 0.0
var ismoving: bool = false #check movement for footsteps
var actual_current_speed: float
var held_item: Item = null
var is_item_in_hover_pos: bool = false

var has_noclip: bool = false

var current_speed: float
var current_accel: float
var current_decel: float

func _ready() -> void:
	Input.mouse_mode = Input.MOUSE_MODE_CAPTURED
	GameState.player = self
	Util.set_sample_type_if_web(footsteps)
	current_speed = move_speed
	current_accel = acceleration
	current_decel = deacceleration

	 #we may not want this here
	base_y_pos = look_pivot.position.y

func _physics_process(delta: float) -> void:
	_move(delta)
	#var relative_speed: float = min(actual_current_speed / move_speed, 1.0)
	#var speed_factor: float = relative_speed * head_bobbing_speed
	var speed_factor: float = head_bobbing_speed

	if move_time > 0:
		var offset_strength: float = max(clamp(move_time * 2, 0.0, 1.0), current_y_offset)
		current_y_offset = offset_strength * sin(move_time*speed_factor) * head_bobbing_y_offset
		look_pivot.position.y = base_y_pos + current_y_offset
	else:
		current_y_offset = lerp(current_y_offset, 0.0, delta)
		look_pivot.position.y = base_y_pos + current_y_offset		

func _move(delta: float) -> void:
	var input_dir: Vector2 = Input.get_vector("move_left", "move_right", "move_up", "move_down")
	if !can_use_input():
		input_dir = Vector2.ZERO

	var y_velo: float = 0.0 if (is_on_floor() || has_noclip) else -gravity

	var move_dir: Vector3 = Vector3.ZERO
	if !input_dir.is_zero_approx():
		move_dir = transform.basis * Vector3(input_dir.x, 0, input_dir.y)
		move_time += delta
		ismoving = true
		interaction.set_dirty()
		# 0 when moving in exact opposition direction to move_dir, 1 when moving in exact same direction
		var acc_dec_ratio = velocity.normalized().dot(move_dir.normalized()) * 0.5 + 0.5 
		var acc_dec_rate = lerp(current_decel, current_accel, acc_dec_ratio)
		velocity = velocity.move_toward(move_dir * current_speed, acc_dec_rate * delta)
	else:
		move_time = 0.0
		ismoving = false
		velocity = velocity.move_toward(Vector3(0,y_velo,0), current_decel * delta)


	var previous_pos: Vector3 = global_position
	velocity.y = lerp(velocity.y, y_velo, delta*30)
	move_and_slide()

	if previous_pos.is_equal_approx(global_position):
		move_time = 0
	actual_current_speed = (global_position - previous_pos).length()/delta
	
func _input(event: InputEvent) -> void:
	if !can_use_input():
		return
	if event is InputEventMouseMotion:
		rotate_y(-event.relative.x * mouse_sensitivity * Settings.sensitivity)
		look_pivot.rotate_x(-event.relative.y * mouse_sensitivity * Settings.sensitivity)
		look_pivot.rotation.x = clampf(look_pivot.rotation.x, -deg_to_rad(max_down_angle), deg_to_rad(max_up_angle))
	if event is InputEventMouseButton && (event as InputEventMouseButton).pressed:
		#Needed for web capture
		Input.mouse_mode = Input.MOUSE_MODE_CAPTURED

	if event.is_action_pressed("interact"):
		interaction.interact()
	if event.is_action_released("interact"):
		interaction.stop_interact()
	if event.is_action_pressed("drop_item"):
		drop_current_item()
				
	if event is InputEventKey:
		var iek: InputEventKey = event as InputEventKey
		if iek.pressed && iek.keycode == KEY_F3:
			if held_item != null:
				held_item.print_debug()
				
func can_use_input() -> bool:
	return true

func _on_timer_timeout() -> void:
	if ismoving:
		footsteps.play()
	
func remove_and_get_current_item() -> Item:
	if held_item == null:
		return null
	var item: Item = held_item
	held_item = null
	return item
	
func set_item_in_hand(item: Item) -> void:
	item.global_position = item_hold_position.global_position
	held_item = item
	held_item.set_held(true)
	held_item.drag_target = item_hold_position
	is_item_in_hover_pos = false

func drop_current_item() -> void:
	if !is_instance_valid(held_item):
		return

	if is_item_in_hover_pos:
		held_item.drag_target = self
		await get_tree().create_timer(0.1).timeout
	is_item_in_hover_pos = false
	held_item.set_held(false)
	held_item.drag_target = null
	held_item = null

func set_item_to_hand_pos_from_hover() -> void:
	if !is_instance_valid(held_item):
		return
	var tween: Tween = held_item.tween_to_position(item_hold_position)
	tween.finished.connect(on_after_item_hover)

func on_after_item_hover() -> void:
	is_item_in_hover_pos = false
	held_item.drag_target = item_hold_position

func set_item_to_hover_pos(pos_node: Node3D) -> void:
	if !is_instance_valid(held_item):
		return
	held_item.drag_target = pos_node
	is_item_in_hover_pos = true
	held_item.tween_to_position(pos_node)

func get_look_ortho() -> float:
	return rotation.y + PI

func get_look_ortho_vec3D() -> Vector3:
	var displacemnt_vec: Vector2 = Vector2.from_angle(2 * PI - get_look_ortho())
	return Vector3(displacemnt_vec.x, 0, displacemnt_vec.y)

func set_noclip_enabled(has_noclip_new: bool) -> void:
	has_noclip = has_noclip_new
	set_collision_layer_value(1, !has_noclip_new)
	set_collision_mask_value(1, !has_noclip_new)
	current_speed = move_speed * 2 if has_noclip_new else move_speed
	current_accel = acceleration * 2 if has_noclip_new else acceleration
	current_decel = deacceleration * 2 if has_noclip_new else deacceleration

func set_current_room(room_type_new: GameState.RoomType) -> void:
	if room_type_new == GameState.RoomType.NONE:
		return
	print("player entering room: ", GameState.RoomType.keys()[room_type_new])
	current_room = room_type_new
