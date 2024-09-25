extends GPUParticles2D

func _ready():
	TimeScale.on_time_scale_changed.connect(_on_timescale_change)
	
func _on_timescale_change(value):
	speed_scale = value
