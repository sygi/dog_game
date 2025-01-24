extends Control

@export var WARNING_TIME: float = 0.5
@export var WARNING_THRESHOLD: float = 80
@onready var recency_weight: float = 0.1

func _ready() -> void:
	pass

var running_average: float = 100.0

func update_movement_stats(velocity: float):
	if recency_weight == null:
		return
	var scaled_movement = velocity * WARNING_TIME
	running_average = running_average * (1. - recency_weight) + scaled_movement * recency_weight
	if running_average < WARNING_THRESHOLD:
		visible = true
		$Timer.start()

# Called every frame. 'delta' is the elapsed time since the previous frame.
func _process(delta: float) -> void:
	pass

func _on_timer_timeout() -> void:
	visible = false
