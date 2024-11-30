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
var current_dir = "down"
var allow_move = true

signal is_dead
signal has_won
signal ask_for_reward

@export var animation_speed: int = 3


func stop() -> void:
	allow_move = false


func reset(initial_pos: Vector2) -> void:
	position = initial_pos
	position = position.snapped(Vector2.ONE * tile_size)
	position += Vector2.ONE * tile_size/2
	status_index = 0
	current_dir = "down"
	allow_move = true
	update_animation(current_dir)
	show()


# Called when the node enters the scene tree for the first time.
func _ready() -> void:
	reset(position)


@onready var sprite = $Sprite2D
var dir_index = {"down": 0, "right": 1, "up": 2, "left": 3}
func update_animation(dir: String) -> void:
	if status_index < len(statuses):
		sprite.frame = 4*status_index + dir_index[dir]
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
			1.0/animation_speed).set_trans(Tween.TRANS_LINEAR)
		moving = true
		AudioManager.play("sailing")
		await tween.finished
		moving = false
		
		
func _unhandled_input(event: InputEvent) -> void:
	if !allow_move: return 
	if event.is_action_pressed("pick_reward"):
		ask_for_reward.emit()
		

# Called every frame. 'delta' is the elapsed time since the previous frame.
func _physics_process(_delta: float) -> void:
	if !allow_move: return
	if moving:
		return
	for dir in inputs.keys():
		if Input.is_action_pressed(dir):
			if dir != current_dir:
				update_animation(dir)
				current_dir = dir
			move(dir)


func _on_timer_status_changed() -> void:
	status_index += 1
	update_animation(current_dir)


func _on_body_entered(body: Node2D) -> void:
	var tilemap = body as TileMapLayer
	if !tilemap: return
		
	var tile_collider_rid = $RayCast2D.get_collider_rid()
	var tile_coords = tilemap.get_coords_for_body_rid(tile_collider_rid)
	var tile_data = tilemap.get_cell_tile_data(tile_coords)
	if !tile_data: return
	
	var custom_data = tile_data.get_custom_data("victory")
	if custom_data:
		has_won.emit()
