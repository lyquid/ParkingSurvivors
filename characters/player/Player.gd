extends KinematicBody2D

# How fast the player will move (pixels/sec).
export var speed: float = 50.0
export var max_health: float = 100.0
var health: float = 100.0
var health_regen: float = 1.0
var healthbar_length: float
# directional vector
var velocity: Vector2

# attack stuff
export var attack_damage: float = 100.0
export var attack_length: float = 50.0


# Called when the node enters the scene tree for the first time.
func _ready():
	healthbar_length = $HealthBar/Inside.rect_size.x
	update_healthbar()


func _physics_process(delta):
	# velocity = Vector2.ZERO

	# if Input.is_action_pressed("move_right"):
	# 	velocity.x = 1
	# if Input.is_action_pressed("move_left"):
	# 	velocity.x = -1
	# if Input.is_action_pressed("move_up"):
	# 	velocity.y = -1
	# if Input.is_action_pressed("move_down"):
	# 	velocity.y = 1
	velocity.x = Input.get_action_strength("move_right") - Input.get_action_strength("move_left")
	velocity.y = Input.get_action_strength("move_down") - Input.get_action_strength("move_up")

	# If input is digital, normalize it for diagonal movement
	if abs(velocity.x) == 1 and abs(velocity.y) == 1:
		velocity = velocity.normalized()

	if velocity.length_squared() > 0:
		$AnimatedSprite.play()
	else:
		$AnimatedSprite.stop()

	var _move_result = move_and_collide(speed * velocity * delta)
	
	# raycast for attacking
	if velocity != Vector2.ZERO:
		$RayCast2D.cast_to = velocity.normalized() * attack_length


func _process(delta):
	# sprite flip
	if velocity.x != 0:
		$AnimatedSprite.animation = "walk"
		$AnimatedSprite.flip_v = false
		$AnimatedSprite.flip_h = velocity.x < 0

	# health update
	var new_health = min(health + health_regen * delta, max_health)
	if new_health != health:
		health = new_health
		update_healthbar()


func update_healthbar():
	$HealthBar/Inside.rect_size.x = healthbar_length * health / max_health


func attack():
	var target = $RayCast2D.get_collider()
	if target != null:
		if target.name.find("Skeleton") >= 0:
			# Skeleton hit!
			target.hit(attack_damage)


func _on_Timer_timeout():
	attack()
