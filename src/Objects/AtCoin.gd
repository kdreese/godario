extends Area2D


func _on_AtCoin_body_entered(body: Node) -> void:
	body.collect_coin()
	queue_free()
