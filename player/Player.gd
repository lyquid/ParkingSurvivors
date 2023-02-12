extends KinematicBody2D

signal experience_changed(value)

var level := 1
var experience := 0
var experience_until_new_level := 0
onready var leveling_manager := get_tree().root.get_node("Main/LevelingManager")
var speed := 50.0
var max_health := 100.0
var health := 100.0
var health_regen := 1.0
var healthbar_length := 0.0
onready var healthbar := $HealthBar/Inside
# graphics
onready var animated_sprite := $AnimatedSprite
onready var animation_player := $AnimationPlayer
onready var hit_particles := $HitParticles
onready var hit_particles_timer := $HitParticles/EmissionTimer
# directional vector
var direction := Vector2.ZERO
var last_moving_direction := Vector2(1.0, 0.0)
var facing_left := false
# camera
export var min_zoom := 0.5
export var max_zoom := 2000.0
export var zoom_factor := 0.1
# Duration of the zoom's tween animation.
export var zoom_duration := 0.2
# The camera's target zoom level.
var zoom_level := 1.0 setget set_zoom_level
onready var camera := $Camera2D
onready var tween := $Camera2D/Tween


func _ready():
	experience_until_new_level = leveling_manager.new_level(level)
	healthbar_length = healthbar.rect_size.x
	update_healthbar()


func _physics_process(_delta):
	direction.x = Input.get_action_strength("move_right") - Input.get_action_strength("move_left")
	direction.y = Input.get_action_strength("move_down") - Input.get_action_strength("move_up")
	# If input is digital, normalize it for diagonal movement
	if abs(direction.x) == 1.0 and abs(direction.y) == 1.0:
		direction = direction.normalized()

	if direction.length_squared() > 0.0:
		animated_sprite.play()
		last_moving_direction = direction
	else:
		animated_sprite.stop()

	var _move_result := move_and_slide(speed * direction)

	if direction.x > 0.0:
		facing_left = false
	elif direction.x < 0.0:
		facing_left = true


func _process(delta):
	# sprite flip
	if direction.x != 0.0:
		animated_sprite.animation = "walk"
		animated_sprite.flip_v = false
		animated_sprite.flip_h = direction.x < 0.0
	# health update
	var new_health = min(health + health_regen * delta, max_health)
	if new_health != health:
		health = new_health
		update_healthbar()


func add_experience(how_much: int):
	experience += how_much
	if experience >= experience_until_new_level:
		var residue := experience - experience_until_new_level
		level += 1
		experience_until_new_level = leveling_manager.new_level(level)
		experience = residue
		print("level up: " + level as String + " xp until new level: " + experience_until_new_level as String)

	emit_signal("experience_changed", experience * 100.0 / experience_until_new_level)


func update_healthbar():
	healthbar.rect_size.x = healthbar_length * health / max_health


func get_last_moving_direction() -> Vector2:
	return last_moving_direction


func hit(damage: float):
	health -= damage
	update_healthbar()
	animation_player.play("hit")
	hit_particles.emitting = true
	hit_particles_timer.start()
	if health <= 0.0:
		# die!
		pass


func is_facing_left() -> bool:
	return facing_left


func _unhandled_input(event):
	if event.is_action_pressed("zoom_in"):
		# Inside a given class, we need to either write `self._zoom_level = ...` or explicitly
		# call the setter function to use it.
		set_zoom_level(zoom_level - zoom_factor)
	if event.is_action_pressed("zoom_out"):
		set_zoom_level(zoom_level + zoom_factor)


func set_zoom_level(value: float):
	# We limit the value between `min_zoom` and `max_zoom`
	zoom_level = clamp(value, min_zoom, max_zoom)
	# Then, we ask the tween node to animate the camera's `zoom` property from its current value
	# to the target zoom level.
	tween.interpolate_property(
		camera,
		"zoom",
		camera.zoom,
		Vector2(zoom_level, zoom_level),
		zoom_duration,
		tween.TRANS_SINE,
		# Easing out means we start fast and slow down as we reach the target value.
		tween.EASE_OUT
	)
	tween.start()


func _on_EmissionTimer_timeout():
	hit_particles.emitting = false


func _on_PickupArea_area_entered(area):
	area.go_to_player()
