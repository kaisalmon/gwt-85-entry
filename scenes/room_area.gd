class_name RoomArea
extends Area3D

@export var room_type: GameState.RoomType
@export var player_center_position: Marker3D

func _ready() -> void:
	if player_center_position != null:
		GameState.room_center_positions[room_type]

func _on_body_entered(body: Node3D) -> void:
	if !body is Player:
		return
		
	var player: Player = body as Player
	player.current_room = room_type
