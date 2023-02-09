extends Path2D

# Nodes references
onready var player := get_tree().root.get_node("Main/YSort/Player")
onready var tilemap := get_tree().root.get_node("Main/MapGenerator/Terrain")
onready var enemies_manager := get_tree().root.get_node("Main/EnemiesManager")
# Spawner variables
onready var enemy_spawn_location := $EnemySpawnLocation


func spawn_enemy(enemy: Enemy):
	# Check if it's a valid position
	var valid_position := false
	while not valid_position:
		enemy_spawn_location.offset = randi()
		valid_position = test_position(enemy_spawn_location.position + player.position)
	enemy.position = enemy_spawn_location.position + player.position


func test_position(position: Vector2) -> bool:
	# Check if the cell type in this position is grass or sand
	var cell_coord = tilemap.world_to_map(position)
	var cell_type_id = tilemap.get_cellv(cell_coord)
	var grass_or_sand = cell_type_id == tilemap.tile_set.find_tile_by_name("Grass") or cell_type_id == tilemap.tile_set.find_tile_by_name("Sand")
	# Check if there's a tree in this position
	var no_trees = cell_type_id != tilemap.tile_set.find_tile_by_name("Tree")
	# If the two conditions are true, the position is valid
	return grass_or_sand and no_trees
