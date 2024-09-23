extends Node

@onready var _time_scale : float = 1

@onready var timer : Timer = $Timer

signal on_time_scale_changed(value)

func set_time_scale(value: float) -> void:
	_time_scale = value
	emit_signal("on_time_scale_changed", _time_scale)

func get_time_scale() -> float:
	return _time_scale
	
func temporary_slow_mo(scale, duration):
	set_time_scale(scale)
	timer.wait_time = duration
	timer.start()


func _on_timer_timeout() -> void:
	set_time_scale(1)
