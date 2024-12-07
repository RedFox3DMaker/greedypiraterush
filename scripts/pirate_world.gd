extends Area2D
class_name PirateWorld


# members
const TILE_SIZE = 64
const NB_HORIZONTAL_TILES = 10
const NB_VERTICAL_TILES = 10
const FORBIDDEN_CELLS: Array[Vector2i] = [
	Vector2i(3,2),
	Vector2i(9,3),
	Vector2i(5,4),
	Vector2i(6,7),
	Vector2i(3,8),
	Vector2i(10,7),
	Vector2i(8,8),
	Vector2i(9,8),
	Vector2i(10,8),
	Vector2i(8,9),
	Vector2i(9,9),
	Vector2i(10,9),
	Vector2i(7,10),
	Vector2i(8,10),
	Vector2i(9,10),
	Vector2i(10,10),
	Vector2i(3,5),
	]


# public members
@export var treasure_scene: PackedScene
@export var nb_treasures: int = 15


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
	var used_cells: Array[Vector2i] = FORBIDDEN_CELLS.duplicate()
	
	for idx in range(nb_treasures):
		# compute the treasure position
		var tile_num: int = randi() % (NB_HORIZONTAL_TILES * NB_VERTICAL_TILES) + 1
		var tile_y: int = roundi(tile_num / NB_VERTICAL_TILES)
		var tile_x: int = tile_num - tile_y * NB_VERTICAL_TILES
		var tile_map_coords = Vector2i(tile_x, tile_y)
		
		# check the tile is not occupied by rocks or player
		while used_cells.has(tile_map_coords):
			tile_x = wrapi(tile_x + 1, 1, NB_HORIZONTAL_TILES +1)
			tile_map_coords = Vector2i(tile_x, tile_y)
		
		# add the coords to the forbidden cells to avoid superimposition
		used_cells.append(tile_map_coords)
		
		# instantiate the scene at the computed coordinates
		var treasure = treasure_scene.instantiate()
		treasure.position = Vector2(tile_map_coords) * TILE_SIZE - Vector2.ONE * TILE_SIZE / 2
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
	return sea_layer.local_to_map(local_position)
	
	
func on_ennemy_dead(reward: int, init_glob_position: Vector2) -> void:
	# instantiate the treasure scene at the current coordinates
	var treasure_inst = treasure_scene.instantiate()
	treasure_inst.position = sand_layer.to_local(init_glob_position)
	call_deferred("add_child", treasure_inst)
	treasure_inst.reward = reward
