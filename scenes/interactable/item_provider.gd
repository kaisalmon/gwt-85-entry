class_name ItemProvider
extends Interactable

const START_WIGGLE_INTENSITY: float = 0.01
const FINAL_WIGGLE_INTENSITY: float = 0.3

const START_WIGGLE_SPEED: float = 1.0
const FINAL_WIGGLE_SPEED: float = 45.0

@export var produced_item: Item.ItemType
@export var interaction_duration: float = 2
@export var cooldown_duration: float = 3.0
@export var max_interaction_distance: float = 2.5
@export var source_mesh: MeshInstance3D
@export var highlight_albedo: Color = Color.GREEN_YELLOW
@export var finalzie_albedo: Color = Color.WHITE
@export_category("internal nodes")
@export var info_label_3d: InfoLabel3D
@export var pickup_audio_stream_player: AudioStreamPlayer
@export var progress_mesh: MeshInstance3D
@export var cooldown_timer: Timer

#var text_tween: Tween = null
var orb_color_tween: Tween = null
var highlight_material: StandardMaterial3D
var default_albedo: Color

var is_interacting: bool = false
var source_player: Player = null
var interaction_progress: float = 0

var progress_mesh_tween: Tween = null
var source_mesh_default_pos: Vector3
var progress_mesh_mat: StandardMaterial3D

var is_on_cooldown: bool = false

func _ready() -> void:
	highlight_material = source_mesh.get_active_material(0) as StandardMaterial3D	
	progress_mesh_mat = progress_mesh.get_active_material(0) as StandardMaterial3D
	cooldown_timer.wait_time = cooldown_duration
	source_mesh_default_pos = source_mesh.global_position
	default_albedo = highlight_material.albedo_color
	#highlight_albedo = Color.from_hsv(default_albedo.h, max(default_albedo.s - 0.3, 0), min(default_albedo.v + 0.2, 1.0))
	set_info_label_text_to_item()
	progress_mesh_mat.albedo_color.a = 0.0

	set_highlight(null, false)

func _process(delta: float) -> void:
	#var alpha: float = progress_mesh_mat.albedo_color.a
	#if alpha > 0:
		#print(self.name + ": albedo alpha: ", alpha)
	if is_on_cooldown:
		info_label_3d.text = get_cooldown_time_left()
		
	if !is_interacting:
		if interaction_progress > 0:
			interaction_progress -= delta * 2
			set_progress_bar(interaction_progress / interaction_duration)
			source_mesh.global_position = source_mesh_default_pos
			#print("pickup stopped: ", interaction_progress)
		return

	interaction_progress += delta
	var relative_progress: float = interaction_progress / interaction_duration
	set_progress_bar(relative_progress)

	var wiggle_intensity: float = lerp(START_WIGGLE_INTENSITY, FINAL_WIGGLE_INTENSITY, relative_progress)
	var wiggle_speed: float = lerp(START_WIGGLE_SPEED, FINAL_WIGGLE_SPEED, relative_progress)
	var wiggle_factor: float = sin(relative_progress * wiggle_speed)
	source_mesh.global_position = source_mesh_default_pos + (source_player.get_look_ortho_vec3D() * wiggle_factor * wiggle_intensity)
	highlight_material.albedo_color = lerp(highlight_albedo, finalzie_albedo, interaction_progress/interaction_duration)

	#print("pickup: ", interaction_progress)
	if interaction_progress >= interaction_duration:
		on_interaction_finished()
		return
	
	if source_player.global_position.distance_to(self.global_position) > max_interaction_distance:
		stop_interact(source_player)
		return

func can_interact(_player: Player) -> bool:
	return true

func interact(player: Player) -> void:
	if is_instance_valid(player.held_item) || is_on_cooldown:
		#print("player can't pick up '", Item.ItemType.keys()[produced_item], "' from '", self.name, "' because he currently holds '", player.held_item)
		# TODO: should we allow the player to remove items from his hand if its from the same type?
		
		info_label_3d.wiggle_text(player.get_look_ortho_vec3D())
		return
		
		
	if is_interacting:
		return
		
	is_interacting = true
	tween_progress_mesh_visibility(true)
	info_label_3d.visible = false
	source_player = player
	if is_instance_valid(orb_color_tween):
		orb_color_tween.kill()
	#print(player.name, ": interacting with ", self.name)
	
func tween_progress_mesh_visibility(mesh_visible: bool) -> void:
	if is_instance_valid(progress_mesh_tween):
		progress_mesh_tween.kill()
		
	var mesh_alpha: float = 1.0 if mesh_visible else 0.0
	
	progress_mesh_tween = create_tween()
	progress_mesh_tween.tween_property(progress_mesh_mat, "albedo_color:a", mesh_alpha, 0.35)	
	await progress_mesh_tween.finished

func stop_interact(_player: Player) -> void:
	tween_progress_mesh_visibility(false)
	info_label_3d.visible = true
	is_interacting = false
	
func on_interaction_finished() -> void:
	interaction_progress = 0
	stop_interact(source_player)
	source_mesh.global_position = source_mesh_default_pos
	var new_item: Item = Item.get_scene(produced_item).instantiate() as Item
	source_player.set_item_in_hand(new_item)
	cooldown_timer.start()
	is_on_cooldown = true
	pickup_audio_stream_player.play()
	
func set_highlight(_player: Player, highlight_new: bool) -> void:

	if !is_on_cooldown && highlight_new:
		if is_instance_valid(orb_color_tween):
			orb_color_tween.kill()

		var target_color: Color = highlight_albedo if highlight_new else default_albedo
		orb_color_tween = create_tween()
		orb_color_tween.tween_property(highlight_material, "albedo_color", target_color, 0.2)
		#print("highlighting for ", self.name, ": ", highlight_new)
	info_label_3d.visible = highlight_new
	
#func wiggle_text(direction_vec: Vector3) -> void:
	#if is_instance_valid(text_tween):
		#text_tween.kill()
		#
	#text_tween = create_tween()
	#text_tween.tween_method(tween_wiggle.bind(label_position, direction_vec), 0.0, 1.0, 0.5)
	#
#func tween_wiggle(progress: float, start_pos: Vector3, direction_vec: Vector3) -> void:
	#var displacement: float = sin(progress * 10) * 0.1
	#label_3d.global_position = start_pos + (direction_vec * displacement * (1-progress))
	#label_3d.modulate = Color.DARK_RED.lerp(Color.WHITE, progress)

func set_progress_bar(rel_progress: float) -> void:
	progress_mesh.scale.x = rel_progress
	#progress_mesh.position.x = -rel_progress / 2
	progress_mesh.rotation.y = source_player.get_look_ortho()
	progress_mesh_mat.albedo_color = Color(Color.html("d3d3d3"), progress_mesh_mat.albedo_color.a ).lerp(Color(Color.WHITE, progress_mesh_mat.albedo_color.a), rel_progress)

func _on_cooldown_timer_timeout() -> void:
	is_on_cooldown = false
	
	if !info_label_3d.is_wiggle_active:
		set_info_label_text_to_item()
	
func set_info_label_text_to_item() -> void:
	info_label_3d.text = tr(Util.item_type_to_trkey(produced_item))
	
func get_cooldown_time_left() -> String:
	return str(roundi(cooldown_timer.time_left))


func _on_info_label_3d_wiggle_finished() -> void:
	if !is_on_cooldown:
		set_info_label_text_to_item()
