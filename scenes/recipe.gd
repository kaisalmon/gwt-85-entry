class_name Recipe
extends Resource


enum MagicType {
	COZY,
	HOLLOW,
	VIVID,
	WINDY
}

#item -> amount
@export var ingredients: Dictionary[Item.ItemType, int]

#magic type -> amount
@export var produced_magic: Dictionary[MagicType, int]
