extends Node2D

@export var speed = 400 # px/s

var screen_size: Vector2

func _ready() -> void:
	# playing animation
	$AnimatedSprite2D.play("going_up")

	screen_size = get_viewport_rect().size


func _process(delta: float) -> void:
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
