extends Weapon

const DEFAULT_COOLDOWN_TIME := 0.75
const DEFAULT_DAMAGE := 50.0
const DEFAULT_KINEMATIC_FORCE := 10.0
const DEFAULT_SPEED := 300.0
const DEFAULT_PIERCING := 3

var knife_scene := preload("res://weapons/knife/Knife.tscn")
onready var main := get_tree().root.get_node("Main")
onready var cooldown_timer := $Cooldown
var throw_direction := Vector2.ZERO
var speed := DEFAULT_SPEED
var piercing_power := DEFAULT_PIERCING


func _ready():
	damage = DEFAULT_DAMAGE
	kinematic_force = DEFAULT_KINEMATIC_FORCE
	cooldown = DEFAULT_COOLDOWN_TIME
	cooldown_timer.wait_time = cooldown
	cooldown_timer.start()


func attack():
	throw_direction = player.get_last_moving_direction()
	var knife = knife_scene.instance().setup(damage, kinematic_force, speed, piercing_power, throw_direction)
	knife.set_position(player.position)
	main.call_deferred("add_child", knife)


func _on_Cooldown_timeout():
	attack()
