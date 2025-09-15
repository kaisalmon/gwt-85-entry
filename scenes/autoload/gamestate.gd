extends Node
# Autoload

enum RoomType {
	NONE, # Used to disable room-specific behavior
	BEDROOM,
}

var ui: UI

var outside: Node3D

var player: Player

var music_player: MusicPlayer

var current_magic_amounts: Array[int] = []


# returns the amount that was removed	
func remove_magic(magic_type: Recipe.MagicType, remove_amount: int) -> int:
	var current_amount: int = current_magic_amounts[magic_type]
	var amount_to_remove: int = min(current_amount, remove_amount)
	set_magic(magic_type, current_amount - amount_to_remove)
	return amount_to_remove

func change_magic(magic_type: Recipe.MagicType, change_amount: int) -> void:
	set_magic(magic_type, current_magic_amounts[magic_type] + change_amount)

func set_magic(magic_type: Recipe.MagicType, new_amount: int) -> void:
	current_magic_amounts[magic_type] = max(new_amount, 0)
	ui.set_magic_amount(magic_type, current_magic_amounts[magic_type] )
