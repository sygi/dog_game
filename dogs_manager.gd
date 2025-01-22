extends Node2D

@export var n_dogs: int = 3

var dog_scene = preload("res://dog.tscn")

func _ready() -> void:
	for i in range(n_dogs):
		var dog = dog_scene.instantiate()
		dog.position = Vector2(randf_range(0, get_viewport().size.x), randf_range(0, get_viewport().size.y))
		add_child(dog)


# Called every frame. 'delta' is the elapsed time since the previous frame.
func _process(delta: float) -> void:
	pass
