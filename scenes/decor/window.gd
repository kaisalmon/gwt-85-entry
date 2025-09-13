extends RoomListener

var outside_camera: Camera3D
var viewport: Viewport
var unlock_time = null
var unlock_duration = null
var has_emitted = false
@export var removed_by_room: GameState.RoomType = GameState.RoomType.NONE

func _ready() -> void:
	super._ready()
	viewport = $SubViewport
	outside_camera = $SubViewport/Camera3D

func _physics_process(delta: float) -> void:
	update_dissapear_animation(delta)

	viewport.size = get_viewport().size # Sync viewport size with main viewport

	var active_camera = get_viewport().get_camera_3d()
	viewport.size = get_viewport().size
	outside_camera.size = active_camera.size
	outside_camera.near = active_camera.near
	outside_camera.far = active_camera.far
	outside_camera.fov = active_camera.fov
	
	var src = GameState.outside

	# outside_camera.global_transform = src.global_transform
	var relative_position = active_camera.global_transform.origin - self.global_transform.origin
	outside_camera.global_transform.origin = src.global_transform.origin + relative_position

	var look_vector = -1 * active_camera.global_transform.basis.z
	outside_camera.global_transform.basis = Basis.looking_at(look_vector, Vector3.UP)

func update_dissapear_animation(delta: float) -> void:
	if unlock_time == null:
		return
	unlock_time -= delta
	outside_camera.environment.fog_depth_end = lerp(0, 25, unlock_time / unlock_duration)
	outside_camera.environment.fog_depth_begin = lerp(0, 22, unlock_time / unlock_duration)

	if unlock_time <= $GPUParticles3D.lifetime / 2.0:
		has_emitted = true
		$GPUParticles3D.emitting = true

func on_room_unlocked(_room: GameState.RoomType) -> void:
	if _room == removed_by_room:
		queue_free()

func on_room_unlock_start(room_type: GameState.RoomType, unlock_time: float) -> void:
	if room_type == removed_by_room:
		self.unlock_time = unlock_time
		self.unlock_duration = unlock_time
