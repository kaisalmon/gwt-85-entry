class_name DoorProperties
extends Resource

@export var unlocked_room_type: GameState.RoomType

## magic -> amount
@export var required_magic: Dictionary[Recipe.MagicType, int] = {}
