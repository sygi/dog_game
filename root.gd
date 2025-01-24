extends Control

const MAX_DOGS_ON_SCREEN = 3

enum GameState {Starting, Active, Ended}

var state: GameState = GameState.Starting
var dog_scene = preload("res://dog.tscn")
@export var MIN_PLAYER_DIST = 100
var DEBUG = false


func _on_pre_countdown_timer_timeout():
	$PreCountdownTimer.queue_free()
	var countdown_timer = Timer.new()
	countdown_timer.name = "CountdownTimer"
	countdown_timer.wait_time = 0.1 if DEBUG else 2
	countdown_timer.one_shot = true
	add_child(countdown_timer)
	countdown_timer.timeout.connect(_on_countdown_timer_timeout)
	countdown_timer.start()

func _on_countdown_timer_timeout():
	$CountdownTimer.queue_free()
	var post_countdown_timer = Timer.new()
	post_countdown_timer.name = "PostCountdownTimer"
	post_countdown_timer.wait_time = 0.1 if DEBUG else 0.5
	post_countdown_timer.one_shot = true
	add_child(post_countdown_timer)
	post_countdown_timer.timeout.connect(on_post_countdown_timer_timeout)
	post_countdown_timer.start()
	
func on_post_countdown_timer_timeout():
	$PostCountdownTimer.queue_free()
	$Announce.text = "Start!"
	
	var start_text_timer = Timer.new()
	start_text_timer.name = "StartTextTimer"
	start_text_timer.wait_time = 0.1 if DEBUG else 0.5
	start_text_timer.one_shot = true
	add_child(start_text_timer)
	start_text_timer.timeout.connect(on_start_text_timer_timeout)
	start_text_timer.start()
	
	state = GameState.Active
	
func on_start_text_timer_timeout():
	$StartTextTimer.queue_free()
	$Announce.text = ""
	
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
	var pre_countdown_timer = Timer.new()
	pre_countdown_timer.name = "PreCountdownTimer"
	pre_countdown_timer.wait_time = 0.1 if DEBUG else 0.5
	pre_countdown_timer.one_shot = true
	add_child(pre_countdown_timer)
	pre_countdown_timer.timeout.connect(_on_pre_countdown_timer_timeout)
	pre_countdown_timer.start()

func _process(delta: float) -> void:
	match state:
		GameState.Starting:
			if has_node("CountdownTimer"):
				var count = int($CountdownTimer.time_left / $CountdownTimer.wait_time * 3 + 1)
				$Announce.text = str(count)
		GameState.Active:
			fill_world_with_dogs()
