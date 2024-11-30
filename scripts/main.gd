extends Node2D

var rewards = []
func init_rewards() -> void:
	rewards.clear()
	var idx = 0
	while idx < 15:
		rewards.append(randi() % 1499 + 1)
		idx += 1

var tiles_already_searched = []
func get_player_current_tile() -> Vector2i:
	# the player can ask for a reward once on each tile so keep track of where 
	# the requests have been made
	var tile_size = $Player.tile_size
	var player_pos = $Player.position - Vector2.ONE * tile_size / 2
	var level_origin = $Level1.position
	var player_pos_on_level = player_pos - level_origin
	return Vector2i(player_pos_on_level / tile_size)


func _ready() -> void:
	init_rewards()
	AudioManager.play("ambiant")
	
	
func _on_hud_restart() -> void:
	# reset the end screen
	$EndScreen.reset()
	
	# put the player back to its initial position
	$Player.reset($PlayerInitialPosition.position) 
	
	# refill the rewards
	init_rewards()
	AudioManager.stop_all()
	AudioManager.play("ambiant")
	
	# reset and restart the timer
	$Timer.reset()


func _on_end_screen_endgame(gameover: bool) -> void:
	AudioManager.stop("ambiant")
	if gameover:
		$Player.hide()
		AudioManager.play("fail")
	else:
		AudioManager.play("win")
		
	$Timer.stop()
	$Player.stop()


func _on_player_ask_for_reward() -> void:
	# during the play time, if the reward is granted, 
	# take it from the rewards bag
	if (!$Timer.is_stopped() or !$Timer.is_paused()) and len(rewards) > 0:
		# check the tile
		var tile_coords = get_player_current_tile()
		if tile_coords in tiles_already_searched: return
		tiles_already_searched.append(tile_coords)
					
		var grant_reward = randi() % 2 as bool
		if !grant_reward: return
		
		$HUD.add_to_score(rewards.pop_back())
		AudioManager.play("coins")
