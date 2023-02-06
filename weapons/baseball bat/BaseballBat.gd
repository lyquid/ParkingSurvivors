extends Weapon

const DEFAULT_COOLDOWN_TIME := 1.0
const DEFAULT_DAMAGE := 2.0
const DEFAULT_KINEMATIC_FOCE := 25.0
const DEFAULT_ATTACK_LENGTH := 50.0

var attack_length := DEFAULT_ATTACK_LENGTH
onready var cooldown_timer := $Cooldown
onready var attack_area := $AttackArea
onready var attack_shape := $AttackArea/CollisionShape2D
onready var graphics := $WeaponGraphics


func _ready():
	attack_shape.shape.extents.x = attack_length
	attack_area.set_transform(Transform2D(0.0, Vector2(attack_shape.shape.extents.x, 0.0)))
	graphics.set_size(Vector2(attack_length * 2.0, 5.0))
	damage = DEFAULT_DAMAGE
	kinematic_force = DEFAULT_KINEMATIC_FOCE
	cooldown = DEFAULT_COOLDOWN_TIME
	cooldown_timer.wait_time = cooldown
	cooldown_timer.start()


func _process(_delta):
	if player.is_facing_left():
		attack_area.set_transform(Transform2D(0.0, Vector2(-attack_shape.shape.extents.x, 0.0)))
	else:
		attack_area.set_transform(Transform2D(0.0, Vector2(attack_shape.shape.extents.x, 0.0)))


func attack():
	var bodies = attack_area.get_overlapping_bodies()
	for body in bodies:
		if body.name.find("Skeleton") >= 0:
			var impact_direction := Vector2(kinematic_force, 0.0)
			if player.is_facing_left():
				impact_direction = Vector2(-kinematic_force, 0.0)
			body.hit(damage, impact_direction, true)
			
	$WeaponGraphics/ShowTimer.start()
	
	if player.is_facing_left():
		graphics.set_position(Vector2(-graphics.get_rect().size.x, 0.0))
	else:
		graphics.set_position(Vector2.ZERO)
	graphics.visible = true


func _on_Cooldown_timeout():
	attack()


func _on_ShowTimer_timeout():
	graphics.visible = false
