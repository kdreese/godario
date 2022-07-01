extends Camera2D


var player: KinematicBody2D


func _process(_delta: float) -> void:
	if player:
		position = player.position
		var target_y := -get_viewport_rect().size.y / 2
		if position.y > target_y:
			position.y = target_y
