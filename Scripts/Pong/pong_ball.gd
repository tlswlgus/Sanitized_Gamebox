extends CharacterBody2D

var ball_velocity := Vector2.ZERO

const BASE_SPEED := 600.0
const MAX_SPEED := 1200.0
const SPEED_INCREMENT := 1.03

func _ready():
	reset()

func _physics_process(delta):
	var collision = move_and_collide(ball_velocity * delta)

	if collision:
		var normal = collision.get_normal()
		ball_velocity = ball_velocity.bounce(normal)
		ball_velocity = ball_velocity.normalized() * min(ball_velocity.length() * SPEED_INCREMENT, MAX_SPEED)

	# Prevent horizontal dead-zone
	if abs(ball_velocity.y) < 150:
		ball_velocity.y = sign(ball_velocity.y) * 150

	# Cap speed
	if ball_velocity.length() > MAX_SPEED:
		ball_velocity = ball_velocity.normalized() * MAX_SPEED

	# Reset when out of bounds
	var screen = get_viewport_rect().size
	if position.y < -50 or position.y > screen.y + 50:
		reset()

func reset():
	position = get_viewport_rect().size / 2
	var dir = Vector2(randf_range(-1, 1), randf_range(-1, 1)).normalized()
	ball_velocity = dir * BASE_SPEED
