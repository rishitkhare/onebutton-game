extends CharacterBody2D

@onready var aim_vector = Vector2.UP
@onready var aim_vector_rotation_dir = -1

const gravity = 600

func _ready():
	pass
	
func _input(event):
	if event.is_action_pressed("jump"):
		velocity = aim_vector * 300
	
func _draw():
	draw_line(Vector2.ZERO, aim_vector * 50, Color.WHITE, 1.0, true)
	
func _process(delta):
	rotate_aim_vector(delta)
	move_and_slide()
	
	velocity.y += gravity * delta
	
func rotate_aim_vector(delta):
	aim_vector = aim_vector.rotated(aim_vector_rotation_dir * delta)
	var angle = aim_vector.angle()
	if angle > -0.25*PI:
		aim_vector_rotation_dir = -1
	if angle < -0.75*PI:
		aim_vector_rotation_dir = 1
	queue_redraw()
	
