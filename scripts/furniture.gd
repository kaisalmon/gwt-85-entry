extends RoomListener

@export var removed_by_room: GameState.RoomType = GameState.RoomType.NONE

func _ready() -> void:
    super._ready()

func on_room_unlocked(_room: GameState.RoomType) -> void:
    if _room == removed_by_room:
        queue_free()