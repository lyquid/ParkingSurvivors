extends Enemy

class_name Zombie

const DEFAULT_ZOMBIE_SPEED := 15.0
const DEFAULT_ZOMBIE_HEALTH := 3.0
const DEFAULT_ZOMBIE_DAMAGE := 0.2

func _ready():
	damage = DEFAULT_ZOMBIE_DAMAGE
	health = DEFAULT_ZOMBIE_HEALTH
	speed = DEFAULT_ZOMBIE_SPEED
	damage_label.visible = false
	damage_label_show_timer.wait_time = DAMAGE_LABEL_SHOW_TIMER
	hit_animation.play("walk")
	ia_timer.start()
