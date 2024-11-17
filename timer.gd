extends Timer

var statuses = ["100", "75", "50", "25"]
var current_status = statuses[0]

signal status_changed

func reset() -> void:
	current_status = statuses[0]
	start()

# Called every frame. 'delta' is the elapsed time since the previous frame.
@onready var decay_rate: int = floori(wait_time / len(statuses))
func _process(_delta: float) -> void:
	var status_index = floori((wait_time - time_left) / decay_rate)
	if status_index >= len(statuses):
		return
	var new_status = statuses[status_index]
	if current_status != new_status:
		current_status = new_status
		status_changed.emit()
