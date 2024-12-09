extends Path2D
class_name Ennemy


# members
var tile_size: int
var cell_size: Vector2i
var pirate_world: PirateWorld
var astar_grid = AStarGrid2D.new()
var target_treasure: Treasure
var reward: int

# public member
@export var speed: int = 100
@export var treasure_scene: PackedScene


# nodes
@onready var path_follow: PathFollow2D = $PathFollow2D
@onready var sprite: Sprite2D = $PathFollow2D/Area2D/Sprite2D
@onready var area2D: Area2D = $PathFollow2D/Area2D

# signal 
signal dead(reward: int, init_global_position: Vector2)


func set_pirate_world(world: PirateWorld) -> void:
	pirate_world = world
	tile_size = pirate_world.TILE_SIZE
	cell_size = Vector2i.ONE * tile_size
	initialize_astar()


func reset(initial_glob_pos: Vector2) -> void:
	global_position = initial_glob_pos
	path_follow.progress_ratio = 0
	
	
func initialize_astar():
	astar_grid.clear()
	astar_grid.region = Rect2i(0, 0, pirate_world.NB_HORIZONTAL_TILES, pirate_world.NB_VERTICAL_TILES)
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
	if astar_grid.region.has_point(end):
		
		for point in astar_grid.get_point_path(self_map_position, end):
			curve.add_point(pirate_world.to_global(point) - global_position)
		

func choose_target() -> Vector2i:
	# get the list of treasures
	var treasures: Array[Node] = get_tree().get_nodes_in_group("treasures")
	# search the closest treasure
	var min_distance = INF
	var target_pos: Vector2i = Vector2i.ZERO
	for treasure in treasures:
		var distance = global_position.distance_to(treasure.global_position)
		if distance < min_distance:
			min_distance = distance 
			target_pos = pirate_world.convert_position(treasure.global_position) - Vector2i.ONE
			target_treasure = treasure
	
	return target_pos
	
func _process(delta: float) -> void:
	# stop if no more treasures
	var treasures = get_tree().get_nodes_in_group("treasures")
	if treasures.size() == 0:
		return 
	
	# check target validity
	var treasure_valid = is_instance_valid(target_treasure) and target_treasure in treasures
	
	if path_follow.progress_ratio == 0:
		var target = choose_target()
		compute_astar_path(target)
	elif not treasure_valid or path_follow.progress_ratio == 1:
		reset(global_position + curve.get_point_position(curve.point_count - 1))
		return
		
	# check if the treasure is still valid and the ship is moving towards it
	if target_treasure in treasures and path_follow.progress_ratio < 1:
		path_follow.progress += speed * delta
		
		
func _on_area_2d_area_entered(area: Area2D) -> void:
	if area.is_in_group("bullet"):
		if sprite.frame < sprite.hframes -1:
			sprite.frame += 1
		else:
			print("reward: ", reward)
			if reward > 0:
				dead.emit(reward, global_position + path_follow.position)
			
			# delete the ennemy
			area2D.remove_from_group("ennemy")
			queue_free()
			

func on_treasure_gained(treasure_reward: int) -> void:
	reward += treasure_reward
