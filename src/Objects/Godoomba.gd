extends KinematicBody2D


const GRAVITY = 1000
const HIT_HURT_ANGLE = 0.8
const SPEED := 100

var velocity := Vector2(-SPEED, 0)
var direction := -1


func _physics_process(delta: float) -> void:
	velocity.y += GRAVITY * delta
	velocity = move_and_slide(velocity, Vector2.UP)
	var checkLeft = not $GodoombaWalkingLeft.is_colliding() and $GodoombaWalkingLeft.is_enabled()
	var checkRight = not $GodoombaWalkingRight.is_colliding() and $GodoombaWalkingRight.is_enabled()
	if ((checkLeft or checkRight) and is_on_floor()) or is_on_wall():
		direction *= -1
		velocity.x = direction * SPEED
		if(checkLeft):
			$GodoombaWalkingLeft.enabled = false
			$GodoombaWalkingRight.enabled = true
		elif(checkRight):
			$GodoombaWalkingRight.enabled = false
			$GodoombaWalkingLeft.enabled = true
		elif(is_on_wall()):
			$GodoombaWalkingRight.enabled = true
			$GodoombaWalkingLeft.enabled = true


func _on_GodoombaHitHurtBox_body_entered(body: Node) -> void:
	var collisionVector = position.direction_to(body.position)
	var godoombaNormal = Vector2(0, -1)
	if collisionVector.dot(godoombaNormal) > HIT_HURT_ANGLE:
		body.bounce()
		queue_free()
	else:
		body.damage_from_enemy()
