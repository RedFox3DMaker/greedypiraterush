extends Node2D


# public members
@export var ennemy_scene: PackedScene


# nodes
@onready var player: Player = $Player
@onready var level1: PirateWorld = $Level1
@onready var timer: Timer = $Timer
@onready var hud: HUD = $HUD
@onready var end_screen: EndScreen = $EndScreen


func init() -> void:	
	# set the player at the right position
	player.reset(level1.get_player_initial_position())
	
	# init the ennemy ship
	var ennemies = get_tree().get_nodes_in_group("ennemy")
	for ennemy in ennemies:
		ennemy.remove_from_group("ennemy")
		remove_child(ennemy)
		ennemy.queue_free()
	
	var ennemy_inst: Ennemy = ennemy_scene.instantiate()
	ennemy_inst.set_pirate_world(level1)
	add_child(ennemy_inst)
	ennemy_inst.reset(level1.get_ennemy_initial_position())
	ennemy_inst.dead.connect(level1.on_ennemy_dead)
	
	# create the treasures and connect their signals
	var treasures: Array[Node] = level1.init_rewards()
	for treasure: Treasure in treasures:
		treasure.player_gained.connect(_on_player_reward_gained)
		treasure.ennemy_gained.connect(ennemy_inst.on_treasure_gained)
	
	# start the music
	AudioManager.play("ambiant")


func _ready() -> void:
	hud.init_bullets()
	player.bullet_fired.connect(hud.on_bullet_fired)
	init()


func _on_end_screen_restart() -> void:
	# reset the end screen
	end_screen.reset()
	
	# reset the score
	hud.reset_score()
	hud.reset_bullets()
	
	# remove remaining reward and create new ones
	level1.clean_treasures()
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


func _on_player_reward_gained(reward: int) -> void:
	# during the play time, if the reward is granted, 
	# update the score
	if !timer.is_stopped() or !timer.is_paused():
		hud.add_to_score(reward)
		
