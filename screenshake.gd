extends Camera2D

var intensity : float
@onready var rng = RandomNumberGenerator.new()

func shake_screen(time, setIntensity):
	$ScreenShakeTimer.wait_time = time
	$ScreenShakeTimer.start()
	intensity = setIntensity

func _ready():
	rng.randomize()

func _process(_delta):
	offset.y = rng.randf_range(-intensity, intensity)
	if(offset.y == 0 && intensity != 0):
		offset.y = 1

func _on_screen_shake_timer_timeout() -> void:
	intensity = 0
