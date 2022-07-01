extends Area2D


export (String) var next_level_path


func _on_LevelFinish_body_entered(_body: Node) -> void:
	Global.game_state.level_scene_path = next_level_path
	var error := get_tree().change_scene("res://src/Game/Game.tscn")
	assert(not error)

