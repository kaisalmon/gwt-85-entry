class_name Item
extends Node3D

const BOOK_ITEM_SCENE: PackedScene = preload("res://scenes/item/book_item.tscn") as PackedScene
const CANDLE_ITEM_SCENE: PackedScene = preload("res://scenes/item/candle_item.tscn") as PackedScene
const KNIFE_ITEM_SCENE: PackedScene = preload("res://scenes/item/knife_item.tscn") as PackedScene

enum ItemType {
	BOOK,
	CANDLE,
	KNIFE
}

@export var item_type: ItemType


static func get_scene(scene_item_type: ItemType) -> PackedScene:
	match scene_item_type:
		ItemType.BOOK:
			return BOOK_ITEM_SCENE
		ItemType.CANDLE:
			return CANDLE_ITEM_SCENE
		ItemType.KNIFE:
			return KNIFE_ITEM_SCENE
			
	push_warning("Item.get_scene(): no implementation for " + ItemType.keys()[scene_item_type] + " exists yet!")
	return null
