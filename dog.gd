extends Node2D

const BREEDS: Array = ["black", "white", "brown", "yellow"]
@export var breed: String = BREEDS[randi() % BREEDS.size()]
@export var leash_color: Color = Color(0., 0.38, 0., 0.9)
var running: bool = false
var barking_sounds = [
	preload("res://assets/dog_sounds/Dog/Dog Bark 0.wav"),
	preload("res://assets/dog_sounds/Dog/Dog Bark 1.wav"),
	preload("res://assets/dog_sounds/Dog/Dog Bark 2.wav"),
	preload("res://assets/dog_sounds/Dog/Dog Bark 3.wav")
]

func _ready() -> void:
	$AnimatedSprite2D.play("idle_" + breed)

func sprite_size() -> Vector2:
	var sprite_frames = $AnimatedSprite2D.sprite_frames
	var texture       = sprite_frames.get_frame_texture("idle_black", 0)
	var texture_size  = texture.get_size()
	var as2d_size     = texture_size * $AnimatedSprite2D.get_scale()
	return as2d_size

func start_running():
	running = true
	remove_from_group("dogs")

func _draw():
	if not running:
		return
	var player_offset = Vector2(80, 80)
	var dog_offset = Vector2(sprite_size().x / 2, sprite_size().y / 2)
	draw_line(dog_offset, -position + player_offset, leash_color, 10)

func barking_delay():
	return randf_range(0.7, 3.)

func bark():
	if is_inside_tree() and !$AudioStreamPlayer.is_playing():
		$AudioStreamPlayer.stream = barking_sounds[randi() % 4]
		$AudioStreamPlayer.play()
	$Timer.wait_time = barking_delay()
	$Timer.start()

func activate() -> void:
	queue_free()

func _on_timer_timeout() -> void:
	bark()

# Called every frame. 'delta' is the elapsed time since the previous frame.
func _process(delta: float) -> void:
	if running:
		queue_redraw()
	pass
