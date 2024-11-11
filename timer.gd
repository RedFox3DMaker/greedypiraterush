extends Timer

var statuses = ["100", "75", "50", "25"]
var current_status = statuses[0]

signal status_changed

# Called when the node enters the scene tree for the first time.
func _ready() -> void:
	pass # Replace with function body.


# Called every frame. 'delta' is the elapsed time since the previous frame.
@onready var decay_rate: int = wait_time / len(statuses)
func _process(delta: float) -> void:
	var status_index = floori(wait_time - time_left) / decay_rate
	if status_index >= len(statuses):
		return
	var new_status = statuses[status_index]
	if current_status != new_status:
		current_status = new_status
		status_changed.emit()
