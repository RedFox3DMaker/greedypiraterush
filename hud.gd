extends Control

signal restart

var score = 0

func add_to_score(reward: int) -> void:
	score += reward
	$Score/HSplitContainer/ScoreValue.text = "%4d" % score

func _on_restart_button_pressed() -> void:
	restart.emit()
	score = 0
	$Score/HSplitContainer/ScoreValue.text = "%4d" % score
