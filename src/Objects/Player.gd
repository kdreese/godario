extends KinematicBody2D


const GRAVITY = 1000

const MAX_RUN_SPEED = 400
const RUN_ACCEL = 1000
const GROUND_FRICTION_ACCEL = 800
const AIR_FRICTION_ACCEL = 100
const SLOWDOWN_ACCEL = 1500

const JUMP_POWER = 500
const DOUBLE_JUMP_POWER = 600
const TRIPLE_JUMP_POWER = 700
const JUMP_SPEED_SCALING = 0.25
const BOUNCE_POWER = 250

const CONSECUTIVE_JUMP_WINDOW = 0.25 # Seconds between landing on the ground and losing your n-jump counter
const TRIPLE_JUMP_SPEED_THRESHOLD = 300


var velocity := Vector2.ZERO
var is_jumping := false
var is_flipped := false
var num_jumps := 0
var time_on_ground := 0.0


func _physics_process(delta: float) -> void:
	var wishdir = Input.get_axis("game_left", "game_right")

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
		if (wishdir > 0) == is_flipped:
			is_flipped = not is_flipped
			scale.x *= -1

	velocity.y += GRAVITY * delta

	if velocity.y >= 0:
		is_jumping = false

	if is_jumping and Input.is_action_just_released("game_jump"):
		is_jumping = false
		velocity.y *= 0.4

	if is_on_floor():
		time_on_ground += delta
		if time_on_ground > CONSECUTIVE_JUMP_WINDOW:
			num_jumps = 0
		if Input.is_action_just_pressed("game_jump"):
			var jump_power := JUMP_POWER
			num_jumps += 1
			if num_jumps == 2:
				jump_power = DOUBLE_JUMP_POWER
			elif num_jumps == 3:
				if abs(velocity.x) < TRIPLE_JUMP_SPEED_THRESHOLD:
					num_jumps = 1
				else:
					jump_power = TRIPLE_JUMP_POWER
					num_jumps = 0
			velocity.y = -(jump_power + abs(velocity.x) * JUMP_SPEED_SCALING)
			is_jumping = true
			time_on_ground = 0

	velocity = move_and_slide(velocity, Vector2.UP, true)


func bounce():
	if Input.is_action_pressed("ui_up"):
		velocity.y = -JUMP_POWER
	else:
		velocity.y = -BOUNCE_POWER
