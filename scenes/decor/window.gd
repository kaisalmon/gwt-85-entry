extends Node3D

var outside_camera: Camera3D
var viewport: Viewport

func _ready() -> void:
	viewport = $SubViewport
	outside_camera = $SubViewport/Camera3D

func _physics_process(_delta: float) -> void:
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
