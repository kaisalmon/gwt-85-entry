extends Node
# Autoload

const SAVE_PATH: String = "user://savegame.save"

var is_savegame_available: bool = false

func _ready() -> void:
	is_savegame_available = FileAccess.file_exists(SAVE_PATH)
	if !is_savegame_available:
		clear_savegame()

func clear_savegame() -> void:
	GameState.current_magic_amounts = []
	for type: Recipe.MagicType in Recipe.MagicType.values():
		GameState.current_magic_amounts.append(0)
				
func save_to_file() -> void:
	if !is_instance_valid(GameState.player):
		push_warning("Cannot save game when GameState.player is not a valid instance (are you outside the level scene?) ")
		return
	
	var savegame_file_access: FileAccess = FileAccess.open(SAVE_PATH, FileAccess.WRITE)
	var save_dict: Dictionary = {
		"player_room_pos": GameState.player.current_room,
		"magic_amounts": var_to_str(GameState.current_magic_amounts),
		"opened_doors": var_to_str(GameState.opened_doors),
		"held_item": -1 if !is_instance_valid(GameState.player.held_item) else GameState.player.held_item.item_type
	}
	
	var json_string: String = JSON.stringify(save_dict)
	savegame_file_access.store_line(json_string)
	is_savegame_available = true
	print("saved to " + savegame_file_access.get_path_absolute())

func load_from_file() -> void:
	if not FileAccess.file_exists(SAVE_PATH):
		return
	is_savegame_available = true
	
	if !is_instance_valid(GameState.player):
		push_warning("Cannot load game when GameState.player is not a valid instance (are you outside the level scene?) ")
		return
		
	var save_game: FileAccess = FileAccess.open(SAVE_PATH, FileAccess.READ)
	while save_game.get_position() < save_game.get_length():
		var json_string: String = save_game.get_line()
		var json: JSON = JSON.new()
		var parseResult: Error = json.parse(json_string)
		if not parseResult == OK:
			push_warning("Preferences: JSON Parse Error: '" + json.get_error_message() + "'  at line " + str(json.get_error_line()))
			continue
		var save_dict: Dictionary = json.get_data()

		if save_dict.has("magic_amounts"):
			GameState.current_magic_amounts = str_to_var(save_dict["magic_amounts"]) as Array[int]
		if save_dict.has("player_room_pos"):
			GameState.player.current_room = save_dict["player_room_pos"] as GameState.RoomType
		if save_dict.has("opened_doors"):
			GameState.opened_doors = str_to_var(save_dict["opened_doors"]) as Array[GameState.RoomType]
		if save_dict.has("held_item"):
			var held_item_int: int = save_dict["held_item"]
			if held_item_int > -1:
				ItemProvider.give_item_to_player(held_item_int as Item.ItemType, GameState.player)
		
	GameState.apply_loaded_state()
