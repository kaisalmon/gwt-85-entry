extends Node
class_name WalkManager

@export var stride_length = 8.0
@export var limb_length = 8.0
@export var step_height = 4.0
@export var walk_speed = 4.0
@export var hip_offset = Vector3(.3, 0.0, 0.0)
@export var house_min_height = 2.0
@export var house_max_height = 3.0
@export var foot_angle_rate = 0.1 # How quickly the rotates, relative to its height
@export var foot_max_angle = 0.5 # Maximum angle the foot rotates, in radians

var l_foot;
var r_foot;
var house; 
var l_knee;
var r_knee;
var l_shin;
var r_shin;
var l_thigh;
var r_thigh;

var left_foot_planted = true

func _ready() -> void:
	l_foot = $LeftFoot
	r_foot = $RightFoot
	house = $House
	l_knee = $LeftKnee
	r_knee = $RightKnee
	l_shin = $LeftShin
	r_shin = $RightShin
	l_thigh = $LeftThigh
	r_thigh = $RightThigh

func get_planted_foot() -> Node3D:
	if left_foot_planted:
		return l_foot
	return r_foot

func get_swinging_foot() -> Node3D:
	if left_foot_planted:
		return r_foot
	return l_foot


func get_equidistant_point(a: Vector3, b: Vector3, distance: float, direction: Vector3) -> Vector3:
	# Calculates the circle of points that are `distance` away from both a and b
	# Then returns the point which is furthest in the `direction` vector
	# If the two points are greater than `distance * 2` apart, returns the midpoint

	var mid_point = (a + b) / 2
	var ab_dist = a.distance_to(b)
	if ab_dist > distance * 2:
		return mid_point
	var radius = sqrt(distance * distance - (ab_dist / 2) * (ab_dist / 2))
	# Sanity check: If ab_dist is aproximately, but less than, distance * 2, then radius will be:
	#  sqrt(x * x - (x * 2 / 2) * (x * 2 / 2)) = 0, which makes sense
	# If ab_dist is 0, then radius will be:
	# sqrt(x * x - 0) = x, which also makes sense
	
	var ab_dir = (b - a).normalized()
	var answer_plane = Plane(ab_dir, mid_point) # Plane with normal ab_dir that contains mid_point
	var direction_in_plane = answer_plane.project(direction).normalized()
	return mid_point + direction_in_plane * radius
	
func _process(delta: float) -> void:
	# self.position += walk_speed * delta * Vector3.FORWARD
	var swinging_foot = self.get_swinging_foot()
	var planted_foot = self.get_planted_foot()
	swinging_foot.position += walk_speed * delta * Vector3.FORWARD
	planted_foot.position -= walk_speed * delta * Vector3.FORWARD

	if swinging_foot.position.dot(Vector3.FORWARD) > planted_foot.position.dot(Vector3.FORWARD) + stride_length / 2.0:
		left_foot_planted = !left_foot_planted


	var distance = planted_foot.position.dot(Vector3.FORWARD) - swinging_foot.position.dot(Vector3.FORWARD)
	var cossine = cos(distance / stride_length * PI) # 0 when feet are together and when at max stride length, 1 when halfway
	swinging_foot.position.y = (cossine * step_height)

	#.                /|
	#. limb_length   / |  x
	#               /  | 
	#              -----
	#.           distance
	#. ( 2 * limb_length) = sqrt(x^2 + distance^2)
	#   (2* limb_length)^2 = x^2 + distance^2
	#   x^2 = (2*limb_length)^2 - distance^2
	#   x = sqrt((2*limb_length)^2 - distance^2)

	# if abs(distance) < limb_length * 2:
	# 	house.position.y =  sqrt(2 * (limb_length * limb_length) - distance * distance)
	house.position.y = house_min_height + (house_max_height - house_min_height) * (1.0 - abs(cossine))

	var l_hip = house.position + hip_offset
	var r_hip = house.position - hip_offset

	l_knee.position = get_equidistant_point(l_hip, l_foot.position, limb_length, Vector3.BACK)
	r_knee.position = get_equidistant_point(r_hip, r_foot.position, limb_length, Vector3.BACK)

	l_shin.position = l_foot.position
	l_shin.look_at(l_knee.position)
	r_shin.position = r_foot.position
	r_shin.look_at(r_knee.position)
	l_thigh.position = l_knee.position
	l_thigh.look_at(l_hip)
	r_thigh.position = r_knee.position
	r_thigh.look_at(r_hip)

	# Rotate feet based on height
	var foot_angle = -swinging_foot.position.y * foot_angle_rate
	foot_angle = clamp(foot_angle, -foot_max_angle, foot_max_angle)
	swinging_foot.rotation.x = foot_angle
	planted_foot.rotation.x = 0.0
