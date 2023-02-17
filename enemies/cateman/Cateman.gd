extends Enemy

class_name Cateman

const DEFAULT_CATEMAN_SPEED := 15.0
const DEFAULT_CATEMAN_HEALTH := 4.0
const DEFAULT_CATEMAN_DAMAGE := 0.3

func _ready():
	damage = DEFAULT_CATEMAN_DAMAGE
	health = DEFAULT_CATEMAN_HEALTH
	speed = DEFAULT_CATEMAN_SPEED
	damage_label.visible = false
	damage_label_show_timer.wait_time = DAMAGE_LABEL_SHOW_TIMER
	hit_animation.play("walk")
	animated_sprite.play("stand")
	ia_timer.start()

func _on_StunTimer_timeout():
	if health > 0.0:
		stunned = false
		hit_animation.play("walk")
		animated_sprite.play("stand")
