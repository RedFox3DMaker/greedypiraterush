extends Control
class_name HUD


# members
var score = 0
var num_bullets_fired = 0

# public members
@export var num_bullets: int = 25


# nodes
@onready var score_value: Label = $Score/HSplitContainer/ScoreValue
@onready var z_key: TextureRect = $Controls/ControlsList/ZKey
@onready var q_key: TextureRect = $Controls/ControlsList/ZKey
@onready var bullets: GridContainer = $Bullets/BulletsIcons


func add_to_score(reward: int) -> void:
	score += reward
	score_value.text = "%4d" % score
	
	
func reset_score() -> void:
	score = 0
	score_value.text = "%4d" % score


func reset_bullets() -> void:
	for bullet_texture: TextureRect in bullets.get_children():
		bullet_texture.modulate.a = 1
	num_bullets_fired = 0
		

func init_bullets() -> void:
	for i in range(num_bullets):
		var bullet_texture = TextureRect.new()
		bullet_texture.texture = load("res://assets/sprites/BulletIconHUD.png")
		bullets.add_child(bullet_texture)


func on_bullet_fired() -> void:
	if num_bullets_fired < num_bullets:
		var bullet_texture = bullets.get_child(num_bullets_fired)
		bullet_texture.modulate.a = 0.5
		num_bullets_fired += 1


func _on_layout_pref_item_selected(index: int) -> void:
	if index == 0:
		z_key.texture = load("res://assets/ux/keyboard_z.png")
		q_key.texture = load("res://assets/ux/keyboard_q.png")
	elif index == 1:
		z_key.texture = load("res://assets/ux/keyboard_w.png")
		q_key.texture = load("res://assets/ux/keyboard_a.png")
