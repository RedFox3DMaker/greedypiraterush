extends Node


var bus = "master"

var available = [] # the available players
var queue = [] # the queue of sounds to play

var players = {}

var streams = {
	"countdown": load("res://assets/musics/arcade-countdown-7007.mp3"),
	"sailing": load("res://assets/musics/pope-sailing-wake-26126_short.mp3"),
	"ambiant": load("res://assets/musics/pirate-adventures-112150.mp3"),
	"coins": load("res://assets/musics/bag-of-coins-100423_short.mp3"),
	"win": load("res://assets/musics/level-win-6416.mp3"),
	"fail": load("res://assets/musics/level-failed-80951.mp3"),
	"explosion": load("res://assets/musics/explosion-91872.mp3"),
	"splash": load("res://assets/musics/water-splash-46402.mp3"),
}

func _ready() -> void:
	# create the pool of AudioStreamPlayers
	for stream_name in streams:
		var player = AudioStreamPlayer.new()
		player.stream = streams[stream_name]
		player.bus = bus
		player.finished.connect(_on_stream_finished.bind(stream_name))
		
		players[stream_name] = player
		available.append(stream_name)
		add_child(player)
		

func _on_stream_finished(stream_name: String):
	# when finised playing a stream, make the player available again
	available.append(stream_name)


func play(sound_name: String):
	assert(sound_name in streams)
	queue.append(sound_name)
	

func stop(sound_name: String):
	assert(sound_name in streams)
	players[sound_name].stop()
	available.append(sound_name)
	
	
func stop_all():
	available.clear()
	for sound_name in players:
		players[sound_name].stop()
		available.append(sound_name)

func _process(_delta: float) -> void:
	# play a queued sound if any players are available
	var stream_to_play = queue.pop_front()
	if stream_to_play in available:
		players[stream_to_play].play()
		available.erase(stream_to_play)
