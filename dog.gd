extends Node2D

const BREEDS: Array = ["black", "white", "brown", "yellow"]
@export var breed: String = BREEDS[randi() % BREEDS.size()]
var is_active: bool = false

func _ready() -> void:
	$AnimatedSprite2D.play("idle_" + breed)


func activate() -> void:
	"""I'm close to the player"""
	print("activating")
	# TODO: how do you add some picture to show one gets activated?
	draw_circle(Vector2.ZERO, 100, Color.WHITE)
	is_active = true

func deactivate() -> void:
	"""I'm far from the player"""
	print("deactivating")
	is_active = false

# Called every frame. 'delta' is the elapsed time since the previous frame.
func _process(delta: float) -> void:
	pass
