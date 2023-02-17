extends Weapon

const DEFAULT_COOLDOWN_TIME := 1.0
const DEFAULT_DAMAGE := 1
const DEFAULT_KINEMATIC_FORCE := 2.0
const DEFAULT_SPEED := 100.0
#const DEFAULT_PIERCING := 0

var molotov_scene := preload("res://weapons/molotov/Molotov.tscn")
onready var main := get_tree().root.get_node("Main")
onready var cooldown_timer := $Cooldown
var throw_direction := Vector2.ZERO
var speed := DEFAULT_SPEED


func _ready():
	damage = DEFAULT_DAMAGE
	kinematic_force = DEFAULT_KINEMATIC_FORCE
	cooldown = DEFAULT_COOLDOWN_TIME
	cooldown_timer.wait_time = cooldown
	cooldown_timer.start()


func attack():
	var molotov = molotov_scene.instance().setup(damage)
	molotov.set_position(player.position)
	main.call_deferred("add_child", molotov)


func _on_Cooldown_timeout():
	attack()
