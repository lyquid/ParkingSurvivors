extends Node

class_name EnemiesManager

const DEFAULT_SPAWN_TIME := 0.2
const MAX_ENEMIES := 300

onready var player := get_tree().root.get_node("Main/YSort/Player")
onready var enemy_spawner := $EnemySpawner
onready var spawn_timer := $SpawnTimer

var rng := RandomNumberGenerator.new()

var starting_enemies := 10
var enemies_count := 0
# Enemies
enum { DRAGON, BIZKY, ZOMBIE }
var dragon_scene := preload("res://enemies/dragon/Dragon.tscn")
var bizky_scene := preload("res://enemies/bizky/Bizky.tscn")
var zombie_scene := preload("res://enemies/zombie/Zombie.tscn")


func _ready():
	spawn_timer.wait_time = DEFAULT_SPAWN_TIME
	spawn_timer.start()
	# Create starting enemies, no dragon
	for _i in range(starting_enemies):
		instance_enemy(rng.randi_range(1, 2))
	enemies_count = starting_enemies


func instance_enemy(enemy_type):
	var enemy: Enemy
	match enemy_type:
		DRAGON:
			enemy = dragon_scene.instance()
			assert(enemy)
		BIZKY:
			enemy = bizky_scene.instance()
			assert(enemy)
		ZOMBIE:
			enemy = zombie_scene.instance()
			assert(enemy)
		_:
			print("Wrong enemy")

	get_tree().root.get_node("Main/YSort").call_deferred("add_child", enemy)
	# Connect enemy's death signal to the manager
	var err := enemy.connect("death", self, "_on_Enemy_death")
	assert(!err)
	enemy_spawner.spawn_enemy(enemy)
	
	enemies_count += 1


func _on_SpawnTimer_timeout():
	if enemies_count < MAX_ENEMIES:
		var spawn_dragon := rng.randi_range(0, 50) == 0
		if spawn_dragon:
			instance_enemy(DRAGON)
		else:
			instance_enemy(rng.randi_range(1, 2))


func _on_Enemy_death():
	enemies_count -= 1
