class_name ItemProvider
extends Interactable

@export var interaction_duration: float = 0.5
@export var produced_item: Item.ItemType
@export var source_mesh: MeshInstance3D
@onready var debug_label_3d: Label3D = $DebugLabel3D
@onready var pickup: AudioStreamPlayer = $pickup

var text_tween: Tween = null
var highlight_tween: Tween = null
var highlight_material: StandardMaterial3D
var default_albedo: Color
var highlight_albedo: Color

func _ready() -> void:
	highlight_material = source_mesh.get_active_material(0) as StandardMaterial3D	
	default_albedo = highlight_material.albedo_color
	highlight_albedo = Color.from_hsv(default_albedo.h, max(default_albedo.s - 0.3, 0), min(default_albedo.v + 0.2, 1.0))
	debug_label_3d.text = Item.ItemType.keys()[produced_item]
	set_highlight(null, false)

func can_interact(_player: Player) -> bool:
	return true

func interact(player: Player) -> void:
	print(player.name, ": interacting with ", self.name)
	
	if is_instance_valid(player.held_item):
		print("player can't pick up '", Item.ItemType.keys()[produced_item], "' from '", self.name, "' because he currently holds '", player.held_item)
		# TODO: should we allow the player to remove items from his hand if its from the same type?
		
		wiggle_text()
		return
	
	var new_item: Item = Item.get_scene(produced_item).instantiate() as Item
	player.set_item_in_hand(new_item)
	
	pickup.play()
	
func set_highlight(_player: Player, highlight_new: bool) -> void:
	if is_instance_valid(highlight_tween):
		highlight_tween.kill()
	
	
	var target_albedo: Color = highlight_albedo if highlight_new else default_albedo
	highlight_tween = create_tween()
	highlight_tween.tween_property(highlight_material, "albedo_color", target_albedo, 0.3)
	#print("highlighting for ", self.name, ": ", highlight_new)
	debug_label_3d.visible = highlight_new
	
func wiggle_text() -> void:
	if is_instance_valid(text_tween):
		text_tween.kill()
		
	text_tween = create_tween()
	text_tween.tween_method(tween_wiggle.bind(debug_label_3d.global_position), 0.0, 1.0, 0.5)
	
func tween_wiggle(progress: float, start_pos: Vector3) -> void:
	var displacement: float = sin(progress * 10) * 0.1
	debug_label_3d.global_position.x = start_pos.x + displacement * (1-progress)
	debug_label_3d.modulate = Color.DARK_RED.lerp(Color.WHITE, progress)
