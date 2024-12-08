extends Area2D
class_name Bullet


# members
var speed: int = 250


# nodes
@onready var animation_player: AnimationPlayer = $AnimationPlayer


# Called every frame. 'delta' is the elapsed time since the previous frame.
func _physics_process(delta: float) -> void:
	position += transform.x * speed * delta


func _on_body_entered(_body: Node2D) -> void:
	queue_free()


func _on_timer_timeout() -> void:
	speed = 0
	AudioManager.play("splash")
	animation_player.play("splash")
	await animation_player.animation_finished
	queue_free()
	
