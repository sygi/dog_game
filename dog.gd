extends Node2D

const BREEDS: Array = ["black", "white", "brown", "yellow"]
@export var breed: String = BREEDS[randi() % BREEDS.size()]
var is_active: bool = false

func _ready() -> void:
	$AnimatedSprite2D.play("idle_" + breed)


func activate() -> void:
	"""I'm close to the player"""
	$marker.visible = true
	is_active = true

func deactivate() -> void:
	"""I'm far from the player"""
	$marker.visible = false
	is_active = false

# Called every frame. 'delta' is the elapsed time since the previous frame.
func _process(delta: float) -> void:
	pass
