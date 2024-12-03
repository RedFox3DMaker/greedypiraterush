extends Area2D
class_name PirateWorld

const TILE_SIZE = 64
const NB_HORIZONTAL_TILES = 10
const NB_VERTICAL_TILES = 10

@export var treasure_scene: PackedScene
@export var nb_treasures: int = 15

@onready var sea_layer: TileMapLayer = $SeaLayer
@onready var sand_layer: TileMapLayer = $SandLayer
@onready var player_initial_position: Marker2D = $PlayerInitialPosition

# keep a list of cells occupied by sand, rocks, enemies and player
var forbidden_cells: Array[Vector2i]
var treasures: Array = []

func get_player_initial_position():
	return player_initial_position.position
	

func init_rewards() -> void:
	forbidden_cells = sand_layer.get_used_cells()
	var player_x = player_initial_position.position.x
	var player_y = player_initial_position.position.y
	forbidden_cells.append(Vector2i(player_x, player_y))
	
	var idx = 0
	while idx < nb_treasures:		
		# compute the treasure position
		var tile_coords = Vector2i(randi() % NB_HORIZONTAL_TILES, randi() % NB_VERTICAL_TILES)
		
		# check the tile is not occupied by rocks or player
		while tile_coords in forbidden_cells:
			tile_coords.x += 1
			# overflow correction
			if tile_coords.x >= NB_HORIZONTAL_TILES:
				tile_coords.x = 0
		
		# add the coords to the forbidden cells to avoid superimposition
		forbidden_cells.append(tile_coords)
		
		# instantiate the scene at the computed coordinates
		var treasure = treasure_scene.instantiate()
		treasure.position = Vector2(tile_coords.x * TILE_SIZE / 2, tile_coords.y * TILE_SIZE / 2)
		add_child(treasure)
		treasures.append(treasure)
		
		idx += 1
