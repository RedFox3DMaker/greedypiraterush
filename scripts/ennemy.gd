extends Area2D
class_name Ennemy


# members
const TILE_SIZE: int = 64


# public member
@export var speed: int = 100


# nodes
@onready var path2d: Path2D = $Path2D
@onready var path_follow: PathFollow2D = $Path2D/PathFollow2D

func reset(initial_pos: Vector2) -> void:
	position = initial_pos.snapped(Vector2.ONE * TILE_SIZE)
	position += Vector2.ONE * TILE_SIZE/2
	
	
func set_path_2d(points: PackedVector2Array) -> void:
	path2d.curve.clear_points()
	var corrected_points: PackedVector2Array = []
	for point in points:
		point -= position
		path2d.curve.add_point(point)
		corrected_points.append(point)
	$Line2DDebug.points = corrected_points
		

func _process(delta: float) -> void:
	path_follow.progress += speed * delta
