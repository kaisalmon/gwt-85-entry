class_name SettingsUI
extends MarginContainer

signal back_pressed

@onready var overall_fader: HSlider = $VBoxContainer/OverallHBC/OverallFader
@onready var music_fader: HSlider = $VBoxContainer/MusicHBC/MusicFader
@onready var sfx_fader: HSlider = $VBoxContainer/SFXHBC/SFXFader
@onready var ambience_fader: HSlider = $VBoxContainer/AmbienceHBC/AmbienceFader

@onready var overall_value_label: Label = $VBoxContainer/OverallHBC/OverallValueLabel
@onready var music_value_label: Label = $VBoxContainer/MusicHBC/MusicValueLabel
@onready var sfx_value_label: Label = $VBoxContainer/SFXHBC/SFXValueLabel
@onready var ambience_value_label: Label = $VBoxContainer/AmbienceHBC/AmbienceValueLabel

@onready var locale_option_button: OptionButton = $VBoxContainer/LanguageHBC/LocaleOptionButton
@onready var fullscreen_button: CheckBox = $VBoxContainer/FullscreenHBC/FullscreenButton
@onready var click: AudioStreamPlayer = $click
@onready var hover: AudioStreamPlayer = $hover

var fullscreen_active: bool

func _ready() -> void:
	load_values_from_settings()
	
#func _load_values() -> void:
	#change_locale(Settings.locale)
	#Settings.locale_changed.emit()
	#locale_option_button.select(get_locale_button_id(Settings.locale))
	#
func load_values_from_settings() -> void:
	overall_fader.set_value_no_signal(Settings.master_volume_linear)
	music_fader.set_value_no_signal(Settings.music_volume_linear)
	sfx_fader.set_value_no_signal(Settings.sfx_volume_linear)
	ambience_fader.set_value_no_signal(Settings.ambience_volume_linear)

	set_audio_slider_value(overall_value_label, Settings.master_volume_linear)
	set_audio_slider_value(music_value_label, Settings.music_volume_linear)
	set_audio_slider_value(sfx_value_label, Settings.sfx_volume_linear)
	set_audio_slider_value(ambience_value_label, Settings.ambience_volume_linear)
	
	set_fullscreen_active(Settings.fullscreen_active)

	locale_option_button.selected = get_locale_button_id(Settings.locale)
	
func _on_overall_fader_value_changed(value: float) -> void:
	hover.play()
	Settings.set_master_volume(value, false)
	set_audio_slider_value(overall_value_label, value)
	Util.set_bus_volume(Settings.MASTER_BUS_NAME, value)

func _on_music_fader_value_changed(value: float) -> void:
	hover.play()
	Settings.set_music_volume(value, false)
	set_audio_slider_value(music_value_label, value)
	Util.set_bus_volume(Settings.MUSIC_BUS_NAME, value)

func _on_sfx_fader_value_changed(value: float) -> void:
	hover.play()
	Settings.set_sfx_volume(value, false)
	set_audio_slider_value(sfx_value_label, value)
	Util.set_bus_volume(Settings.SFX_BUS_NAME, value)

func _on_ambience_fader_value_changed(value: float) -> void:
	hover.play()
	Settings.set_ambience_volume(value, false)
	set_audio_slider_value(ambience_value_label, value)
	Util.set_bus_volume(Settings.AMBIENCE_BUS_NAME, value)

func _on_overall_fader_drag_ended(value_changed: bool) -> void:
	click.play()
	if value_changed:
		Settings.set_ambience_volume(overall_fader.value)

func _on_music_fader_drag_ended(value_changed: bool) -> void:
	click.play()
	if value_changed:
		Settings.set_ambience_volume(music_fader.value)
		
func _on_sfx_fader_drag_ended(value_changed: bool) -> void:
	click.play()
	if value_changed:
		Settings.set_ambience_volume(sfx_fader.value)
		
func _on_ambience_fader_drag_ended(value_changed: bool) -> void:
	click.play()
	if value_changed:
		Settings.set_ambience_volume(ambience_fader.value)

func set_audio_slider_value(label: Label, value_linear: float) -> void:
	label.text = str(roundi(value_linear * 100)) + "%"
	

static func get_languagecode_fom_locale_uitext(locale_str: String) -> StringName:
	if locale_str.to_lower().contains("deutsch"):
		return &"de";
	elif locale_str.to_lower().contains("русский"):
		return &"ru"
	elif locale_str.to_lower().contains("svenska"):
		return &"sv"
	else:
		return &"en";

static func get_locale_button_id(locale_short: StringName) -> int:
	match locale_short:
		&"en": return 0
		&"de": return 1
		&"ru": return 2		
		&"sv": return 3


	return 0
	
func _on_locale_option_button_item_selected(index: int) -> void:
	click.play()
	var locale_new: String = locale_option_button.get_item_text(index);
	var locale_new_short: String = get_languagecode_fom_locale_uitext(locale_new);
	change_locale(locale_new_short)
	Settings.set_locale(locale_new_short)
	
func change_locale(locale_short: StringName) -> void:
	click.play()
	TranslationServer.set_locale(locale_short)
	
func _on_fullscreen_button_toggled(toggled_on: bool) -> void:
	click.play()
	set_fullscreen_active(toggled_on)
		
func set_fullscreen_active(is_active_new: bool) -> void:
	fullscreen_active = is_active_new
	Util.set_fullscreen(is_active_new)
	Settings.set_fullscreen_active(is_active_new, true)
	fullscreen_button.set_pressed_no_signal(fullscreen_active)
	
func _on_back_button_pressed() -> void:
	click.play()
	back_pressed.emit()

func _on_reset_button_pressed() -> void:
	click.play()
	Settings.reset_to_defaults(true)
	load_values_from_settings()
