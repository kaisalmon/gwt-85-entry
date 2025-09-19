class_name UI
extends CanvasLayer

var default_mouse_mode: Input.MouseMode = Input.MOUSE_MODE_CAPTURED

@export_category("internal nodes")
@export var pause_overlay: ColorRect
@export var magic_value_label: Label


@export var magic_value_label_cozy: Label
@export var magic_value_label_hollow: Label
@export var magic_value_label_vivid: Label
@export var magic_value_label_windy: Label

@export var textbox_container: MarginContainer
@export var text_start: Label
@export var text_main: Label 
@export var text_end: Label

@export var debug_mode_ui: DebugModeUI
#var visual_magic_amounts: Dictionary[Recipe.MagicType, int] = {
	#Recipe.MagicType.SOFT: 0,
	#Recipe.MagicType.CRISPY: 0,
	#Recipe.MagicType.HOLLOW: 0,
	#Recipe.MagicType.BULKY: 0,
	#Recipe.MagicType.STURDY: 0
#}

var music_fade_tween: Tween = null
var music_mono_tween: Tween = null

var text_animate_tween: Tween = null

var is_debug_mode_active: bool = false
var is_on_pause_screen: bool = false

func _ready() -> void:
	process_mode = ProcessMode.PROCESS_MODE_ALWAYS
	GameState.ui = self
	set_pause_screen_active(false)
	hide_textbox()
	set_debug_mode_active(false, false)
	
	for type: Recipe.MagicType in Recipe.MagicType.values():
		set_magic_amount(type, 0)
	
func _input(event: InputEvent) -> void:
	if event.is_action_pressed("pause"):
		set_pause_screen_active(!is_on_pause_screen)
		Input.mouse_mode = Input.MOUSE_MODE_VISIBLE if get_tree().paused else default_mouse_mode
		
	if event.is_action_pressed("text_accept",):
		hide_textbox()
		
	if event.is_action_pressed("debug_mode"):
		set_debug_mode_active(!is_debug_mode_active)
		
		
func set_debug_mode_active(is_debug_mode_active_new: bool, change_paused: bool = true) -> void:
	is_debug_mode_active = is_debug_mode_active_new
	if change_paused:
		set_paused(is_debug_mode_active_new || is_on_pause_screen)
		Input.mouse_mode = Input.MOUSE_MODE_VISIBLE if get_tree().paused else default_mouse_mode

	if is_debug_mode_active_new && !Settings.is_debug_mode_available:
		return

	debug_mode_ui.visible = is_debug_mode_active_new
	if is_debug_mode_active:
		debug_mode_ui.show_only_main_debug_view()
		
func set_pause_screen_active(is_paused_new: bool) -> void:
	if is_instance_valid(music_fade_tween):
		music_fade_tween.kill()
	is_on_pause_screen = is_paused_new
	set_paused(is_paused_new|| is_debug_mode_active)
	pause_overlay.visible = is_paused_new
	
	var audio_effect_eqband: AudioEffectEQ = AudioServer.get_bus_effect(AudioServer.get_bus_index("Master"), 0)
	var audio_effect_stereo: AudioEffectStereoEnhance = AudioServer.get_bus_effect(AudioServer.get_bus_index("Master"), 1)

	#if is_paused_new:
		#set_audio_effect_enabled(true)
	
	var new_band1: float = -60 if is_paused_new else 0
	var new_band2: float = -50 if is_paused_new else 0
	var new_band3: float = -6 if is_paused_new else 0
	var new_band4: float = -20 if is_paused_new else 0
	var new_band5: float = -60 if is_paused_new else 0
	var new_band6: float = -60 if is_paused_new else 0
	
	var new_pan: float = 0 if is_paused_new else 1

	music_fade_tween = create_tween().set_parallel()
	music_fade_tween.tween_property(audio_effect_eqband, "band_db/32_hz", new_band1, 0.5)
	music_fade_tween.tween_property(audio_effect_eqband, "band_db/100_hz", new_band2, 0.4)
	music_fade_tween.tween_property(audio_effect_eqband, "band_db/320_hz", new_band3, 0.3)
	music_fade_tween.tween_property(audio_effect_eqband, "band_db/1000_hz", new_band4, 0.3)
	music_fade_tween.tween_property(audio_effect_eqband, "band_db/3200_hz", new_band5, 0.25)
	music_fade_tween.tween_property(audio_effect_eqband, "band_db/10000_hz", new_band6, 0.2)
	music_fade_tween.tween_property(audio_effect_stereo, "pan_pullout", new_pan, 0.4)
	
	#if !is_paused_new:
	#	music_fade_tween.finished.connect(set_audio_effect_enabled.bind(false))

func set_paused(is_paused_new: bool) -> void:
	get_tree().paused = is_paused_new
	Input.mouse_mode = Input.MOUSE_MODE_VISIBLE if get_tree().paused else default_mouse_mode

func set_audio_effect_enabled(is_enabled_new: bool) -> void:
	#AudioServer.set_bus_effect_enabled(AudioServer.get_bus_index("Master"), 0, is_enabled_new)
	print("set audio effect: ", is_enabled_new)


func set_magic_amount(type: Recipe.MagicType, magic_amount_new: int) -> void:
	# TODO: store the actual mechanical amounts, either here or in player or in game state
	pass
	get_label_by_type(type).text = str(magic_amount_new)

func get_label_by_type(magic_type: Recipe.MagicType) -> Label:
	match magic_type:
		Recipe.MagicType.COZY:
			return magic_value_label_cozy
		Recipe.MagicType.HOLLOW:
			return magic_value_label_hollow
		Recipe.MagicType.VIVID:
			return magic_value_label_vivid
		Recipe.MagicType.WINDY:
			return magic_value_label_windy	
	push_warning("no implementation found for UI.get_label_by_type() with type: ", Recipe.MagicType.keys()[magic_type])
	return null

#func increment_visual_magic_amount(type: Recipe.MagicType, amount: int) -> void:
	#if not visual_magic_amounts.has(type):
		#push_warning("no entry found in visual_magic_amounts for type: ", Recipe.MagicType.keys()[type])
		#return
	#visual_magic_amounts[type] += amount

func hide_textbox():
	text_start.text = ""
	text_main.text = ""
	text_end.text = ""
	textbox_container.hide()
	text_main.visible_ratio = 0

func show_textbox():
	text_start.text = ""
	textbox_container.show()
	
func show_text(next_text):
	text_main.text = next_text
	show_textbox()
	text_animate_tween = create_tween()
	text_animate_tween.tween_property(text_main, "visible_ratio", 1, 1)
