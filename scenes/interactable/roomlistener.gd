class_name RoomListener
extends Node3D

func _ready() -> void:
	self.add_to_group("room_listener")

func on_room_unlocked(_room_type: GameState.RoomType) -> void:
	# Handle the room unlocking logic here
	pass

func on_room_unlock_start(_room_type: GameState.RoomType, _unlock_time: float) -> void:
	# Handle any pre-unlock logic here
	pass