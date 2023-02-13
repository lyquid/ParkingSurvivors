extends Area2D

class_name PickUp

const SPEED := 100.0

onready var player := get_tree().root.get_node("Main/YSort/Player")
onready var timer := $DirectionTimer
onready var pickup_sound := $PickupSound
var direction := Vector2.ZERO


func _physics_process(delta):
	position += SPEED * direction * delta


func get_player_direction() -> Vector2:
	return (player.position - position).normalized()


func go_to_player():
	direction = get_player_direction()
	timer.start()


func _on_DirectionTimer_timeout():
	direction = get_player_direction()


func _on_PickupSound_finished():
	get_tree().queue_delete(self)
