extends Node

class_name EnemiesManager

const DEFAULT_SPAWN_TIME := 0.5
const MAX_ENEMIES := 300

onready var player := get_tree().root.get_node("Main/YSort/Player")
onready var enemy_spawner := $EnemySpawner
onready var spawn_timer := $SpawnTimer

var starting_enemies := 10
var enemies_count := 0
# Enemies
enum { BIZKY, SKELETON, ZOMBIE }
var enemy_scene := preload("res://enemies/Enemy.tscn")


func _ready():
	spawn_timer.wait_time = DEFAULT_SPAWN_TIME
	spawn_timer.start()
	# Create starting enemies
	for _i in range(starting_enemies):
		instance_enemy(BIZKY)
	enemies_count = starting_enemies


func instance_enemy(enemy_type):
	var enemy: Enemy
	if enemy_type == BIZKY:
		enemy = enemy_scene.instance()
		assert(enemy)
	else:
		print("Wrong enemy")

	get_tree().root.get_node("Main/YSort").call_deferred("add_child", enemy)
	# Connect enemy's death signal to the manager
	var err := enemy.connect("death", self, "_on_Enemy_death")
	assert(!err)
	enemy_spawner.spawn_enemy(enemy)
	
	enemies_count += 1


func _on_SpawnTimer_timeout():
	if enemies_count < MAX_ENEMIES:
		instance_enemy(BIZKY)


func _on_Enemy_death():
	enemies_count -= 1
