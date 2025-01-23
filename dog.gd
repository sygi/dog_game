extends Node2D

const BREEDS: Array = ["black", "white", "brown", "yellow"]
@export var breed: String = BREEDS[randi() % BREEDS.size()]
var is_active: bool = false

func _ready() -> void:
	$AnimatedSprite2D.play("idle_" + breed)


func sprite_size() -> Vector2:
	var sprite_frames = $AnimatedSprite2D.sprite_frames
	var texture       = sprite_frames.get_frame_texture("idle_black", 0)
	var texture_size  = texture.get_size()
	var as2d_size     = texture_size * $AnimatedSprite2D.get_scale()
	return as2d_size


func activate() -> void:
	"""I'm close to the player"""
	$marker.visible = true
	is_active = true
	queue_free()

func deactivate() -> void:
	"""I'm far from the player"""
	$marker.visible = false
	is_active = false

# Called every frame. 'delta' is the elapsed time since the previous frame.
func _process(delta: float) -> void:
	pass
