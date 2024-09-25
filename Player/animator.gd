extends AnimatedSprite2D


# time scaling on animations
func _ready():
	speed_scale = TimeScale.get_time_scale()
	TimeScale.on_time_scale_changed.connect(_on_time_scale_change)
	
func _on_time_scale_change(value : float) -> void:
	speed_scale = value
