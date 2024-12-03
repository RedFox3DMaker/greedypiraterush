extends Node2D

@onready var player: Player = $Player
@onready var level1: PirateWorld = $Level1
@onready var timer: Timer = $Timer
@onready var hud: HUD = $HUD
@onready var end_screen: EndScreen = $EndScreen


func init() -> void:
	# create the treasures and connect their signals
	level1.init_rewards()
	for treasure: Treasure in get_tree().get_nodes_in_group("treasures"):
		treasure.gained.connect(_on_reward_gained)
	AudioManager.play("ambiant")


func _ready() -> void:
	init()


func _on_end_screen_restart() -> void:
	# reset the end screen
	end_screen.reset()
	
	# reset the score
	hud.reset_score()
	
	# put the player back to its initial position
	player.reset(level1.get_player_initial_position()) 
	
	# remove remaining reward and create new ones
	for treasure: Treasure in get_tree().get_nodes_in_group("treasures"):
		treasure.queue_free()
	AudioManager.stop_all()
	init()
	
	# reset and restart the timer
	timer.reset()


func _on_end_screen_endgame(gameover: bool) -> void:
	AudioManager.stop("ambiant")
	if gameover:
		player.hide()
		AudioManager.play("fail")
	else:
		AudioManager.play("win")
		
	timer.stop()
	player.stop()


func _on_reward_gained(reward: int) -> void:
	# during the play time, if the reward is granted, 
	# update the score
	if !timer.is_stopped() or !timer.is_paused():
		hud.add_to_score(reward)
