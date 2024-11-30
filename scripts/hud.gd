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


func _on_layout_pref_item_selected(index: int) -> void:
	var z_key = $Controls/ControlsList/ZKey
	var q_key = $Controls/ControlsList/QKey
	if index == 0:
		z_key.texture = load("res://assets/ux/keyboard_z.png")
		q_key.texture = load("res://assets/ux/keyboard_q.png")
	elif index == 1:
		z_key.texture = load("res://assets/ux/keyboard_w.png")
		q_key.texture = load("res://assets/ux/keyboard_a.png")
