extends Node

const SAVE_USER_SETTINGS: bool = false
const SAVE_PATH: String = "user://settings.cfg"

const MASTER_BUS_NAME: String = "Master"
const SFX_BUS_NAME: String = "SFX"
const MUSIC_BUS_NAME: String = "Music"
const AMBIENCE_BUS_NAME: String = "Ambience"

var locale: StringName = &"en"
var master_volume_linear: float = 0.75
var music_volume_linear: float = 0.75
var sfx_volume_linear: float = 0.75
var ambience_volume_linear: float = 0.75

func reset_to_defaults() -> void:
	set_locale(&"en", false)
	set_master_volume(0.75, false)
	set_music_volume(0.75, false)
	set_sfx_volume(0.75, false)
	set_ambience_volume(0.75, false)

	save_to_file()
	
	TranslationServer.set_locale(locale)
	set_bus_volume(MASTER_BUS_NAME, master_volume_linear)
	set_bus_volume(SFX_BUS_NAME, music_volume_linear)
	set_bus_volume(MUSIC_BUS_NAME, sfx_volume_linear)
	set_bus_volume(AMBIENCE_BUS_NAME, ambience_volume_linear)

func _ready() -> void:
	reset_to_defaults()

func save_to_file() -> void:
	pass

func load_from_file() -> void:
	pass

func set_locale(locale_new: StringName, do_save: bool = true) -> void:
	locale = locale_new
	
	if do_save:
		save_to_file()

		
func set_master_volume(volume_linear_new: float, do_save: bool = true) -> void:
	master_volume_linear = volume_linear_new
	
	if do_save:
		save_to_file()
		
func set_music_volume(volume_linear_new: float, do_save: bool = true) -> void:
	music_volume_linear = volume_linear_new
	
	if do_save:
		save_to_file()
		
func set_sfx_volume(volume_linear_new: float, do_save: bool = true) -> void:
	sfx_volume_linear = volume_linear_new
	
	if do_save:
		save_to_file()
		
func set_ambience_volume(volume_linear_new: float, do_save: bool = true) -> void:
	ambience_volume_linear = volume_linear_new
	
	if do_save:
		save_to_file()

static func set_bus_volume(bus_name: String, volume_linear: float) -> void:
	AudioServer.set_bus_volume_db(AudioServer.get_bus_index(bus_name), linear_to_db(volume_linear))
