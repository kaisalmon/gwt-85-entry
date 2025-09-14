extends Camera3D

var initial_angle_y = 0.0
var t = 0.0

func _ready():
	initial_angle_y = rotation.y

func _process(delta):
	t += delta * 0.5
	rotation.y = initial_angle_y + sin(t) * 1
