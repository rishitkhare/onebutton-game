extends Area2D


func _on_body_entered(body: Node2D) -> void:
	if body.is_in_group("Player"):
		call_deferred("safe_reload_scene")

func safe_reload_scene():
	get_tree().reload_current_scene()
