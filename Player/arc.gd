extends Node2D

var _points : PackedVector2Array
var fade = false

func _draw():
	for point in _points:
		draw_circle(to_local(point), 2, Color(1,1,1,1 - to_local(point).length_squared() / 8100))
		
func _process(delta):
	queue_redraw()
	if fade:
		modulate.a = clampf(modulate.a - 1.2 * delta, 0, 1)
	else:
		modulate.a = 1
	
func set_points(pts : PackedVector2Array) -> void:
	_points = pts
