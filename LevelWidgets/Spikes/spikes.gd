extends Area2D


func _on_body_entered(body: Node2D) -> void:
	if body.is_in_group("Player"):
		body.die()

func safe_reload_scene():
	get_tree().reload_current_scene()
