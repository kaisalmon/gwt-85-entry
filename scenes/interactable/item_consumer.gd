class_name ItemConsumer
extends Interactable



## Consumes items and converts them to magic
## Used for the cauldron.


@export var recipe: Recipe
@export var cooldown_time: float = 1.0
@export var ready_item_position: Marker3D
@export var label_3d: Label3D
@export var source_mesh: MeshInstance3D
@onready var cauldroninteract_success: AudioStreamPlayer3D = $cauldroninteract_success
@onready var cauldroninteract_insert: AudioStreamPlayer3D = $cauldroninteract_insert
@onready var cauldroninteract_failure: AudioStreamPlayer3D = $cauldroninteract_failure
@onready var mana_orb: PackedScene = preload("res://ui/mana_orb.tscn")

var label_position: Vector3
var text_tween: Tween = null
var is_on_cooldown: bool = false
var is_currently_highlighted: bool
var provided_ingredients: Dictionary[Item.ItemType, int]

func _ready() -> void:
	label_position = label_3d.global_position
	set_highlight(null, false)
	update_recipe_display()
	if recipe.ingredients.size() == 0:
		push_warning("the recipe on ", self.name, " does not require any ingredients in the recipe")
	if recipe.produced_magic.size() == 0:
		push_warning("the recipe on ", self.name, " does not produce any magic from the recipe")
	
		
	if cauldroninteract_failure.playback_type == AudioServer.PLAYBACK_TYPE_SAMPLE && !OS.has_feature("web"):
		cauldroninteract_failure.playback_type = AudioServer.PLAYBACK_TYPE_DEFAULT
		
	if cauldroninteract_success.playback_type == AudioServer.PLAYBACK_TYPE_SAMPLE && !OS.has_feature("web"):
		cauldroninteract_success.playback_type = AudioServer.PLAYBACK_TYPE_DEFAULT
	
func can_interact(_player: Player) -> bool:
	return !is_on_cooldown

func interact(player: Player) -> void:
	if !is_instance_valid(player.held_item):
		#print("interacting with ", self.name, ": the player does not hold an item")
		return
	
	var held_item_type: Item.ItemType = player.held_item.item_type

	if has_necessary_ingredients_for(held_item_type):
		print("does not need item of the given type")
		cauldroninteract_failure.play()
		wiggle_text(player.get_look_ortho_vec3D())
		return
	
	#print("interacting with ", self.name, ": using item type: ", Item.ItemType.keys()[item])
	var item: Item = player.remove_and_get_current_item()
	item.reparent(self)
	item.drag_target = null
	
	cauldroninteract_insert.play()
	
	if provided_ingredients.has(held_item_type):
		provided_ingredients[held_item_type] = provided_ingredients[held_item_type] + 1
	else:
		provided_ingredients[held_item_type] = 1
	
	var tween: Tween = get_tree().create_tween().set_parallel(true)
	tween.tween_property(item, "global_position", self.global_position, 1.0)
	tween.tween_property(item, "scale", Vector3.ONE * 0.2, 1.0)
	
	var recipe_completed: bool = is_recipe_completed()
	if recipe_completed:
		is_on_cooldown = true
		var cooldown_tween: Tween = create_tween()
		cooldown_tween.tween_property(label_3d, "modulate", Color.GREEN_YELLOW, 0.3)
		cooldown_tween.tween_property(label_3d, "modulate", Color.TRANSPARENT, 0.2)
		update_recipe_display()

		await cooldown_tween.finished
		label_3d.visible = false
	
	await tween.finished
	item.queue_free()
	update_recipe_display()

	if recipe_completed:
		provide_magic(player)
		label_3d.modulate = Color.WHITE
		is_on_cooldown = false
		set_highlight(player, is_currently_highlighted)

	update_recipe_display()

	
func set_highlight(player: Player, highlight_new: bool) -> void:
	is_currently_highlighted = highlight_new
	if is_on_cooldown:
		return
	#print("highlighting for ", self.name, ": ", highlight_new)
	label_3d.visible = highlight_new
	
	if player != null && is_instance_valid(player.held_item):
		if highlight_new:
			player.held_item.reparent(self)
			player.held_item.drag_target = ready_item_position
			player.is_item_in_ready_pos = true
		else:
			player.set_item_to_hand_pos(player.held_item)
	
func has_necessary_ingredients_for(item_type: Item.ItemType) -> bool:
	if recipe.ingredients.size() == 0:
		return true
	if !recipe.ingredients.has(item_type):
		return true
	var needed_amount: int = recipe.ingredients[item_type]
	var current_amount: int = 0
	if provided_ingredients.has(item_type):
		current_amount = provided_ingredients[item_type]
	return current_amount >= needed_amount

func provide_magic(player: Player) -> void:
	for magic_type: Recipe.MagicType in recipe.produced_magic.keys():
		var delay = 0.0
		var total_amount =  recipe.produced_magic[magic_type]
		var duration = (log(total_amount) / log(2)) * 0.5
		var delta_delay = duration / total_amount
		#push_warning("adding produced magic of type ", Recipe.MagicType.keys()[magic_type], "... (types not implemented yet!)")
		if recipe.produced_magic[magic_type] == 0:
			push_warning("found produced magic definition of type (", Recipe.MagicType.keys()[magic_type], ") with a zero amount!!")

		var amount = recipe.produced_magic[magic_type]
		player.change_magic(magic_type, amount)

		for i in amount:
			delay += delta_delay
			var orb_instance: ManaOrb = mana_orb.instantiate()
			get_tree().current_scene.add_child(orb_instance)
			orb_instance.set_magic_type(magic_type)
			orb_instance.global_position = self.global_position
			orb_instance.delay = delay

		cauldroninteract_success.play()
	
	provided_ingredients.clear()

func update_recipe_display() -> void:
	var recipe_texts: Array[String] = []
	for item_type: Item.ItemType in recipe.ingredients.keys():
		if recipe.ingredients[item_type] <= 0:
			push_warning("the recipe on ", self.name, " has an item entry with a 0 (or less) amount for ", Item.ItemType.keys()[item_type])
			continue
		var needed_amount: int = recipe.ingredients[item_type]
		var current_amount: int = 0
		if provided_ingredients.has(item_type):
			current_amount = provided_ingredients[item_type]
			
		recipe_texts.append(Item.ItemType.keys()[item_type] + "s: " + str(current_amount) + "/" + str(needed_amount))

	#for item_type: Item.ItemType in provided_ingredients:
		#if !recipe.ingredients.has(item_type):
			#var current_amount: int = provided_ingredients[item_type]
			#recipe_texts.append(Item.ItemType.keys()[item_type] + "s: " + str(current_amount) + "/0")

	for magic_type: Recipe.MagicType in recipe.produced_magic.keys():
		if recipe.produced_magic[magic_type] <= 0:
			push_warning("the recipe on ", self.name, " has a produced magictype entry with a 0 (or less) amount for ", Recipe.MagicType.keys()[magic_type])
			continue
		
		recipe_texts.append(" => " + str(recipe.produced_magic[magic_type]) + " " + Recipe.magic_type_to_string(magic_type) + " magic ")


	label_3d.text = "\n".join(recipe_texts)

func is_recipe_completed() -> bool:
	for item_type: Item.ItemType in recipe.ingredients.keys():
		if !has_necessary_ingredients_for(item_type):
			return false
			
	return true
	
func wiggle_text(direction_vec: Vector3) -> void:
	if is_instance_valid(text_tween):
		text_tween.kill()
		#debug_label_3d.global_position = label_position
		
	text_tween = create_tween()
	text_tween.tween_method(tween_wiggle.bind(label_position, direction_vec), 0.0, 1.0, 0.5)
	
func tween_wiggle(progress: float, start_pos: Vector3, direction_vec: Vector3) -> void:
	var displacement: float = sin(progress * 10) * 0.1
	label_3d.global_position = start_pos + (direction_vec * displacement * (1-progress))
	label_3d.modulate = Color.DARK_RED.lerp(Color.WHITE, progress)
