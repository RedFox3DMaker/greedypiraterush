extends Control

signal endgame(gameover: bool)

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
	endgame.emit(true)


func _on_player_has_won() -> void:
	visible = true
	anim_player.play("victory")
	endgame.emit(false)
