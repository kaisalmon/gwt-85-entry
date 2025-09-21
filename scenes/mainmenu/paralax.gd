extends MeshInstance3D

@export var parallax_direction = Vector3.BACK
@export var walker: WalkManager
@export var parallax_amount = 2.0
@export var repeat_every = 2.0

var initial_position = Vector3.ZERO
var parallax_time = 0.0

func _ready() -> void:
    initial_position = self.position

func _process(delta: float) -> void:
    parallax_time += delta * parallax_amount * walker.walk_speed
    self.position = initial_position + parallax_direction * fmod(parallax_time, repeat_every)