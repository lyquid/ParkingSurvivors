extends Node

# Called when the node enters the scene tree for the first time.
func _ready():
	randomize()


# Called every frame. 'delta' is the elapsed time since the previous frame.
#func _process(delta):
#	pass


func _input(_event):
	if Input.is_action_pressed("ui_cancel"):
		get_tree().quit()
