extends Area2D
class_name Treasure


# members
var reward: int = 0
const MAX_REWARD = 1499


# signals
signal gained(reward: int)


# Called when the node enters the scene tree for the first time.
func _ready() -> void:
	# compute the reward
	reward = randi() % MAX_REWARD + 1


func _on_area_entered(body: Node2D) -> void:
	if body.is_in_group("player"):
		gained.emit(reward)
	AudioManager.play("coins")
	queue_free()
