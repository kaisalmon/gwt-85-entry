class_name ItemProvider
extends Interactable

const START_WIGGLE_INTENSITY: float = 0.01
const FINAL_WIGGLE_INTENSITY: float = 0.05

const START_WIGGLE_SPEED: float = 10.0
const FINAL_WIGGLE_SPEED: float = 40.0

@export var item_source: ItemSource
@export var max_interaction_distance: float = 2.5
@export var valid_room: GameState.RoomType
@export_category("internal nodes")
@export var source_mesh: Node3D
@export var info_label_3d: InfoLabel3D
@export var pickup_audio_stream_player: AudioStreamPlayer
@export var progress_audio_stream_player: AudioStreamPlayer
@export var progress_mesh: MeshInstance3D
@export var cooldown_timer: Timer

#var text_tween: Tween = null
var orb_color_tween: Tween = null
var default_albedo: Color

var is_interacting: bool = false
var source_player: Player = null
var interaction_progress: float = 0

var progress_mesh_tween: Tween = null
var source_mesh_default_pos: Vector3 = Vector3.ZERO
var progress_mesh_mat: StandardMaterial3D

var is_on_cooldown: bool = false

func _ready() -> void:
	progress_mesh_mat = progress_mesh.get_active_material(0) as StandardMaterial3D
	cooldown_timer.wait_time = item_source.cooldown_duration
	if source_mesh:
		source_mesh_default_pos = source_mesh.global_position
	Settings.locale_changed.connect(translate_text)
	set_info_label_text_to_item()
	progress_mesh_mat.albedo_color.a = 0.0
	set_highlight(null, false)


func _process(delta: float) -> void:
	if is_on_cooldown:
		info_label_3d.text = get_cooldown_time_left()
		
	if !is_interacting:
		if progress_audio_stream_player: 
			progress_audio_stream_player.stop()
		if interaction_progress > 0:
			interaction_progress -= delta * 2
			set_progress_bar(interaction_progress / item_source.interaction_duration)
			if source_mesh:
				source_mesh.global_position = source_mesh_default_pos
			#print("pickup stopped: ", interaction_progress)
		return
	if !progress_audio_stream_player.playing:
		progress_audio_stream_player.play()
	interaction_progress += delta
	var relative_progress: float = interaction_progress / item_source.interaction_duration
	set_progress_bar(relative_progress)

	var wiggle_intensity: float = lerp(START_WIGGLE_INTENSITY, FINAL_WIGGLE_INTENSITY, relative_progress)
	var wiggle_speed: float = lerp(START_WIGGLE_SPEED, FINAL_WIGGLE_SPEED, relative_progress)
	var wiggle_factor: float = sin(relative_progress * wiggle_speed)
	if source_mesh:
		source_mesh.global_position = source_mesh_default_pos + (source_player.get_look_ortho_vec3D() * wiggle_factor * wiggle_intensity)

	#print("pickup: ", interaction_progress)
	if interaction_progress >= item_source.interaction_duration:
		on_interaction_finished()
		return
	
	if source_player.global_position.distance_to(self.global_position) > max_interaction_distance:
		stop_interact(source_player)
		return

func can_interact(_player: Player) -> bool:
	return valid_room == GameState.RoomType.NONE || _player.current_room == valid_room

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
	if source_mesh:
		source_mesh.global_position = source_mesh_default_pos
	give_item_to_player(item_source.item, source_player)
	pickup_audio_stream_player.play()
	cooldown_timer.start()
	is_on_cooldown = true
	pickup_audio_stream_player.play()

	
func set_progress_bar(rel_progress: float) -> void:
	progress_mesh.scale.x = rel_progress
	progress_mesh.rotation.y = source_player.get_look_ortho()
	progress_mesh_mat.albedo_color = Color(Color.html("d3d3d3"), progress_mesh_mat.albedo_color.a ).lerp(Color(Color.WHITE, progress_mesh_mat.albedo_color.a), rel_progress)

func _on_cooldown_timer_timeout() -> void:
	is_on_cooldown = false
	
	if !info_label_3d.is_wiggle_active:
		set_info_label_text_to_item()
	
func set_info_label_text_to_item() -> void:
	translate_text()
		
func get_cooldown_time_left() -> String:
	var time_left: float = cooldown_timer.time_left
	if time_left < 2.0:
		return str(snapped(time_left, 0.1))
	
	return str(roundi(cooldown_timer.time_left))

func _on_info_label_3d_wiggle_finished() -> void:
	if !is_on_cooldown:
		set_info_label_text_to_item()

static func give_item_to_player(item_type: Item.ItemType, player: Player) -> void:
	var new_item: Item = Item.get_scene(item_type).instantiate() as Item
	player.get_parent().add_child(new_item)
	player.set_item_in_hand(new_item)

func translate_text() -> void:
	if cooldown_timer.is_stopped():
		info_label_3d.text = tr(Util.item_type_to_trkey(item_source.item))

func set_highlight(_player: Player, highlight_new: bool) -> void:
	info_label_3d.visible = highlight_new
