extends Node
# Autoload

const AUTO_SAVE: bool = false
const MAX_MAGIC: int = 999

enum RoomType {
	NONE, # Used to disable room-specific behavior
	MAIN_ROOM,
	BEDROOM,
	KITCHEN,
	GREEN_HOUSE,
	CORRIDOR,
	OFFICE,
	BROOM_ROOM,
	LIBRARY
}

signal open_door_requested(room_type: RoomType)

var ui: UI

var outside: Node3D

var player: Player

var music_player: MusicPlayer

var current_magic_amounts: Array[int] = [0, 0, 0, 0]

var opened_doors: Array[RoomType] = []

var room_center_positions: Dictionary[RoomType, Vector3] = {}

var load_game_at_start: bool = false

# returns the amount that was removed	
func remove_magic(magic_type: Recipe.MagicType, remove_amount: int) -> int:
	var current_amount: int = current_magic_amounts[magic_type]
	var amount_to_remove: int = min(current_amount, remove_amount)
	set_magic(magic_type, current_amount - amount_to_remove)
	return amount_to_remove

func change_magic(magic_type: Recipe.MagicType, change_amount: int) -> void:
	set_magic(magic_type, current_magic_amounts[magic_type] + change_amount)

func set_magic(magic_type: Recipe.MagicType, new_amount: int) -> void:
	current_magic_amounts[magic_type] = clamp(new_amount, 0, MAX_MAGIC)
	ui.set_magic_amount(magic_type, current_magic_amounts[magic_type] )

	if AUTO_SAVE:
		SaveGame.save_to_file()

func set_door_opened(unlocked_room_type: RoomType) -> void:
	if opened_doors.has(unlocked_room_type):
		#print("room '", RoomType.keys()[unlocked_room_type], "' already unlocked")
		return
		
	opened_doors.append(unlocked_room_type)
	
	if AUTO_SAVE:
		SaveGame.save_to_file()

func apply_loaded_state() -> void:
	for open_room_type: RoomType in opened_doors:
		if open_room_type == GameState.RoomType.NONE:
			continue
		open_door_requested.emit(open_room_type)
	
	set_player_position_to_room_pos(player.current_room)
	
	for magic_type: Recipe.MagicType in Recipe.MagicType.values():
		ui.set_magic_amount(magic_type, current_magic_amounts[magic_type] )

func set_player_position_to_room_pos(room_type: RoomType) -> void:
	if !room_center_positions.has(room_type):
		
		return
	
	player.global_position = room_center_positions[room_type]
	player.current_room = room_type
