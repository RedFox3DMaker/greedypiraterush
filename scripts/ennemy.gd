extends Path2D
class_name Ennemy


# members
const TILE_SIZE: int = 64


# public member
@export var speed: int = 100


# nodes
@onready var path_follow: PathFollow2D = $PathFollow2D

func reset(initial_glob_pos: Vector2) -> void:
	global_position = initial_glob_pos.snapped(Vector2.ONE * TILE_SIZE)
	
	
func set_path_2d(points: PackedVector2Array) -> void:
	curve.clear_points()
	var corrected_points: PackedVector2Array = []
	for point in points:
		point -= position
		curve.add_point(point)
		corrected_points.append(point)
		

func _process(delta: float) -> void:
	path_follow.progress += speed * delta
