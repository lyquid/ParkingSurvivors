extends Node

class_name EnemiesManager

const DEFAULT_SPAWN_TIME := 1.0
const MAX_ENEMIES := 500

onready var player := get_tree().root.get_node("Main/Player")
onready var enemy_spawner := $EnemySpawner
onready var spawn_timer := $SpawnTimer

var starting_enemies := 12
var enemies_count := 0
# Enemies
enum { SKELETON, ZOMBIE }
var skeleton_scene := preload("res://enemies/skeleton/Skeleton.tscn")


func _ready():
	spawn_timer.wait_time = DEFAULT_SPAWN_TIME
	spawn_timer.start()
	# Create starting skeletons
	for _i in range(starting_enemies):
		instance_enemy(SKELETON)
	enemies_count = starting_enemies


func instance_enemy(enemy_type):
	var enemy: Enemy
	if enemy_type == SKELETON:
		enemy = skeleton_scene.instance()
		assert(enemy)
	else:
		print("Wrong enemy")

	get_tree().root.get_node("Main").call_deferred("add_child", enemy)
	# Connect Skeleton's death signal to the manager
	var err := enemy.connect("death", self, "_on_Enemy_death")
	assert(!err)
	enemy_spawner.spawn_enemy(enemy)
	
	enemies_count += 1


func _on_SpawnTimer_timeout():
	if enemies_count < MAX_ENEMIES:
		instance_enemy(SKELETON)


func _on_Enemy_death():
	enemies_count -= 1
