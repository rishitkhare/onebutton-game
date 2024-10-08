extends CharacterBody2D

# tweakable parameters
const ROT_SPEED = 0.6

const JUMP_PWR = 200

const GRAVITY = 600
const TERMINAL_VEL = 350

@onready var aim_vector = Vector2.UP
@onready var aim_vector_rotation_dir = -ROT_SPEED

@onready var ground_raycast_left : RayCast2D
@onready var ground_raycast_right : RayCast2D

@onready var arc_renderer : Node2D
@onready var sprite : AnimatedSprite2D = $AnimatedSprite2D

# particles
@onready var landing_particles : GPUParticles2D = $LandingParticles
@onready var jumping_particles : GPUParticles2D = $JumpingParticles
@onready var jump_trail_left : GPUParticles2D = $JumpTrailLeft
@onready var jump_trail_right : GPUParticles2D = $JumpTrailRight
@onready var jump_trail_up : GPUParticles2D = $JumpTrailUp

@onready var light : Light2D = $PointLight2D

# screenshake
@onready var screenshake : Camera2D = $Camera2D

# used to temporarily disable grounded check after jump
@onready var ground_timer : Timer

@onready var grounded : bool

# stores how long the button has been pressed for
@onready var buttonheld_duration : float
@onready var buttonheld_too_long : bool = false

@onready var spawn_point : Vector2 = position

@onready var double_jump : bool = false

func _ready():
	ground_raycast_left = $grounded_left
	ground_raycast_right = $grounded_right
	ground_timer = $groundedchecktimer
	arc_renderer = $arc
	
	grounded = false
	
func _input(event):
	# jump happens when the spacebar is released
	if event.is_action_released("jump") && !buttonheld_too_long:
		if (grounded || double_jump):
			var jump_power = get_jump_power()
			velocity = aim_vector * JUMP_PWR * jump_power
			grounded = false
			
			double_jump = false
			
			if(TimeScale.get_time_scale() != 1):
				TimeScale.target = 1
				TimeScale.set_time_scale(1)
				
			
			# render particles
			jumping_particles.restart()
			if(velocity.x > 110):
				jump_trail_right.restart()
			elif(velocity.x < -110):
				jump_trail_left.restart()
			else:
				jump_trail_up.restart()
			landing_particles.emitting = false
			
			# screen shake on charged jumps
			if jump_power > 1.4:
				screenshake.shake_screen(0.1, 3.5)
			
			# make the arc disappear now that the jump is in motion
			arc_renderer.fade = true
			
			# temporarily disable grounded check, to allow the player to change y-velocity
			set_raycast_enable(false)
			ground_timer.start()

# based on how long the button has been held for, determine the power of the jump.
# power is capped at 2, but cannot go lower than 1. The first 0.9 determines how long the user
# must hold before their power actually starts increasing. The second 0.9 is a parameter that determines
# the length of time it takes to reach max power. The 2 is a multiplier cap - no jump can
# ever be stronger than twice the strength of the weakest possible jump.
func get_jump_power() -> float:
	return clampf(0.9 + buttonheld_duration / 0.9, 1, 2)
	
# run every frame
func _physics_process(unscaled_time):
	var delta : float = unscaled_time * TimeScale.get_time_scale()
	
	# increment the timer that tracks how long the jump has been held for
	track_button_press(unscaled_time)
	
	# accelerate towards the ground (gravity)
	velocity.y += GRAVITY * delta
	
	if velocity.y > TERMINAL_VEL:
		velocity.y = TERMINAL_VEL
	
	# read the raycasts to see if player is on the ground (allows us to see if the player can jump)
	if check_grounded() != grounded: 
		grounded = !grounded
		if grounded:
			landing_particles.restart()
			
	if double_jump:
		sprite.modulate = Color(110,110,110)
		light.energy = min(light.energy + (delta * 20), 0.3)
	else:
		sprite.modulate = Color(1,1,1)
		light.energy = max(light.energy - (delta * 0.1), 0.2)
	light.texture_scale = light.energy + 0.4
	
	if grounded:
		# double jump turns off on the ground
		double_jump = false
		
		# animate the sprite to idle
		sprite.play("Idle")
		
		# when touching the ground, decelerate
		velocity.x = velocity.x * 0.9
	else:
			
		if velocity.y < 0:
			sprite.play("AscendingJump")
		else:
			sprite.play("DescendingJump")
	
	# is the player allowed to jump?
	if grounded || double_jump:
		# bring back the arc if it previously disappeared
		arc_renderer.fade = false
		
		# if the button isn't pressed, move the aim, otherwise
		# keep the aim constant and show the user the jump as its power increases
		if Input.is_action_pressed("jump") && !buttonheld_too_long:
			calculate_arc_points(get_jump_power() * aim_vector * 200)
		else:
			rotate_aim_vector(unscaled_time)
			calculate_arc_points(1 * aim_vector * 200)
			
	else:
		# If the player previously jumped right, the new aim will begin from the right
		# pointing right, if they previously jumped left, the new aim will begin from the left.
		# Also make the player sprite face the direction of the jump
		if velocity.x > 0:
			sprite.flip_h = false
			aim_vector = Vector2.RIGHT.rotated(-0.3*PI)
		elif velocity.x < 0:
			sprite.flip_h = true
			aim_vector = Vector2.RIGHT.rotated(-0.7*PI)
		aim_vector_rotation_dir = ROT_SPEED
		
	# preserve x velocity before collision - move_and_slide() will set it to zero. Instead of abrupt stop,
	# we want the player to gently decelerate - this helps them barely squeeze past corners more easily
	# by preserving some of the initial momentum they had when they snagged the corner.
	var precollision_xvelo = velocity.x
	var precollision_yvelo = velocity.y
	move_and_slide_with_scale(TimeScale.get_time_scale())
	
	# shake the screen on hard landings
	if velocity.y == 0 && precollision_yvelo  > 230:
		screenshake.shake_screen(0.1, 3.5)
	
	# if the player is hitting a wall, decelerate
	if !grounded && velocity.x == 0:
		velocity.x = precollision_xvelo * 0.9
	
	$Control/groundedLabel.text = "GROUNDED" if grounded else "FREEFALL"
	
# this function moves the aim of the jump back and forth
func rotate_aim_vector(delta):
	aim_vector = aim_vector.rotated(aim_vector_rotation_dir * delta)
	var angle = aim_vector.angle()
	if angle > -0.3*PI:
		aim_vector_rotation_dir = -ROT_SPEED
	if angle < -0.7*PI:
		aim_vector_rotation_dir = ROT_SPEED

# this function stores the duration for which jump has been held down
# in "buttonheld_duration"
func track_button_press(delta):
	if Input.is_action_pressed("jump"):
		buttonheld_duration += delta
		if buttonheld_duration > 8:
			buttonheld_too_long = true
	else:
		buttonheld_duration = 0
		buttonheld_too_long = false

# helper function to enable all grounded raycasts and turn them all off at once.
func set_raycast_enable(value: bool) -> void:
	ground_raycast_left.enabled = value
	ground_raycast_right.enabled = value
	
# helper function that queries all grounded raycasts and returns true if even one of them
# is touching ground
func check_grounded() -> bool:
	return ground_raycast_left.is_colliding() || ground_raycast_right.is_colliding()

# callback method for the grounded timer. When the player jumps, the grounded raycasts are temporarily
# disabled, but after a very short time (0.2ish seconds) they are re-enabled. This prevents the code
# from thinking that the player is grounded at the start of a jump, despite jumps always starting from 
# the ground.
func _on_groundedchecktimer_timeout() -> void:
	# re-enable the raycast
	set_raycast_enable(true)
	
# method to calculate where to place the arc dots (white dots outlining the jump trajectory). It runs
# by calculating a projectile motion simulation for 49 frames at 60fps and placing a dot at every 7th
# frame. The simulation ignores collisions to keep the computation load light.
func calculate_arc_points(start_vel : Vector2) -> PackedVector2Array:
	const DELTASTEP = 0.016
	
	var points = PackedVector2Array()
	var simulated_pos = position
	var simulated_vel = start_vel
	for x in range(1, 50):
		simulated_pos += simulated_vel * DELTASTEP
		simulated_vel.y += GRAVITY * DELTASTEP
		if(x % 7 == 0):
			points.append(simulated_pos)
		
	arc_renderer.set_points(points)
	
	
	return points
	
func move_and_slide_with_scale(scaled: float ) -> void:
	velocity *= scaled
	move_and_slide()
	velocity /= scaled
	
func die():
	position = spawn_point
	velocity = Vector2.ZERO
