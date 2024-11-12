extends Node2D

func _on_hud_restart() -> void:
	# reset the end screen
	$EndScreen.reset()
	
	# put the player back to its initial position
	$Player.reset($PlayerInitialPosition.position) 
	
	# reset and restart the timer
	$Timer.reset()


func _on_end_screen_endgame() -> void:
	$Player.hide()
