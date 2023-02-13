extends PickUp

class_name ExpGem

var exp_value := 1


func _on_ExpGem_body_entered(body):
	body.add_experience(exp_value)
	pickup_sound.play()
