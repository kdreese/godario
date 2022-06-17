extends Node


export (PackedScene) var level_scene: PackedScene

onready var coin_count := $UI/CoinCount as Label
onready var coin_count_template := coin_count.text

var player: KinematicBody2D


func _ready() -> void:
	var level := level_scene.instance()

	var player_spawn: Position2D = level.get_node("PlayerSpawn")
	player = preload("res://src/Objects/Player.tscn").instance()
	player.position = player_spawn.position
	player_spawn.queue_free()

	$GameCamera.player = player
	var error := player.connect("coin_collected", self, "_on_player_coin_collected")
	assert(not error)

	add_child(level)
	add_child(player)

	update_coin_count()


func _on_player_coin_collected() -> void:
	Global.game_state.coins += 1
	update_coin_count()


func update_coin_count() -> void:
	coin_count.text = coin_count_template % Global.game_state.coins
