extends KinematicBody2D


const GRAVITY = 1000

const MAX_RUN_SPEED = 400
const RUN_ACCEL = 1000
const GROUND_FRICTION_ACCEL = 800
const AIR_FRICTION_ACCEL = 100
const SLOWDOWN_ACCEL = 1500

const JUMP_POWER = 500
const JUMP_SPEED_SCALING = 0.25


var velocity := Vector2.ZERO
var is_jumping := false


func _physics_process(delta: float) -> void:
	var wishdir = Input.get_axis("ui_left", "ui_right")

	if wishdir == 0:
		var friction_accel := GROUND_FRICTION_ACCEL if is_on_floor() else AIR_FRICTION_ACCEL
		if velocity.x > 0:
			velocity.x -= friction_accel * delta
			velocity.x = max(velocity.x, 0)
		elif velocity.x < 0:
			velocity.x += friction_accel * delta
			velocity.x = min(velocity.x, 0)
	else:
		if sign(wishdir) == -sign(velocity.x):
			velocity.x += wishdir * SLOWDOWN_ACCEL * delta
		else:
			velocity.x += wishdir * RUN_ACCEL * delta
		if wishdir > 0:
			velocity.x = min(velocity.x, MAX_RUN_SPEED)
		else:
			velocity.x = max(velocity.x, -MAX_RUN_SPEED)

	velocity.y += GRAVITY * delta

	if velocity.y >= 0:
		is_jumping = false

	if is_jumping and Input.is_action_just_released("ui_up"):
		is_jumping = false
		velocity.y *= 0.4

	if is_on_floor() and Input.is_action_pressed("ui_up"):
		velocity.y = -(JUMP_POWER + abs(velocity.x) * JUMP_SPEED_SCALING)
		is_jumping = true

	velocity = move_and_slide(velocity, Vector2.UP, true)
