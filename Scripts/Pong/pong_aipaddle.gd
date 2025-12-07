extends CharacterBody2D

@onready var ball = get_parent().get_node("Ball")

const THRESHOLD = 3.0
const MAX_SPEED = 550.0
const ACCELERATION = 2000.0
const ERROR_MARGIN = 50.0

var velocity_x = 0.0

func _physics_process(delta):
	if not ball:
		return

	var target_x = ball.position.x + randf_range(-ERROR_MARGIN, ERROR_MARGIN)
	var distance_x = target_x - position.x

	if abs(distance_x) > THRESHOLD:
		var desired_velocity = sign(distance_x) * MAX_SPEED
		velocity_x = move_toward(velocity_x, desired_velocity, ACCELERATION * delta)
	else:
		velocity_x = 0

	velocity.x = velocity_x
	velocity.y = 0
	position.y = 70.0

	move_and_slide()
