extends Weapon

const MAX_LENTGH := 200.0

var start := Vector2.ZERO
var control := Vector2.ZERO
var end := Vector2.ZERO
var fly_time := 0.0
var fire_time := 2.0
var burning := false
var rotation_speed := rand_range(1.0, 20.0)

onready var graphics := $WeaponGraphics
onready var flame := $Flame
onready var fire := $DamageArea/Fire
onready var stop_timer := $StopTimer
onready var damage_area := $DamageArea
onready var damage_tick := $DamageArea/DamageTick


func _ready():
	stop_timer.wait_time = fire_time
	start = position
	control = Vector2(
		rand_range(position.x - MAX_LENTGH, position.x + MAX_LENTGH), 	# x axis
		rand_range(position.y, position.y - MAX_LENTGH) 				# y axis
	)
	if control.x < position.x: # throw left
		end = Vector2(
			rand_range(control.x, control.x - MAX_LENTGH),
			rand_range(control.y, control.y + MAX_LENTGH)
		)
	else: # throw right
		end = Vector2(
			rand_range(control.x, control.x + MAX_LENTGH),
			rand_range(control.y, control.y + MAX_LENTGH)
		)


func _process(delta):
	if fly_time < 1.0:
		position = quadratic_bezier(start, control, end, fly_time)
		fly_time += delta
		rotate(delta * rotation_speed)
	elif not burning:
		start_burning()


func setup(damage_in: int) -> Node2D:
	damage = damage_in
	return self


func start_burning():
	damage_area.monitoring = true
	graphics.visible = false
	flame.emitting = false
	fire.emitting = true
	stop_timer.start()
	damage_tick.start()
	burning = true


static func quadratic_bezier(p0: Vector2, p1: Vector2, p2: Vector2, t: float) -> Vector2:
	var q0 := p0.linear_interpolate(p1, t)
	var q1 := p1.linear_interpolate(p2, t)
	var r := q0.linear_interpolate(q1, t)
	return r


func _on_StopTimer_timeout():
	get_tree().queue_delete(self)


func _on_DamageTick_timeout():
	var bodies = damage_area.get_overlapping_bodies()
	for body in bodies:
		body.hit(damage)
