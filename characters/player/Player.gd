extends KinematicBody2D

# How fast the player will move (pixels/sec).
export var speed := 50.0
export var max_health := 100.0
var health := 100.0
var health_regen := 1.0
var healthbar_length := 0.0
# directional vector
var direction := Vector2.ZERO
var facing_left := false

# attack stuff
export var attack_damage := 80.0
export var attack_length := 50.0
export var attack_kinematic_force := 25.0


# Called when the node enters the scene tree for the first time.
func _ready():
	healthbar_length = $HealthBar/Inside.rect_size.x
	$AttackArea/CollisionShape2D.shape.extents.x = attack_length
	$AttackArea.set_transform(Transform2D(0.0, Vector2($AttackArea/CollisionShape2D.shape.extents.x, 0.0)))
	$Weapon.set_size(Vector2(attack_length * 2.0, 5.0))
	update_healthbar()


func _physics_process(_delta):
	direction.x = Input.get_action_strength("move_right") - Input.get_action_strength("move_left")
	direction.y = Input.get_action_strength("move_down") - Input.get_action_strength("move_up")

	# If input is digital, normalize it for diagonal movement
	if abs(direction.x) == 1.0 and abs(direction.y) == 1.0:
		direction = direction.normalized()

	if direction.length_squared() > 0.0:
		$AnimatedSprite.play()
	else:
		$AnimatedSprite.stop()

	var _move_result := move_and_slide(speed * direction)

	# move the area2d to the corresponding side
	if direction.x > 0.0:
		$AttackArea.set_transform(Transform2D(0.0, Vector2($AttackArea/CollisionShape2D.shape.extents.x, 0.0)))
		facing_left = false
	elif direction.x < 0.0:
		$AttackArea.set_transform(Transform2D(0.0, Vector2(-$AttackArea/CollisionShape2D.shape.extents.x, 0.0)))
		facing_left = true


func _process(delta):
	# sprite flip
	if direction.x != 0.0:
		$AnimatedSprite.animation = "walk"
		$AnimatedSprite.flip_v = false
		$AnimatedSprite.flip_h = direction.x < 0.0
	# health update
	var new_health = min(health + health_regen * delta, max_health)
	if new_health != health:
		health = new_health
		update_healthbar()


func update_healthbar():
	$HealthBar/Inside.rect_size.x = healthbar_length * health / max_health


func attack():
	var bodies = $AttackArea.get_overlapping_bodies()
	for body in bodies:
		if body.name.find("Skeleton") >= 0:
			# Skeleton hit!
			var impact_direction: Vector2
			if facing_left:
				impact_direction = Vector2(-attack_kinematic_force, 0.0)
			else:
				impact_direction = Vector2(attack_kinematic_force, 0.0)
			body.hit(attack_damage, impact_direction)
#			attack_length += 1
#			$Area2D/CollisionShape2D.shape.extents.x = attack_length
#			if facing_left:
#				$Area2D.set_transform(Transform2D(0.0, Vector2(-$Area2D/CollisionShape2D.shape.extents.x, 0.0)))
#			else:
#				$Area2D.set_transform(Transform2D(0.0, Vector2($Area2D/CollisionShape2D.shape.extents.x, 0.0)))
	$Weapon/ShowTimer.start()
	if facing_left:
		$Weapon.set_position(Vector2(-$Weapon.get_rect().size.x, 0.0))
	else:
		$Weapon.set_position(Vector2.ZERO)
	$Weapon.visible = true


func _on_Timer_timeout():
	attack()


func _on_ShowTimer_timeout():
	$Weapon.visible = false


func hit(damage):
	health -= damage
	update_healthbar()
	$AnimationPlayer.play("hit")
	$HitParticles.emitting = true
	if health <= 0.0:
		# die!
		pass
