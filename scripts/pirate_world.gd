extends Area2D
class_name PirateWorld


# members
const TILE_SIZE = 64
const NB_HORIZONTAL_TILES = 10
const NB_VERTICAL_TILES = 10


# public members
@export var treasure_scene: PackedScene
@export var nb_treasures: int = 15
@export var debug: bool = false

# nodes
@onready var sea_layer: TileMapLayer = $SeaLayer
@onready var sand_layer: TileMapLayer = $SandLayer
@onready var player_initial_position: Marker2D = $PlayerInitialPosition
@onready var ennemy_initial_position: Marker2D = $EnnemyInitialPosition


func get_player_initial_position():
	return sea_layer.to_global(player_initial_position.position)
	
	
func get_ennemy_initial_position():
	return sea_layer.to_global(ennemy_initial_position.position)
	

func init_rewards() -> Array[Node]:
	var treasures: Array[Node] = []
	# used_cells represent the lower right corner
	var used_cells: Array[Vector2i] = sand_layer.get_used_cells()
	
	for idx in range(nb_treasures):
		# compute the treasure position
		var tile_num: int = randi() % (NB_HORIZONTAL_TILES * NB_VERTICAL_TILES) + 1
		var tile_y: int = roundi(tile_num / NB_VERTICAL_TILES)
		var tile_x: int = tile_num - tile_y * NB_VERTICAL_TILES
		var tile_map_coords = Vector2i(tile_x, tile_y)
		
		# check the tile is not occupied by rocks or player
		while tile_map_coords in used_cells:
			# compute the lower right corners of cells
			tile_x = wrapi(tile_x + 1, 1, NB_HORIZONTAL_TILES + 1)
			tile_map_coords = Vector2i(tile_x, tile_y)
		
		# add the coords to the forbidden cells to avoid superimposition
		used_cells.append(tile_map_coords)
		
		# instantiate the scene at the computed coordinates
		var treasure = treasure_scene.instantiate()
		treasure.compute_reward()
		# get the world coordinates
		var correction = Vector2i.ONE if tile_map_coords.x > 1 else Vector2i.ZERO
		treasure.position = sand_layer.map_to_local(tile_map_coords - correction)
		wrap(treasure.position.x, position.x + TILE_SIZE / 2,  position.x + (NB_HORIZONTAL_TILES - 0.5) * TILE_SIZE) 
		add_child(treasure)
		treasures.append(treasure)
		
	return treasures


func clean_treasures() -> void:
	for treasure: Treasure in get_tree().get_nodes_in_group("treasures"):
		treasure.remove_from_group("treasures")
		remove_child(treasure)
		treasure.queue_free()	
	
	
func convert_position(glob_position: Vector2) -> Vector2i:
	var local_position = sea_layer.to_local(glob_position)
	var map_position = sea_layer.local_to_map(local_position)
	return map_position
	

# DEBUG
func _draw():
	if not debug: return
	for x in NB_HORIZONTAL_TILES + 1:
		draw_line(Vector2(x * TILE_SIZE, 0),
		Vector2(x * TILE_SIZE, NB_VERTICAL_TILES * TILE_SIZE),
		Color.DARK_GRAY, 2.0)
	for y in NB_VERTICAL_TILES + 1:
		draw_line(Vector2(0, y * TILE_SIZE),
		Vector2(NB_HORIZONTAL_TILES * TILE_SIZE, y * TILE_SIZE),
		Color.DARK_GRAY, 2.0)
		
func _ready():
	if not debug: return
	var used_cells = sand_layer.get_used_cells()
	for cell in used_cells:
		var cell_local = sand_layer.map_to_local(cell - Vector2i.ONE)
		var cell_local_1 = sand_layer.map_to_local(cell)
		print("cell map coords: ", cell - Vector2i.ONE)
		print("cell local coords: ", cell_local)
		print("cell world coords: ", sand_layer.to_global(cell_local))
		print("cell world coords (1): ", sand_layer.to_global(cell_local_1))
