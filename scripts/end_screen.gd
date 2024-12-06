extends Control
class_name EndScreen


# nodes
@onready var restart_button: Button = $RestartButton
@onready var anim_player: AnimationPlayer = $AnimationPlayer


# signals
signal endgame(gameover: bool)
signal restart


func reset() -> void:
	anim_player.stop()
	visible = false
	restart_button.hide()

func _on_timer_timeout() -> void:
	_game_over()


func _on_player_is_dead() -> void:
	_game_over()


func _game_over() -> void:
	visible = true
	anim_player.play("game_over")
	await anim_player.animation_finished
	endgame.emit(true)
	restart_button.show()


func _on_player_has_won() -> void:
	visible = true
	anim_player.play("victory")
	await anim_player.animation_finished
	endgame.emit(false)
	restart_button.show()
	

func _on_restart_button_pressed() -> void:
	restart.emit()
