extends Area3D

var activated: bool = false
var player: Player = null
var cutscene_timer = 0.0
var duration = 0.0
var cutscene_data = []
@export var RECORDING = false
@export_file("*.tscn") var next_scene: String

func _ready() -> void:
	if not RECORDING:
		cutscene_data = load_csv()


func _on_game_end_area_body_entered(body: Node) -> void:
	if body is Player:
		activated = true
		player = body as Player


func _process(delta: float) -> void:
	if activated and player != null:
		player.has_noclip = false
		if RECORDING: 
			player.current_speed = lerp(player.current_speed, 1.0, delta * 3)
			record_position_and_rotation(player)
		else:
			player.disable_input = true
			play_cutscene(delta)

func play_cutscene(delta: float) -> void:
	GameState.ui.in_cutscene = true
	cutscene_timer += delta
	if cutscene_data.size() == 0:
		return
	var line = null
	for i in range(cutscene_data.size()):
		if cutscene_data[i]["time"] >= cutscene_timer:
			line = cutscene_data[i]
			break
	if line != null:  
		var target_pos: Vector3 = line["position"]
		player.position = player.position.move_toward(target_pos, clamp(cutscene_timer, 0, 1))

		var current_rot: Vector3 = Vector3(player.look_pivot.rotation.x, player.rotation.y, player.look_pivot.rotation.z)
		var target_rot: Vector3 = line["rotation"]
		var current_quaternion = Quaternion.from_euler(current_rot)
		var target_quaternion = Quaternion.from_euler(target_rot)
		var new_rot = current_quaternion.slerp(target_quaternion, 0.1).get_euler()
		# var new_rot = target_rot # This works perfectly, just with the choppiness of the original recording
		player.rotation.y = new_rot.y
		player.look_pivot.rotation.x = new_rot.x
		player.look_pivot.rotation.z = new_rot.z
	
	if cutscene_timer >= duration + 0.5:
		GameState.is_ending = true
		if cutscene_timer > duration + 1.5:
			get_tree().change_scene_to_file(next_scene)
			Input.mouse_mode = Input.MOUSE_MODE_VISIBLE

func record_position_and_rotation(player: Player) -> void:
	var pposition: Vector3 = player.position
	var protation: Vector3 = player.rotation
	var look_pivot: Node3D = player.look_pivot
	# Save in csv
	var file = FileAccess.open("res://final_cutscene.csv", FileAccess.READ_WRITE)
	if not file:
		FileAccess.open("res://final_cutscene.csv", FileAccess.WRITE_READ)
		file = FileAccess.open("res://final_cutscene.csv", FileAccess.READ_WRITE)
	file.seek_end()

	var time: float = cutscene_timer
	var line: String = str(time)
	line += "," + str(pposition.x) + "," + str(pposition.y) + "," + str(pposition.z)
	line += "," + str(look_pivot.rotation.x) + "," + str(protation.y) + "," + str(look_pivot.rotation.z)
	file.store_line(line)
	file.close()
	print(line)
		
func load_csv ():
	var file = FileAccess.open("res://final_cutscene.csv", FileAccess.READ)
	if file == null:
		print("No csv found")
		return
	var results = []
	var highest_time = 0.0
	while not file.eof_reached():
		var line: String = file.get_line()
		var arr = Array(line.split(","))
		if arr.size() < 7:
			continue
		var dict = {}
		dict["time"] = float(arr[0])
		highest_time = max(highest_time, dict["time"])
		dict["position"] = Vector3(float(arr[1]), float(arr[2]), float(arr[3]))
		dict["rotation"] = Vector3(float(arr[4]), float(arr[5]), float(arr[6]))
		results.append(dict)
	file.close()
	self.duration = highest_time
	return results
