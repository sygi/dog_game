extends Node2D

const BREEDS: Array = ["black", "white", "brown", "yellow"]
@export var breed: String = BREEDS[randi() % BREEDS.size()]
var running: bool = false
var barking_sounds = [
	preload("res://assets/dog_sounds/Dog/Dog Bark 0.wav"),
	preload("res://assets/dog_sounds/Dog/Dog Bark 1.wav"),
	preload("res://assets/dog_sounds/Dog/Dog Bark 2.wav"),
	preload("res://assets/dog_sounds/Dog/Dog Bark 3.wav")
]

func _ready() -> void:
	if running:
		# TODO: running animations
		$AnimatedSprite2D.play("idle_" + breed)
	else:
		$AnimatedSprite2D.play("idle_" + breed)
		for point in $Path2D.curve.get_baked_points():
			$Line2D.add_point(point + $Path2D.position) 

func sprite_size() -> Vector2:
	var sprite_frames = $AnimatedSprite2D.sprite_frames
	var texture       = sprite_frames.get_frame_texture("idle_black", 0)
	var texture_size  = texture.get_size()
	var as2d_size     = texture_size * $AnimatedSprite2D.get_scale()
	return as2d_size

func start_running():
	running = true
	var dog_offset = Vector2(sprite_size().x / 2, sprite_size().y / 2)
	$Pole.visible = false
	$Line2D.position = Vector2.ZERO
	$Line2D.clear_points()
	$Line2D.add_point(dog_offset)
	$Line2D.add_point(dog_offset)
	$Line2D.visible = true
	remove_from_group("dogs")

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

func _process(delta: float) -> void:
	if running:
		var player_offset = Vector2(40, 40)
		$Line2D.points[-1] = -position + player_offset
