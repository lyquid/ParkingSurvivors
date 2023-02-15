extends Weapon

class_name Chain

const DEFAULT_COOLDOWN_TIME := 4.0
const DEFAULT_DAMAGE := 1
const DEFAULT_KINEMATIC_FORCE := 25.0
const DEFAULT_ATTACK_DURATION := 5.0
const DEFAULT_ANGULAR_SPEED := 5.0

onready var cooldown_timer := $Cooldown
onready var attack_timer := $AttackTimer
onready var attack_area := $AttackArea
onready var attack_collision := $AttackArea/CollisionShape2D
onready var weapon_graphics := $AttackArea/Sprite
var angular_speed := DEFAULT_ANGULAR_SPEED
var attacking := false

func _ready():
	damage = DEFAULT_DAMAGE
	kinematic_force = DEFAULT_KINEMATIC_FORCE
	cooldown = DEFAULT_COOLDOWN_TIME
	cooldown_timer.wait_time = cooldown
	cooldown_timer.start()
	attack_timer.wait_time = DEFAULT_ATTACK_DURATION


func _process(delta):
	if attacking:
		attack_area.rotate(angular_speed * delta)


func _on_Cooldown_timeout():
	# attack time!
	attacking = true
	attack_timer.start()
	attack_collision.disabled = false
	weapon_graphics.show()


func _on_AttackTimer_timeout():
	# stop attacking!
	attacking = false
	attack_collision.disabled = true
	attack_area.rotation = 0.0
	weapon_graphics.hide()
	cooldown_timer.start()


func _on_AttackArea_body_entered(body):
	# an enemy has entered the area
	var impact_direction: Vector2 = -kinematic_force * (player.position - body.position).normalized()
	body.hit(damage, impact_direction, true)
