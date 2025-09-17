class_name RoomExpander
extends Interactable

var animation_progress: float = 0.0
var rotation_speed: float = 0;
var fired_particles: bool = false

@export var room_type: GameState.RoomType = GameState.RoomType.BEDROOM
@export var required_magic: Dictionary[Recipe.MagicType, int]
@export var unlock_time: float = 7.0
@export var scale_factor: float = 0.6
@export var deactivated_color: Color = Color.DIM_GRAY
@export var highlight_color: Color = Color.GRAY
@export var activated_color: Color = Color.WHITE
@export_category("internal nodes")
@export var star_mesh: MeshInstance3D
@export var circle_mesh: MeshInstance3D
@export var wall: MeshInstance3D
@export var gpu_particles_3d: GPUParticles3D
@export var collision_shape_3d: CollisionShape3D
@export var doorframe: MeshInstance3D
@export var info_label_3d: InfoLabel3D
@onready var dooropen: AudioStreamPlayer3D = $dooropen
@onready var dooropen_end: AudioStreamPlayer3D = $dooropen_end

var door_unlocked: bool = false
var has_started_animation: bool = false

#var default_circle_scale: Vector3
var default_star_scale: Vector3
var circle_mat: StandardMaterial3D
var star_mat: StandardMaterial3D
var label_position: Vector3
var text_tween: Tween = null

var provided_magic: Dictionary[Recipe.MagicType, int] = {}

func _ready() -> void:
	Util.set_sample_type_if_web(dooropen)
	Util.set_sample_type_if_web(dooropen_end)
	
	for mtype: Recipe.MagicType in required_magic.keys():
		provided_magic[mtype] = 0
		
	init_circle()
	set_highlight(null, false)
	update_requirement_display()

func _physics_process(delta: float) -> void:
	if door_unlocked:
		return
	if animation_progress == 0.0:
		return
	
	animation_progress += delta

	if star_mesh != null && circle_mesh != null:
		star_mesh.rotate_z(delta * rotation_speed)
		circle_mesh.rotate_z(-delta * 0.5 * rotation_speed)
		rotation_speed += delta * 1

		var star_scale = 1.0 + 0.025 * sin(animation_progress * 2) * animation_progress
		star_mesh.scale = Vector3(star_scale, star_scale, star_scale) * scale_factor
		var circle_scale = 1.0 + 0.025 * cos(animation_progress * 2) * animation_progress
		circle_mesh.scale = Vector3(circle_scale, circle_scale, circle_scale)

	if animation_progress >= (unlock_time - gpu_particles_3d.lifetime/2.0) && !fired_particles:
		fired_particles = true
		gpu_particles_3d.emitting = true
	if animation_progress >= unlock_time:
		unlock()

func can_interact(_player: Player) -> bool:
	return animation_progress == 0.0

func interact(player: Player) -> void:
	if has_started_animation:
		return
	
	var finished: bool = has_all_magic()
	if !finished:
		var received_any_magic: bool = provide_available_magic()

		if !received_any_magic:
			display_no_magic_anim(player.get_look_ortho_vec3D())
			return
		else:
			update_requirement_display()
			if !has_all_magic():
				return
	
	has_started_animation = true
	animation_progress = 0.01
	dooropen.play()
	GameState.music_player.progress_music(room_type)
	
	fadeout_text()
		
	var start_anim_tween: Tween = create_tween().set_trans(Tween.TRANS_SPRING).set_parallel(true)
	start_anim_tween.tween_property(self, "scale_factor", 1.0, 0.4)
	start_anim_tween.tween_property(self, "circle_mat:albedo_color", activated_color, 0.4)
	start_anim_tween.tween_property(self, "star_mat:albedo_color", activated_color, 0.4)	
	
	var room_listeners = get_tree().get_nodes_in_group("room_listener")
	for room_listener in room_listeners:
		if room_listener is RoomListener:
			room_listener.on_room_unlock_start(room_type, unlock_time)

	update_requirement_display()
	
func set_highlight(_player: Player, highlight_new: bool) -> void:
	if has_started_animation || door_unlocked:
		return
	#print("highlighting for ", self.name, ": ", highlight_new)
	info_label_3d.visible = highlight_new
	
	star_mat.albedo_color = highlight_color if highlight_new else deactivated_color
	circle_mat.albedo_color = highlight_color if highlight_new else deactivated_color

func unlock() -> void:
	if door_unlocked: 
		return
	door_unlocked = true
	wall.queue_free()
	circle_mesh.queue_free()
	star_mesh.queue_free()
	collision_shape_3d.queue_free()
	doorframe.visible = true
	dooropen_end.play()
	GameState.ui.show_text("new room!")
	
	var room_listeners = get_tree().get_nodes_in_group("room_listener")
	for room_listener in room_listeners:
		if room_listener is RoomListener:
			room_listener.on_room_unlocked(room_type)

func init_circle() -> void:
	star_mat = star_mesh.material_override
	circle_mat = circle_mesh.material_override
	star_mat.albedo_color = deactivated_color
	circle_mat.albedo_color = deactivated_color
	default_star_scale = star_mesh.scale
	#default_circle_scale = circle_mesh.scale
	star_mesh.scale = default_star_scale * scale_factor
	#circle_mesh.scale = default_circle_scale * initial_scale_factor
	
## returns true if anything was provided
func provide_available_magic() -> bool:
	var has_provided_anything: bool = false	
	for mtype: Recipe.MagicType in required_magic.keys():
		var remaining_magic_amount: int = get_remaining_magic_amount_for(mtype)
		if remaining_magic_amount > 0:
			var added_amount: int = GameState.remove_magic(mtype, remaining_magic_amount)
			if added_amount > 0:
				has_provided_anything = true
				provided_magic[mtype] += added_amount
		
	return has_provided_anything
			
func get_remaining_magic_amount_for(magic_type: Recipe.MagicType) -> int:
	if required_magic.size() == 0:
		return 0
	if !required_magic.has(magic_type):
		return 0
	var needed_amount: int = required_magic[magic_type]
	var current_amount: int = 0
	if provided_magic.has(magic_type):
		current_amount = provided_magic[magic_type]
	return max(needed_amount - current_amount, 0)

func has_all_magic() -> bool:
	for mtype: Recipe.MagicType in required_magic.keys():
		if get_remaining_magic_amount_for(mtype) > 0:
			return false
	return true

func display_no_magic_anim(direction_vec: Vector3) -> void:
	#wiggle_text(direction_vec)
	info_label_3d.wiggle_text(direction_vec)

#func wiggle_text(direction_vec: Vector3) -> void:
	#if is_instance_valid(text_tween):
		#text_tween.kill()
		#
	#text_tween = create_tween()
	#text_tween.tween_method(tween_wiggle.bind(label_3d.global_position, direction_vec), 0.0, 1.0, 0.5)
	#
#func tween_wiggle(progress: float, start_pos: Vector3, direction_vec: Vector3) -> void:
	#var displacement: float = sin(progress * 10) * 0.1
	#label_3d.global_position = start_pos + (direction_vec * displacement * (1-progress))
	#label_3d.modulate = Color.DARK_RED.lerp(Color.WHITE, progress)

func update_requirement_display() -> void:
	var recipe_texts: Array[String] = []
	for mtype: Recipe.MagicType in required_magic.keys():
		if required_magic[mtype] <= 0:
			push_warning("the required on ", self.name, " has an item entry with a 0 (or less) amount for ", Recipe.MagicType.keys()[mtype])
			continue
		var needed_amount: int = required_magic[mtype]
		var current_amount: int = 0
		if provided_magic.has(mtype):
			current_amount = provided_magic[mtype]
		recipe_texts.append(tr(Util.magic_type_to_trkey(mtype)) + ": " + str(current_amount) + "/" + str(needed_amount))

	info_label_3d.text = "\n".join(recipe_texts)

func fadeout_text() -> void:
	var fadeout_text_tween: Tween = create_tween()
	fadeout_text_tween.tween_property(info_label_3d, "modulate", Color.GREEN_YELLOW, 0.3)
	fadeout_text_tween.tween_property(info_label_3d, "modulate", Color.TRANSPARENT, 0.2)
	await  fadeout_text_tween.finished
	info_label_3d.visible = false
