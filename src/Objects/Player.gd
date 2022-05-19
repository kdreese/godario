extends KinematicBody2D


const GRAVITY = 1000
const RUN_SPEED = 400
const JUMP_POWER = -500


var velocity := Vector2.ZERO


func _physics_process(delta: float) -> void:
	var wishdir = Input.get_axis("ui_left", "ui_right")
	velocity.x = wishdir * RUN_SPEED

	velocity.y += GRAVITY * delta

	if is_on_floor() and Input.is_action_pressed("ui_up"):
		velocity.y = JUMP_POWER

	velocity = move_and_slide(velocity, Vector2.UP, true)
