extends KinematicBody2D

# Node references
var player

# Random number generator
var rng = RandomNumberGenerator.new()

# Movement variables
export var speed = 40
var velocity: Vector2
var last_direction = Vector2(0, 1)
var bounce_countdown = 0

# Animation variables
var other_animation_playing = false


# Called when the node enters the scene tree for the first time.
func _ready():
	# player reference
	player = get_tree().root.get_node("Main/Player")
	rng.randomize()


func _physics_process(delta):
	var collision = move_and_collide(speed * velocity * delta)

	if collision != null and collision.collider.name != "Player" and collision.collider.name != "Skeleton":
		velocity = velocity.rotated(rng.randf_range(PI / 4.0, PI / 2.0))
		bounce_countdown = rng.randi_range(2, 4)
		
	# Animate skeleton based on direction
	if not other_animation_playing:
		animates_monster(velocity)


func _on_Timer_timeout():
	# Calculate the position of the player relative to the skeleton
	var player_relative_position = player.position - position

	velocity = player_relative_position.normalized()

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


func get_animation_direction(direction: Vector2):
	var norm_direction = direction.normalized()
	if norm_direction.y >= 0.707:
		return "down"
	elif norm_direction.y <= -0.707:
		return "up"
	elif norm_direction.x <= -0.707:
		return "left"
	elif norm_direction.x >= 0.707:
		return "right"
	return "down"


func animates_monster(direction: Vector2):
	if velocity != Vector2.ZERO:
		last_direction = direction
		
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
		$Timer.start()
	other_animation_playing = false
