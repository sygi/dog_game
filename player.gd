extends Node2D

const POSSIBLE_DIRECTIONS = [&"right", &"left", &"down", &"up"]
const NEXT_PULL_TIME = 0.5 # s
const NEXT_PULL_RANGE = PI / 4 # rads
const DOG_SPEED = 100 # px/s

@export var speed = 400 # px/s
@export var ACTIVATION_DISTANCE = 100 # px
@export var LEASH_LENGTH = 100 # px

var last_direction: String = ""
var screen_size: Vector2
var leashed_dogs = []

var n_dogs: int = 0
var dog_score: int = 0
# We store current and the next pull direction
var pull_directions_schedule = []  # [dog, directions]
var current_pull_direction: Vector2
var pull_timer: float = 0
var dog_scene = preload("res://dog.tscn")

func set_dogs(value: int):
	# This only does extra operations for dropping the number of dogs, we should fix it.
	n_dogs = value
	while leashed_dogs.size() > n_dogs:
		leashed_dogs[-1].queue_free()
		leashed_dogs.pop_back()
	while pull_directions_schedule.size() > n_dogs:
		pull_directions_schedule.pop_back()

func get_closest_dog() -> Array:
	var closest_dog = null
	var closest_distance = INF
	var closest_direction = null
	for dog in get_tree().get_nodes_in_group("dogs"):
		var distance = position.distance_to(dog.position)
		if distance < closest_distance:
			closest_dog = dog
			closest_distance = distance
			closest_direction = position.direction_to(dog.position)

	return [closest_dog, closest_distance, closest_direction]

func activate_dog():
	# Do we have tuple unpacking here?
	var dog_and_dist_dir = get_closest_dog()
	var dog = dog_and_dist_dir[0]
	if dog == null:
		return
	var distance = dog_and_dist_dir[1]
	if distance > ACTIVATION_DISTANCE:
		return

	var breed = dog.breed
	dog.queue_free()
	add_leashed_dog(breed, dog_and_dist_dir[2])

func potentially_release_dog():
	if Input.is_action_just_pressed(&"select"):
		if n_dogs > 0:
			set_dogs(n_dogs - 1)

func sprite_size() -> Vector2:
	var sprite_frames = $AnimatedSprite2D.sprite_frames
	var texture       = sprite_frames.get_frame_texture("up_idle", 0)
	var texture_size  = texture.get_size()
	var as2d_size     = texture_size * $AnimatedSprite2D.get_scale()
	return as2d_size

func update_animation():
	for direction in POSSIBLE_DIRECTIONS:
		if Input.is_action_pressed(direction):
			last_direction = direction
			$AnimatedSprite2D.play(direction)
			return

	# Not moving right now.
	if last_direction != "":
		$AnimatedSprite2D.play(last_direction + "_idle")

static func sum_array(array):
	var sum = Vector2(0.0, 0.0)
	for element in array:
		sum += element
	return sum

func move_player(delta: float):
	var direction = get_direction()
	var velocity = direction * speed

	pull_timer += delta
	if (pull_timer > NEXT_PULL_TIME):
		for dog in range(pull_directions_schedule.size()):
			var pull_direction_change = randf_range(-NEXT_PULL_RANGE, NEXT_PULL_RANGE)
			pull_directions_schedule[dog].append(pull_directions_schedule[dog][-1].rotated(pull_direction_change))
			if pull_directions_schedule[dog].size() > 2:
				pull_directions_schedule[dog].pop_front()
	pull_timer = fmod(pull_timer, NEXT_PULL_TIME)
	var proportion = pull_timer / NEXT_PULL_TIME
	var pull_directions = []
	for dog in range(pull_directions_schedule.size()):
		pull_directions.append(pull_directions_schedule[dog][0].lerp(pull_directions_schedule[dog][-1], proportion))
	var pull_velocity = sum_array(pull_directions) * DOG_SPEED
	velocity += pull_velocity

	position += velocity * delta
	position = position.clamp(Vector2.ZERO, screen_size)
	for dog in range(leashed_dogs.size()):
		leashed_dogs[dog].position = pull_directions[dog] * LEASH_LENGTH

func add_leashed_dog(breed: String, direction: Vector2):
	set_dogs(n_dogs + 1)
	var leashed_dog = dog_scene.instantiate()
	leashed_dog.breed = breed
	leashed_dog.remove_from_group("dogs")
	leashed_dog.position = direction * LEASH_LENGTH
	add_child(leashed_dog)
	leashed_dogs.append(leashed_dog)
	pull_directions_schedule.append([direction, direction])

func get_direction():
	var direction = Vector2.ZERO
	if Input.is_action_pressed(&"right"):
		direction.x += 1
	if Input.is_action_pressed(&"left"):
		direction.x -= 1
	if Input.is_action_pressed(&"down"):
		direction.y += 1
	if Input.is_action_pressed(&"up"):
		direction.y -= 1

	return direction.normalized()

func _ready() -> void:
	screen_size = get_viewport_rect().size - sprite_size()

func _process(delta: float) -> void:
	update_animation()
	activate_dog()
	move_player(delta)
	potentially_release_dog()

func _on_area_2d_area_entered(area: Area2D) -> void:
	if area.is_in_group("house") and n_dogs > 0:
		var new_score = (10 * n_dogs) + pow(n_dogs, 2)
		dog_score += new_score
		$"../Score".text = str(dog_score)
		set_dogs(0)
