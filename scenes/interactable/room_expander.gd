class_name RoomExpander
extends Interactable

var animation_progress: float = 0.0
var rotation_speed: float = 0;
var fired_particles: bool = false



@export var room_type: GameState.RoomType = GameState.RoomType.BEDROOM
@export var unlock_time: float = 7.0
@export var scale_factor: float = 0.6
@export var deactivated_color: Color = Color.DIM_GRAY
@export var highlight_color: Color = Color.GRAY
@export var activated_color: Color = Color.WHITE
@export_category("internal nodes")
@export var star_mesh: MeshInstance3D
@export var circle_mesh: MeshInstance3D
@export var wall: MeshInstance3D
@export var gpu_particles_3d: GPUParticles3D
@export var collision_shape_3d: CollisionShape3D
@export var doorframe: MeshInstance3D
@onready var dooropen: AudioStreamPlayer3D = $dooropen
@onready var dooropen_end: AudioStreamPlayer3D = $dooropen_end

var door_unlocked: bool = false
var has_started_animation: bool = false

#var default_circle_scale: Vector3
var default_star_scale: Vector3
var circle_mat: StandardMaterial3D
var star_mat: StandardMaterial3D

func _ready() -> void:
	init_circle()
	set_highlight(false)

func _physics_process(delta: float) -> void:
	if door_unlocked:
		return
	if animation_progress == 0.0:
		return
	
	animation_progress += delta

	if star_mesh != null && circle_mesh != null:
		star_mesh.rotate_z(delta * rotation_speed)
		circle_mesh.rotate_z(-delta * 0.5 * rotation_speed)
		rotation_speed += delta * 1

		var star_scale = 1.0 + 0.025 * sin(animation_progress * 2) * animation_progress
		star_mesh.scale = Vector3(star_scale, star_scale, star_scale) * scale_factor
		var circle_scale = 1.0 + 0.025 * cos(animation_progress * 2) * animation_progress
		circle_mesh.scale = Vector3(circle_scale, circle_scale, circle_scale)

	if animation_progress >= (unlock_time - gpu_particles_3d.lifetime/2.0) && !fired_particles:
		fired_particles = true
		gpu_particles_3d.emitting = true
	if animation_progress >= unlock_time:
		unlock()

func can_interact(_player: Player) -> bool:
	return animation_progress == 0.0

func interact(_player: Player) -> void:
	if has_started_animation:
		return
	has_started_animation = true
	animation_progress = 0.01
	dooropen.play()
	
	var start_anim_tween: Tween = create_tween().set_trans(Tween.TRANS_SPRING).set_parallel(true)
	start_anim_tween.tween_property(self, "scale_factor", 1.0, 0.4)
	start_anim_tween.tween_property(self, "circle_mat:albedo_color", activated_color, 0.4)
	start_anim_tween.tween_property(self, "star_mat:albedo_color", activated_color, 0.4)	
	
	var room_listeners = get_tree().get_nodes_in_group("room_listener")
	for room_listener in room_listeners:
		if room_listener is RoomListener:
			room_listener.on_room_unlock_start(room_type, unlock_time)


func set_highlight(highlight_new: bool) -> void:
	if has_started_animation || door_unlocked:
		return
	#print("highlighting for ", self.name, ": ", highlight_new)
	
	star_mat.albedo_color = highlight_color if highlight_new else deactivated_color
	circle_mat.albedo_color = highlight_color if highlight_new else deactivated_color


func unlock() -> void:
	if door_unlocked: 
		return
	door_unlocked = true
	wall.queue_free()
	circle_mesh.queue_free()
	star_mesh.queue_free()
	collision_shape_3d.queue_free()
	doorframe.visible = true
	dooropen_end.play()
	
	var room_listeners = get_tree().get_nodes_in_group("room_listener")
	for room_listener in room_listeners:
		if room_listener is RoomListener:
			room_listener.on_room_unlocked(room_type)

func init_circle() -> void:
	star_mat = star_mesh.material_override
	circle_mat = circle_mesh.material_override
	star_mat.albedo_color = deactivated_color
	circle_mat.albedo_color = deactivated_color
	default_star_scale = star_mesh.scale
	#default_circle_scale = circle_mesh.scale
	star_mesh.scale = default_star_scale * scale_factor
	#circle_mesh.scale = default_circle_scale * initial_scale_factor
	
