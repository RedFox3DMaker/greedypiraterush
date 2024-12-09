extends Area2D
class_name Player


# members
const TILE_SIZE = 64
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
var num_bullets_fired: int = 0


# public members
@export var animation_speed: int = 3
@export var bullet_scene: PackedScene
@export var num_bullets: int = 25


# nodes
@onready var ray = $RayCast2D
@onready var sprite = $Sprite2D
@onready var animation_player: AnimationPlayer = $Sprite2D/AnimationPlayer
@onready var bullet_spawn_location: Marker2D = $Sprite2D/BulletSpawnLocation
@onready var collision_shape: CollisionShape2D = $CollisionShape2D


# signals
signal is_dead
signal has_won
signal bullet_fired


func stop() -> void:
	allow_move = false


func reset(initial_pos: Vector2) -> void:
	position = initial_pos
	status_index = 0
	current_dir = "down"
	allow_move = true
	num_bullets_fired = 0
	update_animation(current_dir)
	show()


var dir_rotation = {"down": 0, "right": -PI/2, "up": PI, "left": PI/2}
func update_animation(dir: String) -> void:
	# update the frame to match the status
	if status_index < len(statuses):
		sprite.frame = status_index
	else:
		is_dead.emit()
		
	# update the rotation to match the direction
	assert(dir in dir_rotation)
	sprite.rotation = dir_rotation[dir]
	collision_shape.rotation = dir_rotation[dir]
	

func move(dir: String) -> void:
	ray.target_position = inputs[dir] * TILE_SIZE
	ray.force_raycast_update()
	if !ray.is_colliding():
		var tween = create_tween()
		tween.tween_property(self, "position", 
			position + inputs[dir] * TILE_SIZE, 
			1.0/animation_speed).set_trans(Tween.TRANS_LINEAR)
		moving = true
		AudioManager.play("sailing")
		await tween.finished
		moving = false
	else:
		var collider = ray.get_collider() as Node2D
		check_collision_with_sand(collider)
		
		
func _unhandled_input(event: InputEvent) -> void:
	if !allow_move: return 
	if event.is_action_pressed("shoot"):
		shoot()
		

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


func check_collision_with_sand(body: Node2D) -> void:
	var tilemap = body as TileMapLayer
	if !tilemap: return
		
	var tile_collider_rid: RID = ray.get_collider_rid()
	if !tile_collider_rid.is_valid(): return
	var tile_coords = tilemap.get_coords_for_body_rid(tile_collider_rid)
	var tile_data = tilemap.get_cell_tile_data(tile_coords)
	if !tile_data: return
	
	var custom_data = tile_data.get_custom_data("victory")
	if custom_data:
		has_won.emit()
		
		
func shoot():
	if num_bullets_fired >= num_bullets:
		return
		
	animation_player.play("fire")
	AudioManager.play("explosion")
	var bullet = bullet_scene.instantiate()
	owner.add_child(bullet)
	bullet.transform = bullet_spawn_location.global_transform
	bullet_fired.emit()
	num_bullets_fired += 1
