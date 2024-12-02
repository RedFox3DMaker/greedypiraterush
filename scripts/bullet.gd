extends Area2D


var speed: int = 250


# Called every frame. 'delta' is the elapsed time since the previous frame.
func _physics_process(delta: float) -> void:
	position += transform.x * speed * delta


func _on_body_entered(body: Node2D) -> void:
	if body.is_in_group("mobs"):
		body.queue_free()
	queue_free()


func _on_timer_timeout() -> void:
	speed = 0
	AudioManager.play("splash")
	$AnimationPlayer.play("splash")
	await $AnimationPlayer.animation_finished
	queue_free()
	
