class_name Recipe
extends Resource


enum MagicType {
	SOFT,
	CRISPY,
	HOLLOW,
	BULKY,
	STURDY
}

#item -> amount
@export var ingredients: Dictionary[Item.ItemType, int]

#magic type -> amount
@export var produced_magic: Dictionary[MagicType, int]
