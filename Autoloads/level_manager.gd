extends Node

var current_level = 0
var levels = ["res://alevel1.tscn", "res://level1.tscn"]

# Called when the node enters the scene tree for the first time.
func _ready() -> void:
	pass # Replace with function body.

# Called when player touches the flag, keep a global counter to keep 
# track of levels
func changeLevel():
	current_level += 1
	if current_level >= levels.size():
		current_level = 0  # Loop back to the first level if last level is reached
	change_scence(levels[current_level])

func change_scence(scene):
	get_tree().change_scene_to_file(scene)


# Called every frame. 'delta' is the elapsed time since the previous frame.
func _process(delta: float) -> void:
	pass
