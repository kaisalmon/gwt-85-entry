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
	
static func is_in_editor() -> bool:
	return OS.has_feature("editor")
	
static func is_release_build() -> bool:
	return OS.has_feature("release")

static func set_bus_volume(bus_name: String, volume_linear: float) -> void:
	var vol_to_use: float = volume_linear
	if vol_to_use <= 0:
		vol_to_use = 0.00001
	var bus_index: int = AudioServer.get_bus_index(bus_name)	
	AudioServer.set_bus_volume_db(bus_index, linear_to_db(vol_to_use))
	
static func set_bus_muted(bus_name: String, is_muted_new: bool) -> void:
	var bus_index: int = AudioServer.get_bus_index(bus_name)
	AudioServer.set_bus_mute(bus_index, is_muted_new)
	
static func is_bus_muted(bus_name: String) -> bool:
	var bus_index: int = AudioServer.get_bus_index(bus_name)
	return AudioServer.is_bus_mute(bus_index)

static func set_fullscreen(is_fullscreen: bool) -> void:
	if is_fullscreen:
		DisplayServer.window_set_mode(DisplayServer.WINDOW_MODE_FULLSCREEN)
		DisplayServer.window_set_flag(DisplayServer.WINDOW_FLAG_BORDERLESS, Settings.FULLSCREEN_IS_BORDERLESS)
	else:
		DisplayServer.window_set_mode(DisplayServer.WINDOW_MODE_WINDOWED)
		DisplayServer.window_set_flag(DisplayServer.WINDOW_FLAG_BORDERLESS, false)

static func is_debug_mode_allowed() -> bool:
	return is_in_editor || str(ProjectSettings.get_setting("application/config/version")).ends_with("d")
