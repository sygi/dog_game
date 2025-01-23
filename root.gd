extends Node2D

const MAX_DOGS_ON_SCREEN = 3

var dog_scene = preload("res://dog.tscn")


func fill_world_with_dogs():
	var existing_dogs = $Dogs.get_child_count()
	for i in range(MAX_DOGS_ON_SCREEN - existing_dogs):
		var dog = dog_scene.instantiate()
		var dog_size = dog.sprite_size()
		dog.position = Vector2(
			randf_range(0, get_viewport().size.x - dog_size.x),
			randf_range(0, get_viewport().size.y - dog_size.y)
		)
		$Dogs.add_child(dog)
	
func _ready() -> void:
	fill_world_with_dogs()

# Called every frame. 'delta' is the elapsed time since the previous frame.
func _process(delta: float) -> void:
	fill_world_with_dogs()
