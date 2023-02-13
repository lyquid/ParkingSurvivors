extends Enemy

class_name Bizky

const DEFAULT_BIZKY_SPEED := 20.0
const DEFAULT_BIZKY_HEALTH := 2.0
const DEFAULT_BIZKY_DAMAGE := 0.2

func _ready():
	damage = DEFAULT_BIZKY_DAMAGE
	health = DEFAULT_BIZKY_HEALTH
	speed = DEFAULT_BIZKY_SPEED
	damage_label.visible = false
	damage_label_show_timer.wait_time = DAMAGE_LABEL_SHOW_TIMER
	hit_animation.play("walk")
	ia_timer.start()
