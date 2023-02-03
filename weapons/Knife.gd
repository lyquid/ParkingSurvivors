extends Weapon

const DISABLED_TIMEOUT := 1.5

var speed: float
var direction := Vector2.ZERO
var tilemap
onready var graphics := $WeaponGraphics
onready var disable_timer := $DisableTimer

func _ready():
	tilemap = get_tree().root.get_node("Main/MapGenerator/Terrain")
	disable_timer.wait_time = DISABLED_TIMEOUT
	disable_timer.start()


func setup(damage_in: float, kinematic_force_in: float, speed_in: float, direction_in: Vector2) -> Node2D:
	damage = damage_in
	kinematic_force = kinematic_force_in
	speed = speed_in
	direction = direction_in
	return self


func _process(delta):
	position = position + speed * delta * direction


func _on_AttackArea_body_entered(body):
	if body.name == "Player":
		return

	if body.name == "Terrain":
		var cell_coord = tilemap.world_to_map(position)
		var cell_type_id = tilemap.get_cellv(cell_coord)
		if cell_type_id == tilemap.tile_set.find_tile_by_name("Water"):
			print("waterrrrrrrrrrrrrrrrrrrrrrrrrrrr")
			return

	if body.name.find("Skeleton") >= 0:
#		var impact_direction := Vector2(kinematic_force, 0.0)
#		if player.is_facing_left():
#			impact_direction = Vector2(-kinematic_force, 0.0)
		body.hit(damage)
	
	# Stop the movement and delete
	direction = Vector2.ZERO
	get_tree().queue_delete(self)


func _on_DisableTimer_timeout():
	get_tree().queue_delete(self)
