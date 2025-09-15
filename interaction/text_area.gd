extends Area3D

var was_here: bool = false
@export var room_type: GameState.RoomType

func _on_body_entered(body: Node3D) -> void:
	if was_here == false:
		GameState.ui.show_text(room_dialogue(room_type)+ room_type_to_string(room_type))
		print("test")
		was_here = true
	
	pass # Replace with function body.
static func room_type_to_string(room_type: GameState.RoomType) -> String:
	match room_type:
		GameState.RoomType.BEDROOM: return "Bedroom"
		GameState.RoomType.NONE: return "None"
	return "unknown room type"

static func room_dialogue(room_type: GameState.RoomType) -> String:
	match room_type:
		GameState.RoomType.BEDROOM: return "This is the "
		GameState.RoomType.NONE: return "None"
	return ""
