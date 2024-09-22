extends AnimatableBody2D

@export var movements : PackedVector2Array
@export var seconds_per_movement : float = 1.0

@onready var rider : CharacterBody2D

@onready var t_value = 0

@onready var original_position = position

@onready var sprite = $AnimatedSprite2D

func _ready() -> void:
	sprite.play()

func _physics_process(delta):
	# increment t_value, wrap it so that the animation cycles
	t_value = fmod(t_value + delta, seconds_per_movement * movements.size())
	var index : int = floor(t_value / seconds_per_movement)
	
	var old_position = position
	var new_position = original_position + lerp(movements[index], movements[(index + 1) % movements.size()], fmod(t_value, seconds_per_movement) / seconds_per_movement)
	
	print("platform moved")
	position = new_position
	
	# move the rider with the platform
	if rider:
		rider.relative_motion = (position - old_position) / delta
		$Control/Label.text = "RIDING: " + str(sign(rider.relative_motion.x))
		
		# as soon as rider is in free fall, we cannot control its position.
		if rider.grounded == false:
			rider.relative_motion = Vector2.ZERO
			rider = null
	else:
		$Control/Label.text = ""
		
		
