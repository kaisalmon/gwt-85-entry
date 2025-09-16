extends Area3D

var was_here: bool = false
@export var room_type: GameState.RoomType

func _on_body_entered(_body: Node3D) -> void:
	if was_here == false:
		
		if room_type == GameState.RoomType.NONE:
			GameState.ui.show_text("[no room]")
			push_warning("trying to show text for a 'none' room")
		else:
			GameState.ui.show_text(tr("dialogue.this_is").format([tr(Util.room_type_to_trkey(room_type))]))
		print("test")
		was_here = true
		

static func room_dialogue(rtype: GameState.RoomType) -> String:
	match rtype:
		GameState.RoomType.BEDROOM: return "This is the "
		GameState.RoomType.NONE: return "None"
	return ""
