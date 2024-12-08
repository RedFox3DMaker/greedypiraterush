extends Control
class_name EndScreen


# nodes
@onready var restart_button: Button = $RestartButton
@onready var exit_button: Button = $ExitButton
@onready var anim_player: AnimationPlayer = $AnimationPlayer


# signals
signal endgame(gameover: bool)
signal restart


func reset() -> void:
	anim_player.stop()
	visible = false
	restart_button.hide()
	exit_button.hide()

func _on_timer_timeout() -> void:
	_game_over(true)


func _on_player_is_dead() -> void:
	_game_over(true)


func _game_over(fail: bool) -> void:
	visible = true
	endgame.emit(fail)
	anim_player.play("game_over" if fail else "victory")
	await anim_player.animation_finished
	restart_button.show()
	exit_button.show()
	

func _on_restart_button_pressed() -> void:
	restart.emit()


func _on_exit_button_pressed() -> void:
	get_tree().quit()


func set_victory(true_victory: bool) -> void:
	$SuccessLabel.text = "You're safe." if not true_victory else "Victory !!"
