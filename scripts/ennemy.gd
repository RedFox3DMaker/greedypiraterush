extends Path2D
class_name Ennemy


# members
var tile_size: int
var cell_size: Vector2i
var pirate_world: PirateWorld
var astar_grid = AStarGrid2D.new()

# public member
@export var speed: int = 100

# nodes
@onready var path_follow: PathFollow2D = $PathFollow2D


func set_pirate_world(world: PirateWorld) -> void:
	pirate_world = world
	tile_size = pirate_world.TILE_SIZE
	cell_size = Vector2i.ONE * tile_size
	initialize_astar()


func reset(initial_glob_pos: Vector2) -> void:
	global_position = initial_glob_pos.snapped(cell_size)
	path_follow.progress = 0
	
	
func initialize_astar():
	astar_grid.clear()
	astar_grid.region = Rect2i(0, 0, pirate_world.NB_HORIZONTAL_TILES+1, pirate_world.NB_VERTICAL_TILES+1)
	astar_grid.cell_size = cell_size
	astar_grid.offset = cell_size / 2
	astar_grid.diagonal_mode = AStarGrid2D.DIAGONAL_MODE_NEVER
	astar_grid.default_estimate_heuristic = AStarGrid2D.HEURISTIC_MANHATTAN
	astar_grid.update()
	
	# declare the used cells
	for cell in pirate_world.sand_layer.get_used_cells():
		astar_grid.set_point_solid(cell - Vector2i.ONE)
		
		
func compute_astar_path(end: Vector2i) -> void:
	# reset the path to follow
	curve.clear_points()
	
	# get the current position on the level as map coordinates
	var self_map_position: Vector2i = pirate_world.convert_position(global_position)
	
	for point in astar_grid.get_point_path(self_map_position, end):
		curve.add_point(pirate_world.to_global(point) - global_position)
	
	
var target = Vector2i(7,6)
func _process(delta: float) -> void:
	if path_follow.progress_ratio == 0:
		compute_astar_path(target)
	if path_follow.progress_ratio < 1:
		path_follow.progress += speed * delta
