extends Area2D

@onready var time_elapsed : float = 0

@onready var sprite : Sprite2D = $Sprite
@onready var light : PointLight2D = $Sprite/PointLight2D

@onready var active = true

@onready var explosion_particles : GPUParticles2D = $explosion

func _process(delta: float) -> void:
	var scaled_delta : float = 2 * delta * TimeScale.get_time_scale()
	
	time_elapsed += scaled_delta
	
	if time_elapsed > 6.28:
		time_elapsed -= (2 * PI)
		
	sprite.position.y = sin(time_elapsed) * 3
	
	if active:
		sprite.scale.x += delta * 3
	else:
		sprite.scale.x = 0
	
	sprite.scale.x = clampf(sprite.scale.x, 0, 1)
	sprite.scale.y = sprite.scale.x
	light.scale = sprite.scale * 0.5

func _on_body_entered(body: Node2D) -> void:
	if body.is_in_group("Player") && active:
		TimeScale.temporary_slow_mo(0.1, 2)
		body.double_jump = true
		body.get_node("Camera2D").shake_screen(0.5,2)
		modulate = Color(10,10,10)
		active = false
		explosion_particles.restart()
		
func _on_body_exit(body: Node2D) -> void:
	if body.is_in_group("Player"):
		$CooldownTimer.start()

func _on_cooldown_timer_timeout() -> void:
	active = true
	modulate = Color(1,1,1)
