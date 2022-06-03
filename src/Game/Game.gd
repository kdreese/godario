extends Node


export (PackedScene) var level_scene: PackedScene

var player: KinematicBody2D


func _ready() -> void:
	var level := level_scene.instance()

	var player_spawn: Position2D = level.get_node("PlayerSpawn")
	player = preload("res://src/Objects/Player.tscn").instance()
	player.position = player_spawn.position
	player_spawn.queue_free()

	$GameCamera.player = player

	add_child(level)
	add_child(player)
