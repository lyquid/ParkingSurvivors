extends Enemy

class_name Dragon

const DEFAULT_DRAGON_SPEED := 10.0
const DEFAULT_DRAGON_HEALTH := 5.0
const DEFAULT_DRAGON_DAMAGE := 0.3

func _ready():
	damage = DEFAULT_DRAGON_DAMAGE
	health = DEFAULT_DRAGON_HEALTH
	speed = DEFAULT_DRAGON_SPEED
	damage_label.visible = false
	damage_label_show_timer.wait_time = DAMAGE_LABEL_SHOW_TIMER
	hit_animation.play("walk")
	ia_timer.start()
