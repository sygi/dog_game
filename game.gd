extends Control


var high_score = 0
var game_scene = preload("res://root.tscn")
var title_scene = preload("res://title.tscn")

func _on_exit_to_title(high_score):
	self.high_score = high_score
	remove_child($Root)
	var title_scene = title_scene.instantiate()
	add_child(title_scene)

func _process(delta: float) -> void:
	if has_node("Title"):
		if Input.is_anything_pressed():
			var game = game_scene.instantiate()
			game.high_score = high_score
			add_child(game)
			game.exit_to_title.connect(_on_exit_to_title)
			$Title.queue_free()
