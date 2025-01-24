extends Node2D

const MAX_DOGS_ON_SCREEN = 3

var dog_scene = preload("res://dog.tscn")
@export var MIN_PLAYER_DIST = 100


func fill_world_with_dogs():
	var existing_dogs = $Dogs.get_child_count()
	for i in range(MAX_DOGS_ON_SCREEN - existing_dogs):
		var dog = dog_scene.instantiate()
		var dog_size = dog.sprite_size()
		var preliminary_pos = Vector2(
			randf_range(0, get_viewport().size.x - dog_size.x),
			randf_range(0, get_viewport().size.y - dog_size.y)
		)
		while min(preliminary_pos.distance_to($Player.position), preliminary_pos.distance_to($House.position)) < MIN_PLAYER_DIST:
			preliminary_pos = Vector2(
				randf_range(0, get_viewport().size.x - dog_size.x),
				randf_range(0, get_viewport().size.y - dog_size.y)
			)
		dog.position = preliminary_pos
		$Dogs.add_child(dog)

func _ready() -> void:
	fill_world_with_dogs()

# Called every frame. 'delta' is the elapsed time since the previous frame.
func _process(delta: float) -> void:
	fill_world_with_dogs()
