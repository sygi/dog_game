extends Node2D

const BREEDS: Array = ["black", "white", "brown", "yellow"]
@export var breed: String = BREEDS[randi() % BREEDS.size()]

func _ready() -> void:
	$AnimatedSprite2D.play("idle_" + breed)


# Called every frame. 'delta' is the elapsed time since the previous frame.
func _process(delta: float) -> void:
	pass
