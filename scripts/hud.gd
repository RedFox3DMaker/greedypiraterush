extends Control
class_name HUD


# members
var score = 0


# nodes
@onready var score_value: Label = $Score/HSplitContainer/ScoreValue
@onready var z_key: TextureRect = $Controls/ControlsList/ZKey
@onready var q_key: TextureRect = $Controls/ControlsList/ZKey


func add_to_score(reward: int) -> void:
	score += reward
	score_value.text = "%4d" % score
	
	
func reset_score() -> void:
	score = 0
	score_value.text = "%4d" % score


func _on_layout_pref_item_selected(index: int) -> void:
	if index == 0:
		z_key.texture = load("res://assets/ux/keyboard_z.png")
		q_key.texture = load("res://assets/ux/keyboard_q.png")
	elif index == 1:
		z_key.texture = load("res://assets/ux/keyboard_w.png")
		q_key.texture = load("res://assets/ux/keyboard_a.png")
