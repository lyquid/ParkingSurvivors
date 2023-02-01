extends Path2D

# Nodes references
var player
var tilemap
#var tree_tilemap

# Spawner variables
export var max_skeletons: int = 100
export var start_skeletons: int = 5
var skeleton_count := 0
var skeleton_scene := preload("res://characters/enemies/skeleton/Skeleton.tscn")

# Random number generator
var rng = RandomNumberGenerator.new()


# Called when the node enters the scene tree for the first time.
func _ready():
	# player reference
	player = get_tree().root.get_node("Main/Player")
	# Get tilemaps references
	tilemap = get_tree().root.get_node("Main/MapGenerator/Terrain")
#	tree_tilemap = get_tree().root.get_node("Main/Tree TileMap")
	# Initialize random number generator
	rng.randomize()
	# Create skeletons
	for _i in range(start_skeletons):
		instance_skeleton()
	skeleton_count = start_skeletons


func instance_skeleton():
	# Instance the skeleton scene and add it to the scene tree
	var skeleton = skeleton_scene.instance()
	get_tree().root.get_node("Main").call_deferred("add_child", skeleton)
	# Connect Skeleton's death signal to the spawner
	skeleton.connect("death", self, "_on_Skeleton_death")
	 # Choose a location on Path2D.
	var enemy_spawn_location = get_node("EnemySpawnLocation")
	# Check if it's a valid position
	var valid_position = false
	while not valid_position:
		enemy_spawn_location.offset = randi()
		valid_position = test_position(enemy_spawn_location.position + player.position)
	skeleton.position = enemy_spawn_location.position + player.position
	# Play skeleton's birth animation
	skeleton.arise()


func test_position(position: Vector2):
	# Check if the cell type in this position is grass or sand
	var cell_coord = tilemap.world_to_map(position)
	var cell_type_id = tilemap.get_cellv(cell_coord)
	var grass_or_sand = (cell_type_id == tilemap.tile_set.find_tile_by_name("Grass")) or (cell_type_id == tilemap.tile_set.find_tile_by_name("Sand"))
	# Check if there's a tree in this position
#	cell_coord = tree_tilemap.world_to_map(position)
#	cell_type_id = tree_tilemap.get_cellv(cell_coord)
	var no_trees = (cell_type_id != tilemap.tile_set.find_tile_by_name("Tree"))
	# If the two conditions are true, the position is valid
	return grass_or_sand and no_trees


func _on_SpawnTimer_timeout():
	# Every second, check if we need to instantiate a skeleton
	if skeleton_count < max_skeletons:
		instance_skeleton()
		skeleton_count += 1


func _on_Skeleton_death():
	skeleton_count -= 1
