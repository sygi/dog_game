extends Control


var game_scene = preload("res://root.tscn")

func _process(delta: float) -> void:
	if has_node("Title"):
		if Input.is_anything_pressed():
			var game = game_scene.instantiate()
			add_child(game)
			$Title.queue_free()
