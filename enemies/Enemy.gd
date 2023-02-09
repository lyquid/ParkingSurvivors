extends KinematicBody2D

class_name Enemy

signal death

const DEFAULT_SKELETON_SPEED := 20.0
const DEFAULT_SKELETON_HEALTH := 2.0
const DEFAULT_SKELETON_DAMAGE := 0.2

var damage: float
var direction := Vector2.ZERO
var last_direction := Vector2(0.0, 1.0)
var health: float
var speed: float
# damage
const DAMAGE_LABEL_SHOW_TIMER := 0.3
var impact_direction := Vector2.ZERO
var stunned := false
onready var damage_label := $DamageLabel
onready var damage_label_show_timer := $DamageLabel/ShowTimer
onready var damage_label_tween := $DamageLabel/Tween
# Animation variables
var other_animation_playing := false
onready var animated_sprite := $AnimatedSprite
onready var hit_animation := $HitAnimation
onready var collision_shape := $CollisionShape2D
onready var ia_timer := $IATimer
onready var stun_timer := $StunTimer

onready var player := get_tree().root.get_node("Main/YSort/Player")


func _ready():
	damage = DEFAULT_SKELETON_DAMAGE
	health = DEFAULT_SKELETON_HEALTH
	speed = DEFAULT_SKELETON_SPEED
	damage_label.visible = false
	damage_label_show_timer.wait_time = DAMAGE_LABEL_SHOW_TIMER
	ia_timer.start()


func _physics_process(delta):
	var collision: KinematicCollision2D
	if stunned:
		collision = move_and_collide(impact_direction * delta)
	else:
		move_and_slide(speed * direction)
		for i in get_slide_count():
			collision = get_slide_collision(i)
			if collision != null && collision.collider.name == "Player":
				player.hit(damage)

		# old movement
#		collision = move_and_collide(speed * direction * delta)
#		if collision != null:
#			#print("I collided with ", collision.collider.name)
#			if collision.collider.name == "Player":
#				player.hit(damage)

		# Animate skeleton based on direction
#		if not other_animation_playing:
#			animates_monster(direction)
			
		if direction != Vector2.ZERO:
			last_direction = direction


func _process(_delta):
	# sprite flip
	if direction.x != 0.0:
#		animated_sprite.flip_v = false
		animated_sprite.flip_h = direction.x < 0.0


#func animates_monster(direction_in: Vector2):
#	animated_sprite.play("walk")
#	if direction_in != Vector2.ZERO:
#		last_direction = direction_in


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
#		animated_sprite.play("death")
		collision_shape.call_deferred("set_disabled", true)
		get_tree().queue_delete(self) # maybe this after some dead animation
		emit_signal("death")

	damage_label.text = damage_in as String
	damage_label.visible = true
	damage_label_show_timer.start()
	damage_label_tween.interpolate_property(
		damage_label,
		"rect_scale",
		damage_label.rect_scale * 0.1,
		damage_label.rect_scale * 1,
		DAMAGE_LABEL_SHOW_TIMER,
		Tween.TRANS_BOUNCE,
		Tween.EASE_OUT
	)
	damage_label_tween.start()


func _on_IATimer_timeout():
	var player_relative_position = player.position - position
	direction = player_relative_position.normalized()


func _on_ShowTimer_timeout():
	damage_label.visible = false


func _on_StunTimer_timeout():
	if health > 0.0:
		stunned = false
#		animates_monster(direction)
