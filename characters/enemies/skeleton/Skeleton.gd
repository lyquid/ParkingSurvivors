extends KinematicBody2D

signal death

# Node references
var player: Node2D

# Random number generator
var rng := RandomNumberGenerator.new()

# Movement variables
export var speed := 20.0
var direction := Vector2.ZERO
var last_direction := Vector2(0.0, 1.0)
var bounce_countdown := 0

# Animation variables
var other_animation_playing := false

# health and damage
export var health := 100.0
export var damage := 0.2
var impact_direction := Vector2.ZERO
var stunned := false


# Called when the node enters the scene tree for the first time.
func _ready():
	# player reference
	player = get_tree().root.get_node("Main/Player")
	rng.randomize()


func _physics_process(delta):
	var collision: KinematicCollision2D
	if stunned:
		collision = move_and_collide(impact_direction * delta)
	else:

		collision = move_and_collide(speed * direction * delta)

		if collision != null:
			if collision.collider.name == "Player":
				player.hit(damage)
			elif collision.collider.name != "Skeleton":
				direction = direction.rotated(rng.randf_range(PI / 4.0, PI / 2.0))
				bounce_countdown = rng.randi_range(2, 4)

	#	if collision != null and collision.collider.name != "Player" and collision.collider.name != "Skeleton":
	#		direction = direction.rotated(rng.randf_range(PI / 4.0, PI / 2.0))
	#		bounce_countdown = rng.randi_range(2, 4)

		# Animate skeleton based on direction
		if not other_animation_playing:
			animates_monster(direction)


func _on_Timer_timeout():
	# Calculate the position of the player relative to the skeleton
	var player_relative_position = player.position - position

	direction = player_relative_position.normalized()

#	if player_relative_position.length() <= 16:
#		# If player is near, don't move but turn toward it
#		direction = Vector2.ZERO
#		last_direction = player_relative_position.normalized()
#	elif player_relative_position.length() <= 100 and bounce_countdown == 0:
#		# If player is within range, move toward it
#		direction = player_relative_position.normalized()
#
	# Update bounce countdown
	if bounce_countdown > 0:
		bounce_countdown = bounce_countdown - 1


func get_animation_direction(direction_in: Vector2):
	var norm_direction = direction_in.normalized()
	if norm_direction.y >= 0.707:
		return "down"
	elif norm_direction.y <= -0.707:
		return "up"
	elif norm_direction.x <= -0.707:
		return "left"
	elif norm_direction.x >= 0.707:
		return "right"
	return "down"


func animates_monster(direction_in: Vector2):
	if direction_in != Vector2.ZERO:
		last_direction = direction_in

		# Choose walk animation based on movement direction
		var animation = get_animation_direction(last_direction) + "_walk"

		# Play the walk animation
		$AnimatedSprite.play(animation)
	else:
		# Choose idle animation based on last movement direction and play it
		var animation = get_animation_direction(last_direction) + "_idle"
		$AnimatedSprite.play(animation)


func arise():
	other_animation_playing = true
	$AnimatedSprite.play("birth")


func _on_AnimatedSprite_animation_finished():
	if $AnimatedSprite.animation == "birth":
		$AnimatedSprite.animation = "down_idle"
		$IATimer.start()
	elif $AnimatedSprite.animation == "death":
		get_tree().queue_delete(self)
	other_animation_playing = false


func hit(damage_in: float, impact: Vector2):
	stunned = true
	$StunTimer.start()
	$AnimatedSprite.stop()
	impact_direction = impact
	health -= damage_in
	if health > 0.0:
		$AnimationPlayer.play("hit")
	else:
		$IATimer.stop()
		direction = Vector2.ZERO
		# The set_process() function is used to enable/disable the _process()
		# function call at each frame. We disable it, to prevent the regeneration of skeleton’s health.
		#set_process(false)
		other_animation_playing = true
		$AnimatedSprite.play("death")
		$CollisionShape2D.disabled = true

		emit_signal("death")


func _on_StunTimer_timeout():
	if health > 0.0:
		stunned = false
		animates_monster(direction)
