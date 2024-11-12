extends Control

signal endgame

@onready var anim_player = $AnimationPlayer
func reset() -> void:
	anim_player.stop()
	visible = false

func _on_timer_timeout() -> void:
	_game_over()


func _on_player_is_dead() -> void:
	_game_over()


func _game_over() -> void:
	visible = true
	anim_player.play("game_over")
	#$GameOverLabel.visible = true
	endgame.emit()
