extends Area2D
class_name Treasure


# members
var reward: int = 0
const MAX_REWARD = 1499
const TILE_SIZE = 64


# signals
signal player_gained(reward: int)
signal ennemy_gained(reward: int)

# Called when the node enters the scene tree for the first time.
func _ready() -> void:
	# compute the reward
	reward = randi() % MAX_REWARD + 1
	# snap to the grid
	position = position.snapped(Vector2.ONE * TILE_SIZE / 2)
	position += Vector2.ONE * TILE_SIZE/2
	# print("position: ", position)


func _on_area_entered(area: Area2D) -> void:
	if area.is_in_group("player"):
		player_gained.emit(reward)
	elif area.is_in_group("ennemy"):
		ennemy_gained.emit(reward)
	AudioManager.play("coins")
	remove_from_group("treasures")
	queue_free()
