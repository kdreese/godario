extends KinematicBody2D


const GRAVITY = 1000

const MAX_RUN_SPEED = 400
const RUN_ACCEL = 1000
const GROUND_FRICTION_ACCEL = 800
const AIR_FRICTION_ACCEL = 100
const SLOWDOWN_ACCEL = 1500
const DAMAGE_BOUNCE_FORCE = Vector2(-300, -400)
const BOPPAGE_STUN = 0.3

const JUMP_POWER = 500
const DOUBLE_JUMP_POWER = 600
const TRIPLE_JUMP_POWER = 700
const JUMP_SPEED_SCALING = 0.25
const BOUNCE_POWER = 250

const CONSECUTIVE_JUMP_WINDOW = 0.25 # Seconds between landing on the ground and losing your n-jump counter
const COYOTE_TIME_WINDOW = 0.1 # Seconds after leaving that ground where you can still jump
const JUMP_BUFFER_WINDOW = 0.1 # Seconds after pressing jump that you'll still jump upon reaching the ground
const TRIPLE_JUMP_SPEED_THRESHOLD = 300


onready var animation_player := $AnimationPlayer as AnimationPlayer


var velocity := Vector2.ZERO
var is_jumping := false
var is_flipped := false
var is_attempting_jump := false
var num_jumps := 0
var time_on_ground := 0.0
var time_in_air := 0.0
var time_til_ground := 0.0

var health := 3
var time_since_bopped := 0.0


func _physics_process(delta: float) -> void:
	var wishdir = 0
	if time_since_bopped > 0:
		time_since_bopped -= delta
	else:
		wishdir = Input.get_axis("game_left", "game_right")

	var target_velocity = MAX_RUN_SPEED * wishdir
	var too_fast = false
	if target_velocity > 0:
		too_fast = velocity.x > target_velocity
	elif target_velocity < 0:
		too_fast = velocity.x < target_velocity
	else: # target_velocity == 0:
		too_fast = true

	if too_fast:
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
			velocity.x = min(velocity.x, target_velocity)
		else:
			velocity.x = max(velocity.x, target_velocity)
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
		time_in_air = 0
		time_on_ground += delta
		if time_on_ground > CONSECUTIVE_JUMP_WINDOW:
			num_jumps = 0
		if is_attempting_jump and time_til_ground < JUMP_BUFFER_WINDOW:
			jump()
		else:
			is_attempting_jump = false
			if Input.is_action_just_pressed("game_jump"):
				jump()
	else:
		time_on_ground = 0
		time_in_air += delta
		if is_attempting_jump:
			time_til_ground += delta
		if Input.is_action_just_pressed("game_jump"):
			if time_in_air < COYOTE_TIME_WINDOW:
				jump()
			else:
				is_attempting_jump = true
				time_til_ground = 0

	velocity = move_and_slide(velocity, Vector2.UP, true)


func bounce():
	if Input.is_action_pressed("ui_up"):
		velocity.y = -JUMP_POWER
	else:
		velocity.y = -BOUNCE_POWER


func jump():
	var jump_power := JUMP_POWER
	animation_player.play("Jump")
	num_jumps += 1
	if num_jumps == 2:
		jump_power = DOUBLE_JUMP_POWER
		animation_player.play("Double Jump")
	elif num_jumps == 3:
		if abs(velocity.x) < TRIPLE_JUMP_SPEED_THRESHOLD:
			num_jumps = 1
		else:
			jump_power = TRIPLE_JUMP_POWER
			num_jumps = 0
			animation_player.play("Triple Jump")
	velocity.y = -(jump_power + abs(velocity.x) * JUMP_SPEED_SCALING)
	is_jumping = true


func damage_from_enemy():
	health -= 1
	hurt_force()
	$AnimationPlayer.play("Hurt")
	if health <= 0:
		die()


func hurt_force():
	if velocity.x > 0 or (velocity.x == 0 and not is_flipped):
		velocity = DAMAGE_BOUNCE_FORCE
	else:
		velocity.x = -DAMAGE_BOUNCE_FORCE.x
		velocity.y = DAMAGE_BOUNCE_FORCE.y
	time_since_bopped = BOPPAGE_STUN


func die():
	var error := get_tree().reload_current_scene()
	assert(not error)
