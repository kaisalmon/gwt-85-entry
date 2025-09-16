class_name Util
extends Node


static func room_type_to_trkey(rtype: GameState.RoomType) -> String:
	return "room."+(GameState.RoomType.keys()[rtype] as String).to_lower()
	
static func magic_type_to_trkey(mtype: Recipe.MagicType) -> String:
	return "magic."+(Recipe.MagicType.keys()[mtype] as String).to_lower()
	
static func item_type_to_trkey(itype: Item.ItemType) -> String:
	return "item."+(Item.ItemType.keys()[itype] as String).to_lower()

static func pluralize_item_type_to_trkey(itype: Item.ItemType, amount: int) -> String:
	var suffix: String = "" if amount == 1 else ".plural"
	return item_type_to_trkey(itype)+suffix
#
#static func magic_type_to_string(mtype: MagicType) -> String:
	#match mtype:
		#MagicType.SOFT: return "magic.soft"
		#MagicType.CRISPY: return "magic.crispy"
		#MagicType.HOLLOW: return "magic.hollow"
		#MagicType.BULKY: return "magic.bulky"
		#MagicType.STURDY: return "magic.sturdy"
		#
	#return "?unknown magic type?"

static func set_sample_type_if_web(node: Node) -> void:
	if !(node is AudioStreamPlayer||  node is AudioStreamPlayer2D ||  node is AudioStreamPlayer3D):
		push_warning("set_sample_type_if_web only supports audio stream players. provided node: ", node.name)
	
	if is_web_build():
		node.playback_type = AudioServer.PLAYBACK_TYPE_SAMPLE

static func is_web_build() -> bool:
	return OS.has_feature("web")
