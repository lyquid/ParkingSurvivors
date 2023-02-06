extends Enemy

signal death

const DEFAULT_SKELETON_SPEED := 20.0
const DEFAULT_SKELETON_HEALTH := 2.0
const DEFAULT_SKELETON_DAMAGE := 0.2

# Random number generator
var rng := RandomNumberGenerator.new()
# Movement variables
var last_direction := Vector2(0.0, 1.0)
var bounce_countdown := 0
# Animation variables
var other_animation_playing := false
onready var animated_sprite := $AnimatedSprite
onready var hit_animation := $HitAnimation
onready var collision_shape := $CollisionShape2D
onready var ia_timer := $IATimer
onready var stun_timer := $StunTimer
# damage
const DAMAGE_LABEL_SHOW_TIMER := 0.2
var impact_direction := Vector2.ZERO
var stunned := false
onready var damage_label := $DamageLabel
onready var damage_label_show_timer := $DamageLabel/ShowTimer
onready var damage_label_tween := $DamageLabel/Tween


func _ready():
	damage = DEFAULT_SKELETON_DAMAGE
	health = DEFAULT_SKELETON_HEALTH
	speed = DEFAULT_SKELETON_SPEED
	rng.randomize()
	damage_label.visible = false
	damage_label_show_timer.wait_time = DAMAGE_LABEL_SHOW_TIMER
	arise()


func _physics_process(delta):
	var collision: KinematicCollision2D
	if stunned:
		collision = move_and_collide(impact_direction * delta)
	else:
#		move_and_slide(speed * direction)
#		for i in get_slide_count():
#			collision = get_slide_collision(i)
#			if collision != null:
#				if collision.collider.name == "Player":
#					player.hit(damage)
##				elif "Skeleton" in collision.collider.name:
##					direction = direction.rotated(rng.randf_range(PI / 4.0, PI / 2.0))
##					bounce_countdown = 1
#				else:
#					direction = direction.rotated(rng.randf_range(PI / 4.0, PI / 2.0))
#					bounce_countdown = rng.randi_range(2, 4)

		# old movement
		collision = move_and_collide(speed * direction * delta)
		if collision != null:
			#print("I collided with ", collision.collider.name)
			if collision.collider.name == "Player":
				player.hit(damage)
			else:
				direction = direction.rotated(rng.randf_range(PI / 4.0, PI / 2.0))
				bounce_countdown = rng.randi_range(2, 4)

		# Animate skeleton based on direction
		if not other_animation_playing:
			animates_monster(direction)


func get_animation_direction(direction_in: Vector2) -> String:
	var norm_direction := direction_in.normalized()
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
		# Play the walk animation
		animated_sprite.play(get_animation_direction(last_direction) + "_walk")
	else:
		# Choose idle animation based on last movement direction and play it
		animated_sprite.play(get_animation_direction(last_direction) + "_idle")


func arise():
	other_animation_playing = true
	animated_sprite.play("birth")


func _on_AnimatedSprite_animation_finished():
	if animated_sprite.animation == "birth":
		animated_sprite.animation = "down_idle"
		ia_timer.start()
	elif animated_sprite.animation == "death":
		get_tree().queue_delete(self)
	other_animation_playing = false


func hit(damage_in: float, impact: Vector2 = Vector2.ZERO, stun: bool = false):
	stunned = stun
	if stunned:
		stun_timer.start()
		animated_sprite.stop()
	impact_direction = impact
	health -= damage_in
	if health > 0.0:
		hit_animation.play("hit")
	else:
		ia_timer.stop()
		direction = Vector2.ZERO
		other_animation_playing = true
		animated_sprite.play("death")
		collision_shape.call_deferred("set_disabled", true)
		emit_signal("death")

	damage_label.text = damage_in as String
	damage_label.visible = true
	damage_label_show_timer.start()
#	damage_label_tween.interpolate_property(
#		damage_label,
#		"rect_rotation",
#		0,
#		90,
#		DAMAGE_LABEL_SHOW_TIMER,
#		Tween.TRANS_LINEAR,
#		Tween.EASE_OUT
#	)


func _on_StunTimer_timeout():
	if health > 0.0:
		stunned = false
		animates_monster(direction)


func _on_IATimer_timeout():
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


func _on_ShowTimer_timeout():
	damage_label.visible = false
