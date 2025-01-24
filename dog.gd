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

func bark():
	if !$AudioStreamPlayer.is_playing():
		$AudioStreamPlayer.stream = barking_sounds[randi() % 4]
		$AudioStreamPlayer.play()

func activate() -> void:
	queue_free()

# Called every frame. 'delta' is the elapsed time since the previous frame.
func _process(delta: float) -> void:
	pass
