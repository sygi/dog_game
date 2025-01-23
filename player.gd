extends Node2D

@export var speed = 400 # px/s
@export var ACTIVATION_DISTANCE = 100 # px

const POSSIBLE_DIRECTIONS = [&"right", &"left", &"down", &"up"]
var last_direction: String = ""
var screen_size: Vector2
var active_dog = null


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
		dog.activate()
		active_dog = dog

func sprite_size() -> Vector2:
	var sprite_frames = $AnimatedSprite2D.sprite_frames
	var texture       = sprite_frames.get_frame_texture("up_idle", 0)
	var texture_size  = texture.get_size()
	var as2d_size     = texture_size * $AnimatedSprite2D.get_scale()
	return as2d_size

func _ready() -> void:
	screen_size = get_viewport_rect().size - sprite_size()

func update_animation():
	for direction in POSSIBLE_DIRECTIONS:
		if Input.is_action_pressed(direction):
			last_direction = direction
			$AnimatedSprite2D.play(direction)
			return

	# Not moving right now.
	if last_direction != "":
		$AnimatedSprite2D.play(last_direction + "_idle")


func _process(delta: float) -> void:
	update_animation()
	activate_dog()
	var direction = get_direction()
	var velocity = direction * speed

	position += velocity * delta
	position = position.clamp(Vector2.ZERO, screen_size)


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
