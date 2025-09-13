extends Node
# Autoload

enum RoomType {
    NONE, # Used to disable room-specific behavior
	BEDROOM,
}

var ui: UI

var outside: Node3D