class_name Util
extends Node

static var audio_effect_tween

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


static func set_paused_audio_effect(effect_active: bool, from_node: Node) -> void:
	if is_instance_valid(audio_effect_tween):
		audio_effect_tween.kill()
	var audio_effect_eqband: AudioEffectEQ = AudioServer.get_bus_effect(AudioServer.get_bus_index("Master"), 0)
	var audio_effect_stereo: AudioEffectStereoEnhance = AudioServer.get_bus_effect(AudioServer.get_bus_index("Master"), 1)

	#if effect_active:
		#set_audio_effect_enabled(true)
	
	var new_band1: float = -60 if effect_active else 0
	var new_band2: float = -50 if effect_active else 0
	var new_band3: float = -6 if effect_active else 0
	var new_band4: float = -20 if effect_active else 0
	var new_band5: float = -60 if effect_active else 0
	var new_band6: float = -60 if effect_active else 0
	
	var new_pan: float = 0 if effect_active else 1

	audio_effect_tween = from_node.create_tween().set_parallel()
	audio_effect_tween.tween_property(audio_effect_eqband, "band_db/32_hz", new_band1, 0.5)
	audio_effect_tween.tween_property(audio_effect_eqband, "band_db/100_hz", new_band2, 0.4)
	audio_effect_tween.tween_property(audio_effect_eqband, "band_db/320_hz", new_band3, 0.3)
	audio_effect_tween.tween_property(audio_effect_eqband, "band_db/1000_hz", new_band4, 0.3)
	audio_effect_tween.tween_property(audio_effect_eqband, "band_db/3200_hz", new_band5, 0.25)
	audio_effect_tween.tween_property(audio_effect_eqband, "band_db/10000_hz", new_band6, 0.2)
	audio_effect_tween.tween_property(audio_effect_stereo, "pan_pullout", new_pan, 0.4)
	#if !is_paused_new:
	#	music_fade_tween.finished.connect(set_audio_effect_enabled.bind(false))
	
static func reset_paused_audio_effect() -> void:
	if is_instance_valid(audio_effect_tween):
		audio_effect_tween.kill()
	var audio_effect_eqband: AudioEffectEQ = AudioServer.get_bus_effect(AudioServer.get_bus_index("Master"), 0)
	var audio_effect_stereo: AudioEffectStereoEnhance = AudioServer.get_bus_effect(AudioServer.get_bus_index("Master"), 1)
	audio_effect_eqband["band_db/32_hz"] = 0
	audio_effect_eqband["band_db/100_hz"] = 0
	audio_effect_eqband["band_db/320_hz"] = 0
	audio_effect_eqband["band_db/1000_hz"] = 0
	audio_effect_eqband["band_db/3200_hz"] = 0
	audio_effect_eqband["band_db/10000_hz"] = 0
	audio_effect_stereo["pan_pullout"] = 0
