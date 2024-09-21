extends CharacterBody2D

@onready var aim_vector = Vector2.UP
@onready var aim_vector_rotation_dir = -1

@onready var ground_raycast : RayCast2D

# used to temporarily disable grounded check after jump
@onready var ground_timer : Timer

@onready var grounded : bool

# stores how long the button has been pressed for
@onready var buttonheld_duration : float

const gravity = 600

func _ready():
	ground_raycast = $groundedcheck
	ground_timer = $groundedchecktimer
	
	grounded = false
	
func _input(event):
	if event.is_action_released("jump"):
		var jump_power = clampf(buttonheld_duration / 0.2, 1, 2)
		
		velocity = aim_vector * 200 * jump_power
		grounded = false
		queue_redraw()
		ground_raycast.enabled = false
		ground_timer.start()
		
	
func _draw():
	if grounded:
		draw_line(Vector2.ZERO, aim_vector * 50, Color.WHITE, 1.0, true)
	
func _process(delta):
	track_button_press(delta)
	
	velocity.y += gravity * delta
	
	grounded = ground_raycast.is_colliding()
	if grounded:
		velocity.y = 0
		velocity.x *= 0.95
		rotate_aim_vector(delta)
	else:
		aim_vector = Vector2.UP
	move_and_slide()
	
func rotate_aim_vector(delta):
	aim_vector = aim_vector.rotated(aim_vector_rotation_dir * delta)
	var angle = aim_vector.angle()
	if angle > -0.25*PI:
		aim_vector_rotation_dir = -1
	if angle < -0.75*PI:
		aim_vector_rotation_dir = 1
	queue_redraw()

func track_button_press(delta):
	if Input.is_action_pressed("jump"):
		buttonheld_duration += delta
	else:
		buttonheld_duration = 0
	


func _on_groundedchecktimer_timeout() -> void:
	# re-enable the raycast
	ground_raycast.enabled = true
