extends Camera2D


var player: KinematicBody2D


func _process(_delta: float) -> void:
	if player:
		position = player.position
