extends RoomListener

@export var removed_by_room: GameState.RoomType = GameState.RoomType.NONE
@export var added_by_room: GameState.RoomType = GameState.RoomType.NONE

var disappearing: bool = false
var appearing: bool = false
var disappearing_time: float = 0.0
var appearing_time: float = 0.0
var base_scale: Vector3
var base_rotation: Vector3

func _ready() -> void:
	super._ready()
	base_scale = self.scale
	base_rotation = self.rotation
	if added_by_room != GameState.RoomType.NONE:
		self.scale = Vector3.ZERO
		self.visible = false
		disable_all_collisions(self)

func on_room_unlocked(room: GameState.RoomType) -> void:
	if room == removed_by_room:
		disappearing = true
		disappearing_time = 0.0
		base_scale = self.scale
	elif room == added_by_room:
		appearing = true
		appearing_time = 0.0
		self.visible = true

func _process(delta: float) -> void:
	if disappearing:
		disappearing_time += delta
		self.rotate_y(delta * 5.0)
		self.position.y += delta * 0.3
		self.scale = base_scale * (1.0 - (disappearing_time / 1.0))
		if disappearing_time >= 1.0:
			queue_free()
	elif appearing:
		appearing_time += delta
		self.rotation.y = base_rotation.y + (1.0 - (appearing_time / 1.0)) * PI * 2.0
		self.scale = base_scale * (appearing_time / 1.0)
		if appearing_time >= 1.0:
			appearing = false
			self.scale = base_scale 
			enable_all_collisions(self)
	
func disable_all_collisions(node: Node) -> void:
	if node is CollisionObject3D and not (node is StaticBody3D):
		print("disabling collision for ", node.name)
		(node as CollisionObject3D).disabled = true
	for child in node.get_children():
		if child is Node:
			disable_all_collisions(child as Node)

func enable_all_collisions(node: Node) -> void:
	if node is CollisionObject3D and not (node is StaticBody3D):
		print("enabling collision for ", node.name)
		(node as CollisionObject3D).disabled = false
		check_for_player_stuck((node as CollisionObject3D))
	for child in node.get_children():
		if child is Node:
			enable_all_collisions(child as Node)

func check_for_player_stuck(collision_object: CollisionObject3D) -> void:
	print("TODO")
