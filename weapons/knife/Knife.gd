extends Weapon

const DISABLED_TIMEOUT := 1.5

var speed: float
var direction: Vector2
var piercing_power: float
var tilemap: TileMap
onready var graphics := $WeaponGraphics
onready var disable_timer := $DisableTimer

func _ready():
	tilemap = get_tree().root.get_node("Main/MapGenerator/Terrain")
	disable_timer.wait_time = DISABLED_TIMEOUT
	disable_timer.start()


func setup(damage_in: float, kinematic_force_in: float, speed_in: float, piercing: float, direction_in: Vector2) -> Node2D:
	damage = damage_in
	kinematic_force = kinematic_force_in
	speed = speed_in
	piercing_power = piercing
	direction = direction_in
	return self


func _process(delta):
	position = position + speed * delta * direction


func _on_AttackArea_body_entered(body):
	var impact_direction := Vector2(kinematic_force, 0.0)
	if player.is_facing_left():
		impact_direction = Vector2(-kinematic_force, 0.0)
	body.hit(damage, impact_direction, true)
	piercing_power -= 1
	if piercing_power:
		return
	# Stop the movement and delete
	direction = Vector2.ZERO
	get_tree().queue_delete(self)


func _on_DisableTimer_timeout():
	get_tree().queue_delete(self)
