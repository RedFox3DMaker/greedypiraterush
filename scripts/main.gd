extends Node2D


# members
var total_rewards: int
var ennemy: Ennemy

# public members
@export var ennemy_scene: PackedScene
@export var treasure_scene: PackedScene


# nodes
@onready var player: Player = $Player
@onready var level1: PirateWorld = $Level1
@onready var timer: Timer = $Timer
@onready var hud: HUD = $HUD
@onready var end_screen: EndScreen = $EndScreen


func init() -> void:	
	# set the player at the right position
	player.reset(level1.get_player_initial_position())
	
	# remove the ennemy ship is still here
	if is_instance_valid(ennemy):
		remove_child(ennemy)
		ennemy.queue_free()
	
	ennemy = ennemy_scene.instantiate()
	ennemy.set_pirate_world(level1)
	add_child(ennemy)
	ennemy.reset(level1.get_ennemy_initial_position())
	ennemy.dead.connect(_on_ennemy_dead)
	
	# create the treasures and connect their signals
	total_rewards = 0
	var treasures: Array[Node] = level1.init_rewards()
	for treasure: Treasure in treasures:
		print("reward(init): ", treasure.reward)
		total_rewards += treasure.reward
		treasure.player_gained.connect(_on_player_reward_gained)
		treasure.ennemy_gained.connect(ennemy.on_treasure_gained)
	
	print("total rewards(game_start): ", total_rewards)
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
		print("reward:", reward)
		hud.add_to_score(reward)
		


func _on_player_has_won() -> void:
	# compute the total rewards
	print("total rewards(game_end): ", total_rewards)
	print("hud score: ", hud.score)
	
	end_screen.set_victory(total_rewards == hud.score)
	end_screen._game_over(false)


func _on_ennemy_dead(reward: int, init_glob_position: Vector2) -> void:
	# instantiate the treasure scene at the current coordinates
	var treasure_inst = treasure_scene.instantiate()
	var map_position = level1.sand_layer.local_to_map(init_glob_position)
	treasure_inst.position = level1.sand_layer.map_to_local(map_position - 2*Vector2i.ONE)
	call_deferred("add_child", treasure_inst)
	treasure_inst.reward = reward
	treasure_inst.player_gained.connect(_on_player_reward_gained)
