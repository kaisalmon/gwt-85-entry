class_name Player
extends CharacterBody3D

@export var move_speed: float = 12.0
@export_range(0.0, 0.6, 0.01) var walk_y_variance: float = 0.1
@export var mouse_sensitivity: float = 0.05
@export_range(0, 90, 1, "radians_as_degrees") var max_down_angle: float = 60
@export_range(0, 90, 1, "radians_as_degrees") var max_up_angle: float = 60

@export_category("internal nodes")
@export var look_pivot: Node3D

@onready var footsteps: AudioStreamPlayer3D = $PlayerAudio/footsteps

var base_y_pos: float
var move_time: float = 0.0
var current_y_offset: float = 0.0
var ismoving: bool = false #check movement for footsteps


func _ready() -> void:
	Input.mouse_mode = Input.MOUSE_MODE_CAPTURED #we may not want this here
	base_y_pos = look_pivot.position.y

func _physics_process(delta: float) -> void:
	
	move(delta)
	
	if move_time > 0:
		var offset_strength: float = max(clamp(move_time * 2, 0.0, 1.0), current_y_offset)
		current_y_offset = offset_strength * sin(move_time*10) * walk_y_variance
		look_pivot.position.y = base_y_pos + current_y_offset
	else:
		current_y_offset = lerp(current_y_offset, 0.0, delta)
		look_pivot.position.y = base_y_pos + current_y_offset		

func move(delta: float) -> void:
	var input_dir: Vector2 = Input.get_vector("move_left", "move_right", "move_up", "move_down")
	if !can_use_input():
		input_dir = Vector2.ZERO


	var move_dir: Vector3 = Vector3.ZERO
	if !input_dir.is_zero_approx():
		move_dir = transform.basis * Vector3(input_dir.x, 0, input_dir.y)
		move_time += delta
		ismoving = true
	else:
		move_time = 0.0
		ismoving = false
	
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


func _on_timer_timeout() -> void:
	if ismoving:
		footsteps.play()
