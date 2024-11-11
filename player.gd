extends Area2D

var tile_size = 64
var inputs = {
	"right": Vector2.RIGHT, 
	"left": Vector2.LEFT, 
	"up": Vector2.UP, 
	"down": Vector2.DOWN
	}	
var statuses = ["100", "75", "50", "25"]
var status_index = 0
var moving = false

signal is_dead

@export var animation_speed: int = 3


# Called when the node enters the scene tree for the first time.
func _ready() -> void:
	position = position.snapped(Vector2.ONE * tile_size)
	position += Vector2.ONE * tile_size/2


@onready var anim_player = $AnimationPlayer
func change_animation(dir: String) -> void:
	if status_index < len(statuses):
		anim_player.play(dir + statuses[status_index])
	else:
		is_dead.emit()


@onready var ray = $RayCast2D
func move(dir: String) -> void:
	ray.target_position = inputs[dir] * tile_size
	ray.force_raycast_update()
	if !ray.is_colliding():
		var tween = create_tween()
		tween.tween_property(self, "position", 
			position + inputs[dir] * tile_size, 
			1.0/animation_speed).set_trans(Tween.TRANS_SINE)
		moving = true
		await tween.finished
		moving = false


# Called every frame. 'delta' is the elapsed time since the previous frame.
func _physics_process(delta: float) -> void:
	if moving:
		return
	for dir in inputs.keys():
		if Input.is_action_pressed(dir):
			change_animation(dir)
			move(dir)


func _on_timer_status_changed() -> void:
	status_index += 1 # Replace with function body.
