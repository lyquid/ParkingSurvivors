extends Area2D

class_name ExpGem

onready var player := get_tree().root.get_node("Main/YSort/Player")
var exp_value := 1
var direction := Vector2.ZERO
var speed := 100.0
onready var timer := $DirectionTimer
onready var pickup_sound := $PickupSound


func _physics_process(delta):
	position += speed * direction * delta


func get_player_direction() -> Vector2:
	return (player.position - position).normalized()


func go_to_player():
	direction = get_player_direction()
	timer.start()


func _on_DirectionTimer_timeout():
	direction = get_player_direction()


func _on_ExpGem_body_entered(body):
	body.add_experience(exp_value)
	pickup_sound.play()


func _on_PickupSound_finished():
	get_tree().queue_delete(self)
