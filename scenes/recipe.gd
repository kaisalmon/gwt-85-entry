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


static func magic_type_to_string(mtype: MagicType) -> String:
	match mtype:
		MagicType.SOFT: return "Soft"
		MagicType.CRISPY: return "Crispy"
		MagicType.HOLLOW: return "Hollow"
		MagicType.BULKY: return "Bulky"
		MagicType.STURDY: return "Sturdy"
		
	return "?unknown magic type?"
