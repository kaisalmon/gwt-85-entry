class_name Player
extends CharacterBody3D

@export var mouse_sensitivity: float = 0.05
@export var move_speed: float = 12.0
@export_range(0, 90, 1, "radians_as_degrees") var max_down_angle: float = 60
@export_range(0, 90, 1, "radians_as_degrees") var max_up_angle: float = 60

@export_category("internal nodes")
@export var look_pivot: Node3D


func _ready() -> void:
	Input.mouse_mode = Input.MOUSE_MODE_CAPTURED #we may not want this here

func _physics_process(delta: float) -> void:
	move(delta)

func move(delta: float) -> void:
	var input_dir: Vector2 = Input.get_vector("move_left", "move_right", "move_up", "move_down")
	if !can_use_input():
		input_dir = Vector2.ZERO
	
	var move_dir: Vector3 = transform.basis * Vector3(input_dir.x, 0, input_dir.y)
	velocity = velocity.move_toward(move_dir * move_speed, delta * 200)
	move_and_slide()


func _input(event: InputEvent) -> void:
	if !can_use_input():
		return
	if event is InputEventMouseMotion:
		rotate_y(-event.relative.x * mouse_sensitivity)
		look_pivot.rotate_x(-event.relative.y * mouse_sensitivity)
		look_pivot.rotation.x = clampf(look_pivot.rotation.x, -deg_to_rad(max_down_angle), deg_to_rad(max_up_angle))
		
func can_use_input() -> bool:
	return true
