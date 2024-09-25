extends Node

@onready var _time_scale : float = 1

@onready var timer : Timer = $Timer

@warning_ignore("unused_signal")
signal on_time_scale_changed(value)

@onready var target : float = 1

func _process(delta):
	if _time_scale < target:
		set_time_scale(min(_time_scale + 1.9 * delta, target))
	elif _time_scale > target:
		set_time_scale(target)

func set_time_scale(value: float) -> void:
	_time_scale = value
	emit_signal("on_time_scale_changed", _time_scale)

func get_time_scale() -> float:
	return _time_scale
	
func temporary_slow_mo(scale, duration):
	target = scale
	timer.wait_time = duration
	timer.start()
	



func _on_timer_timeout() -> void:
	target = 1
