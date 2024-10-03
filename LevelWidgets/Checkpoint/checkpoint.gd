extends Area2D

@onready var earned = false

func _on_body_entered(body: Node2D) -> void:
	if !earned && body.is_in_group("Player"):
		body.spawn_point = global_position
		$AnimationPlayer.play("checkpoint")
		earned = true
