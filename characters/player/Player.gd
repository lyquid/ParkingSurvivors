extends KinematicBody2D

# How fast the player will move (pixels/sec).
export var speed: float = 50.0
export var max_health: float = 100.0
var health: float = 100.0
var health_regen: float = 1.0
var healthbar_length: float = 0.0
# directional vector
var direction: Vector2 = Vector2.ZERO
var facing_left: bool = false

# attack stuff
export var attack_damage: float = 80.0
export var attack_length: float = 50.0


# Called when the node enters the scene tree for the first time.
func _ready():
	healthbar_length = $HealthBar/Inside.rect_size.x
	$Area2D/CollisionShape2D.shape.extents.x = attack_length
	$Area2D.set_transform(Transform2D(0.0, Vector2($Area2D/CollisionShape2D.shape.extents.x, 0.0)))
	update_healthbar()


func _physics_process(_delta):
	direction.x = Input.get_action_strength("move_right") - Input.get_action_strength("move_left")
	direction.y = Input.get_action_strength("move_down") - Input.get_action_strength("move_up")

	# If input is digital, normalize it for diagonal movement
	if abs(direction.x) == 1 and abs(direction.y) == 1:
		direction = direction.normalized()

	if direction.length_squared() > 0:
		$AnimatedSprite.play()
	else:
		$AnimatedSprite.stop()

	var _move_result = move_and_slide(speed * direction)

	# move the area2d to the corresponding side
	if direction.x > 0:
		$Area2D.set_transform(Transform2D(0.0, Vector2($Area2D/CollisionShape2D.shape.extents.x, 0.0)))
		facing_left = false
	elif direction.x < 0:
		$Area2D.set_transform(Transform2D(0.0, Vector2(-$Area2D/CollisionShape2D.shape.extents.x, 0.0)))
		facing_left = true


func _process(delta):
	# sprite flip
	if direction.x != 0:
		$AnimatedSprite.animation = "walk"
		$AnimatedSprite.flip_v = false
		$AnimatedSprite.flip_h = direction.x < 0

	# health update
	var new_health = min(health + health_regen * delta, max_health)
	if new_health != health:
		health = new_health
		update_healthbar()


func update_healthbar():
	$HealthBar/Inside.rect_size.x = healthbar_length * health / max_health


func attack():
	var bodies = $Area2D.get_overlapping_bodies()
	for body in bodies:
		if body.name.find("Skeleton") >= 0:
			# Skeleton hit!
			body.hit(attack_damage)
#			attack_length += 1
#			$Area2D/CollisionShape2D.shape.extents.x = attack_length
#			if facing_left:
#				$Area2D.set_transform(Transform2D(0.0, Vector2(-$Area2D/CollisionShape2D.shape.extents.x, 0.0)))
#			else:
#				$Area2D.set_transform(Transform2D(0.0, Vector2($Area2D/CollisionShape2D.shape.extents.x, 0.0)))


func _on_Timer_timeout():
	attack()
