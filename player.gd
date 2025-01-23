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
var active_dog = null # TODO: remove this
var leashed_dog = null

var n_dogs: int = 0
var dog_score: int = 0
# We store current and the next pull direction
var pull_directions_schedule: Array[Vector2] = [Vector2.UP.rotated(randf_range(0, TAU))]
var current_pull_direction: Vector2
var pull_timer: float = 0
var dog_scene = preload("res://dog.tscn")

func set_dog_counter(value: int):
	n_dogs = value
	if value == 0 and leashed_dog != null:
		leashed_dog.queue_free()
	$"../dog_counter".text = str(value)

func get_closest_dog() -> Array:
	var closest_dog = null
	var closest_distance = INF
	for dog in get_tree().get_nodes_in_group("dogs"):
		var distance = position.distance_to(dog.position)
		if distance < closest_distance:
			closest_dog = dog
			closest_distance = distance

	if active_dog != null and closest_dog != active_dog:
		active_dog.deactivate()
		active_dog = null
	return [closest_dog, closest_distance]

func activate_dog():
	# Do we have tuple unpacking here?
	var dog_and_dist = get_closest_dog()
	var dog = dog_and_dist[0]
	if dog == null:
		return
	var distance = dog_and_dist[1]
	if distance > ACTIVATION_DISTANCE:
		if active_dog != null:
			active_dog.deactivate()
			active_dog = null
		return

	if not dog.is_active:
		var breed = dog.breed
		dog.activate()
		#active_dog = dog
		add_leashed_dog(breed)

func potentially_release_dog():
	if Input.is_action_just_pressed(&"select"):
		if n_dogs > 0:
			set_dog_counter(n_dogs - 1)

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

func move_player(delta: float):
	var direction = get_direction()
	var velocity = direction * speed

	pull_timer += delta
	if (pull_timer > NEXT_PULL_TIME):
		var pull_direction_change = randf_range(-NEXT_PULL_RANGE, NEXT_PULL_RANGE)
		pull_directions_schedule.append(pull_directions_schedule[-1].rotated(pull_direction_change))
	if pull_directions_schedule.size() > 2:
		pull_directions_schedule.pop_front()
	pull_timer = fmod(pull_timer, NEXT_PULL_TIME)
	var proportion = pull_timer / NEXT_PULL_TIME
	current_pull_direction = pull_directions_schedule[0].lerp(pull_directions_schedule[-1], proportion)
	var pull_velocity = current_pull_direction * n_dogs * DOG_SPEED
	velocity += pull_velocity

	position += velocity * delta
	position = position.clamp(Vector2.ZERO, screen_size)
	if leashed_dog != null:
		# TODO: make this smoother
		leashed_dog.position = current_pull_direction * LEASH_LENGTH

func add_leashed_dog(breed: String):
	set_dog_counter(n_dogs + 1)
	if n_dogs == 1:
		# first dog, visualizing it
		leashed_dog = dog_scene.instantiate()
		leashed_dog.breed = breed
		leashed_dog.remove_from_group("dogs")
		add_child(leashed_dog)

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
	if area.is_in_group("house"):
		dog_score += n_dogs # TODO: something growing quicker than linear here
		set_dog_counter(0)
		if leashed_dog != null:
			leashed_dog.queue_free()
