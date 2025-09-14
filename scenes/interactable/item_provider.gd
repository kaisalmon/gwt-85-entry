class_name ItemProvider
extends Interactable

const START_WIGGLE_INTENSITY: float = 0.02
const FINAL_WIGGLE_INTENSITY: float = 0.2

const START_WIGGLE_SPEED: float = 0.5
const FINAL_WIGGLE_SPEED: float = 12.0

@export var produced_item: Item.ItemType
@export var interaction_duration: float = 2
@export var max_interaction_distance: float = 2.5
@export var source_mesh: MeshInstance3D
@export_category("internal nodes")
@export var label_3d: Label3D
@export var pickup_audio_stream_player: AudioStreamPlayer
@export var interaction_timer: Timer
@export var progress_mesh: MeshInstance3D

var text_tween: Tween = null
var highlight_tween: Tween = null
var highlight_material: StandardMaterial3D
var default_albedo: Color
var highlight_albedo: Color

var is_interacting: bool = false
var source_player: Player = null
var interaction_progress: float = 0

var progress_mesh_tween: Tween = null
var source_mesh_default_pos: Vector3
var progress_mesh_mat: StandardMaterial3D

func _ready() -> void:
	highlight_material = source_mesh.get_active_material(0) as StandardMaterial3D	
	progress_mesh_mat = progress_mesh.get_active_material(0) as StandardMaterial3D
	source_mesh_default_pos = source_mesh.global_position
	default_albedo = highlight_material.albedo_color
	highlight_albedo = Color.from_hsv(default_albedo.h, max(default_albedo.s - 0.3, 0), min(default_albedo.v + 0.2, 1.0))
	label_3d.text = Item.ItemType.keys()[produced_item]
	progress_mesh_mat.albedo_color.a = 0.0
	
	set_highlight(null, false)

func _process(delta: float) -> void:
	if !is_interacting:
		if interaction_progress > 0:
			interaction_progress -= delta * 2
			set_progress(interaction_progress / interaction_duration)
			source_mesh.global_position = source_mesh_default_pos
			#print("pickup stopped: ", interaction_progress)
		return
		
	interaction_progress += delta
	set_progress(interaction_progress / interaction_duration)

	var wiggle_intensity: float = lerp(START_WIGGLE_INTENSITY, FINAL_WIGGLE_INTENSITY, interaction_progress)
	var wiggle_speed: float = lerp(START_WIGGLE_SPEED, FINAL_WIGGLE_SPEED, interaction_progress)
	var wiggle_factor: float = sin(interaction_progress * wiggle_speed)
	source_mesh.global_position = source_mesh_default_pos + (source_player.get_look_ortho_vec3D() * wiggle_factor * wiggle_intensity)
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
	if is_instance_valid(player.held_item):
		print("player can't pick up '", Item.ItemType.keys()[produced_item], "' from '", self.name, "' because he currently holds '", player.held_item)
		# TODO: should we allow the player to remove items from his hand if its from the same type?
		
		wiggle_text(player.get_look_ortho_vec3D())
		return
		
	if is_interacting:
		return
		
	is_interacting = true
	tween_progress_mesh_visibility(true)
	label_3d.visible = false
	source_player = player
	#print(player.name, ": interacting with ", self.name)
	
func tween_progress_mesh_visibility(mesh_visible: bool) -> void:
	if is_instance_valid(progress_mesh_tween):
		progress_mesh_tween.kill()
		

	var mesh_alpha: float = 1.0 if mesh_visible else 0.0

	
	progress_mesh_tween = create_tween()
	progress_mesh_tween.tween_property(progress_mesh_mat, "albedo_color:a", mesh_alpha, 0.35)	

func stop_interact(_player: Player) -> void:
	tween_progress_mesh_visibility(false)
	label_3d.visible = true
	is_interacting = false
	
func on_interaction_finished() -> void:
	interaction_progress = 0
	stop_interact(source_player)
	source_mesh.global_position = source_mesh_default_pos
	var new_item: Item = Item.get_scene(produced_item).instantiate() as Item
	source_player.set_item_in_hand(new_item)
	
	pickup_audio_stream_player.play()
	
func set_highlight(_player: Player, highlight_new: bool) -> void:
	if is_instance_valid(highlight_tween):
		highlight_tween.kill()

	var target_albedo: Color = highlight_albedo if highlight_new else default_albedo
	highlight_tween = create_tween()
	highlight_tween.tween_property(highlight_material, "albedo_color", target_albedo, 0.3)
	#print("highlighting for ", self.name, ": ", highlight_new)
	label_3d.visible = highlight_new
	
func wiggle_text(direction_vec: Vector3) -> void:
	if is_instance_valid(text_tween):
		text_tween.kill()
		
	text_tween = create_tween()
	text_tween.tween_method(tween_wiggle.bind(label_3d.global_position, direction_vec), 0.0, 1.0, 0.5)
	
func tween_wiggle(progress: float, start_pos: Vector3, direction_vec: Vector3) -> void:
	var displacement: float = sin(progress * 10) * 0.1
	label_3d.global_position = start_pos + (direction_vec * displacement * (1-progress))
	label_3d.modulate = Color.DARK_RED.lerp(Color.WHITE, progress)

func set_progress(rel_progress: float) -> void:
	progress_mesh.scale.x = rel_progress
	#progress_mesh.position.x = -rel_progress / 2
	progress_mesh.rotation.y = source_player.get_look_ortho()
