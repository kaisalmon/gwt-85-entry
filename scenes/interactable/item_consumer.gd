class_name ItemConsumer
extends Interactable

## Consumes items and converts them to magic
## Used for the cauldron.


@export var recipe: Recipe
@export var source_mesh: MeshInstance3D
@export var provided_ingredients: Dictionary[Item.ItemType, int]
@export var debug_label_3d: Label3D
@onready var cauldroninteract_success: AudioStreamPlayer3D = $cauldroninteract_success
@onready var cauldroninteract_insert: AudioStreamPlayer3D = $cauldroninteract_insert

var text_tween: Tween = null

func _ready() -> void:
	set_highlight(false)
	update_recipe_display()
	if recipe.ingredients.size() == 0:
		push_warning("the recipe on ", self.name, " does not require any ingredients in the recipe")
	if recipe.produced_magic.size() == 0:
		push_warning("the recipe on ", self.name, " does not produce any magic from the recipe")
						
func can_interact(_player: Player) -> bool:
	#TODO ?
	return true


#TODO: should we only allow to add items required for the recipe? what about excess amount?
func interact(player: Player) -> void:
	if !is_instance_valid(player.held_item):
		#print("interacting with ", self.name, ": the player does not hold an item")
		return
	
	var held_item_type: Item.ItemType = player.held_item.item_type

	if has_necessary_ingredients_for(held_item_type):
		print("does not need item of the given type")
		
		wiggle_text()
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
		
	if is_recipe_completed():
		provide_magic(player)
		
	update_recipe_display()
	
	var tween: Tween = get_tree().create_tween().set_parallel(true)
	tween.tween_property(item, "global_position", self.global_position, 1.0)
	tween.tween_property(item, "scale", Vector3.ONE * 0.2, 1.0)
	await tween.finished
	item.queue_free()
	
func set_highlight(highlight_new: bool) -> void:
	#print("highlighting for ", self.name, ": ", highlight_new)
	debug_label_3d.visible = highlight_new
	
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
		push_warning("adding produced magic of type ", Recipe.MagicType.keys()[magic_type], "... (types not implemented yet!)")
		if recipe.produced_magic[magic_type] == 0:
			push_warning("found produced magic definition of type (", Recipe.MagicType.keys()[magic_type], ") with a zero amount!!")
		
		player.change_magic(magic_type, recipe.produced_magic[magic_type])
		
		cauldroninteract_success.play()
	
	provided_ingredients.clear()

func update_recipe_display() -> void:
	var recipe_texts: Array[String] = []
	for item_type: Item.ItemType in recipe.ingredients.keys():
		if recipe.ingredients[item_type] == 0:
			push_warning("the recipe on ", self.name, " has an item entry with a 0 amount for ", Item.ItemType.keys()[item_type])
			continue
		var needed_amount: int = recipe.ingredients[item_type]
		var current_amount: int = 0
		if provided_ingredients.has(item_type):
			current_amount = provided_ingredients[item_type]
			
		recipe_texts.append(Item.ItemType.keys()[item_type] + "s: " + str(current_amount) + "/" + str(needed_amount))

	for item_type: Item.ItemType in provided_ingredients:
		if !recipe.ingredients.has(item_type):
			var current_amount: int = provided_ingredients[item_type]
			recipe_texts.append(Item.ItemType.keys()[item_type] + "s: " + str(current_amount) + "/0")


	debug_label_3d.text = "\n".join(recipe_texts)

func is_recipe_completed() -> bool:
	for item_type: Item.ItemType in recipe.ingredients.keys():
		if !has_necessary_ingredients_for(item_type):
			return false
			
	return true
	
func wiggle_text() -> void:
	if is_instance_valid(text_tween):
		text_tween.kill()
		
	text_tween = create_tween()
	text_tween.tween_method(tween_wiggle.bind(debug_label_3d.global_position), 0.0, 1.0, 0.5)
	
func tween_wiggle(progress: float, start_pos: Vector3) -> void:
	var displacement: float = sin(progress * 10) * 0.1
	debug_label_3d.global_position.x = start_pos.x + displacement * (1-progress)
	debug_label_3d.modulate = Color.DARK_RED.lerp(Color.WHITE, progress)
