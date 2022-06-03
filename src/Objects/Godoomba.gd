extends KinematicBody2D


const GRAVITY = 1000
const HIT_HURT_ANGLE = 0.8

var velocity := Vector2(-100, 0)


func _physics_process(delta: float) -> void:
	velocity.y += GRAVITY * delta
	velocity = move_and_slide(velocity, Vector2.UP)
	var checkLeft = not $GodoombaWalkingLeft.is_colliding()
	var checkRight = not $GodoombaWalkingRight.is_colliding()
	if ((checkLeft or checkRight) and is_on_floor()) or is_on_wall():
		velocity.x *= -1


func _on_GodoombaHitHurtBox_body_entered(body: Node) -> void:
	var collisionVector = position.direction_to(body.position)
	var godoombaNormal = Vector2(0, -1)
	if collisionVector.dot(godoombaNormal) > HIT_HURT_ANGLE:
		body.bounce()
		queue_free()
	else:
		pass # player hurt
