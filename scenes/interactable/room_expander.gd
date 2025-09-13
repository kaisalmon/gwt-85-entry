class_name RoomExpander
extends Interactable

var animation_progress: float = 0.0
var rotation_speed: float = 0;
var fired_particles: bool = false

@export var room_type: GameState.RoomType = GameState.RoomType.BEDROOM
func _ready() -> void:
	set_highlight(false)

func _physics_process(delta: float) -> void:
	if animation_progress == 0.0:
		return
	
	animation_progress += delta

	var star = $Star
	var circle = $Circle
	if star != null && circle != null:
		star.rotate_z(delta * rotation_speed)
		circle.rotate_z(-delta * 0.5 * rotation_speed)
		rotation_speed += delta * 1

		var star_scale = 1.0 + 0.05 * sin(animation_progress * 2) * animation_progress
		star.scale = Vector3(star_scale, star_scale, star_scale)
		var circle_scale = 1.0 + 0.05 * cos(animation_progress * 2) * animation_progress
		circle.scale = Vector3(circle_scale, circle_scale, circle_scale)

	if animation_progress >= (7.0 - $GPUParticles3D.lifetime/2.0) && !fired_particles:
		fired_particles = true
		$GPUParticles3D.emitting = true
	if animation_progress >= 7.0:
		unlock()

func can_interact(_player: Player) -> bool:
	return animation_progress == 0.0

func interact(_player: Player) -> void:
	animation_progress = 0.01

	
func set_highlight(highlight_new: bool) -> void:
	print("highlighting for ", self.name, ": ", highlight_new)
	#TODO
	pass


func unlock() -> void:
	if $Wall == null:
		return
	$Wall.queue_free()
	$Circle.queue_free()
	$Star.queue_free()
	$CollisionShape3D.queue_free()
	
	var room_listeners = get_tree().get_nodes_in_group("room_listener")
	for room_listener in room_listeners:
		if room_listener is RoomListener:
			room_listener.on_room_unlocked(room_type)
