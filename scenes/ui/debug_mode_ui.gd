class_name DebugModeUI
extends MarginContainer

@export var magic_amount_for_single_type: int = 10
@export_category("internal nodes")
@export var main_debug_vbc: VBoxContainer
@export var item_vbc: VBoxContainer
@export var magic_vbc: VBoxContainer
@export var teleport_vbc: VBoxContainer
@export var open_door_vbc: VBoxContainer

func _ready() -> void:
	pass

func show_only_main_debug_view() -> void:
	main_debug_vbc.visible = true
	item_vbc.visible = false
	teleport_vbc.visible = false
	magic_vbc.visible = false
	open_door_vbc.visible = false
	
#region Sub Menu Navigation
func _on_back_pressed() -> void:
	show_only_main_debug_view()

func _on_give_magic_menu_pressed() -> void:
	main_debug_vbc.visible = false
	magic_vbc.visible = true

func _on_give_item_menu_pressed() -> void:
	main_debug_vbc.visible = false
	item_vbc.visible = true

func _on_teleport_to_menu_pressed() -> void:
	main_debug_vbc.visible = false
	teleport_vbc.visible = true
	
func _on_open_door_menu_pressed() -> void:
	main_debug_vbc.visible = false
	open_door_vbc.visible = true
#endregion
	
func _on_no_clip_toggled(toggled_on: bool) -> void:
	print("[DebugModeUI]: Toggle NOCLIP on player to ", toggled_on)
	GameState.player.set_noclip_enabled(toggled_on)

func _on_give_all_magic_pressed() -> void:
	print("[DebugModeUI]: Giving ", GameState.MAX_MAGIC, " of each magic type")
	for magic_type: Recipe.MagicType in Recipe.MagicType.values():
		GameState.change_magic(magic_type, GameState.MAX_MAGIC)

func _on_give_magic_pressed(magic_type_int: int) -> void:
	var magic_type_to_give: Recipe.MagicType = magic_type_int as Recipe.MagicType
	print("[DebugModeUI]: Giving ", magic_amount_for_single_type, " '", Recipe.MagicType.keys()[magic_type_to_give] , "' magic to player")
	GameState.change_magic(magic_type_to_give, magic_amount_for_single_type)
	
func _on_give_item_pressed(item_type_int: int) -> void:
	var item_type_to_give: Item.ItemType = item_type_int as Item.ItemType
	print("[DebugModeUI]: Giving item '", Item.ItemType.keys()[item_type_to_give] , "' to player")
	if is_instance_valid(GameState.player.held_item):
		GameState.player.drop_current_item()
	
	ItemProvider.give_item_to_player(item_type_to_give, GameState.player)
	
func _on_teleport_pressed(teleport_target_int: int) -> void:
	var teleport_room_type: GameState.RoomType = teleport_target_int as GameState.RoomType
	print("[DebugModeUI]: Teleporting player to ", GameState.RoomType.keys()[teleport_room_type])
	GameState.set_player_position_to_room_pos(teleport_room_type)
	
func _on_open_door_pressed(room_type_to_open_int: int) -> void:
	var open_room_type: GameState.RoomType = room_type_to_open_int as GameState.RoomType
	print("[DebugModeUI]: Opening door to ", GameState.RoomType.keys()[open_room_type])
	GameState.open_door_requested.emit(open_room_type)
		
func _on_open_all_doors_pressed() -> void:
	print("[DebugModeUI]: Opening all doors")
	for open_room_type: GameState.RoomType in GameState.RoomType.values():
		if open_room_type == GameState.RoomType.NONE:
			continue
		GameState.open_door_requested.emit(open_room_type)

func _on_restart_game_pressed() -> void:
	print("[DebugModeUI]: Restarting game (not touching a savegame)")
	GameState.load_game_at_start = false
	get_tree().reload_current_scene()

func _on_save_game_pressed() -> void:
	print("[DebugModeUI]: Saving the game")
	SaveGame.save_to_file()

func _on_load_game_pressed() -> void:
	print("[DebugModeUI]: Loading the game")
	SaveGame.load_from_file()
