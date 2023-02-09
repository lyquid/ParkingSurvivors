extends Node

onready var terrain := $Terrain
onready var trees := $Trees

export var size := Vector2(100.0, 100.0)
export var noise_seed := 42
export var lacunarity := 2.0
export var octaves := 4
export var period := 20.0
export var persistence := 0.5

enum TILE { GRASS, SAND, WATER, OBSTACLE, TREE }
enum { BUSH, ROCK, STUMP, SAND_ROCK }
var obstacles_arr = [
	Vector2(0.0, 0.0),
	Vector2(1.0, 0.0),
	Vector2(0.0, 1.0),
	Vector2(1.0, 1.0),
]

func _ready():
	var rng = RandomNumberGenerator.new()
	rng.randomize()

	var noise: OpenSimplexNoise = OpenSimplexNoise.new()
	noise_seed = rng.randi() # delete this to actually use the given seed
	noise.seed = noise_seed
	noise.octaves = octaves
	noise.period = period
	noise.persistence = persistence
	
	var water_offset := 20
	
	# fill everything with water
	for i in range(-size.y * 0.5 - water_offset, size.y * 0.5 + water_offset):
		for j in range(-size.x * 0.5 - water_offset, size.x * 0.5 + water_offset):
			terrain.set_cell(j, i, TILE.WATER)

	for i in range(-size.y * 0.5, size.y * 0.5):
		for j in range(-size.x * 0.5, size.x * 0.5):

			var noise_value: float = noise.get_noise_2d(j, i)
			if noise_value < -0.5:
				terrain.set_cell(j, i, TILE.WATER)
			elif noise_value < 0.3:
				if rng.randi_range(1, 500) == 1:
					var obstacle: int = rng.randi_range(0, 2)
					terrain.set_cell(j, i, TILE.OBSTACLE, false, false, false, obstacles_arr[obstacle])
				else:
					terrain.set_cell(j, i, TILE.GRASS)
					if rng.randi_range(1, 500) == 1:
						trees.set_cell(j, i, TILE.TREE)
			else:
				terrain.set_cell(j, i, TILE.SAND)

	terrain.update_bitmask_region(
		Vector2(-size.x * 0.5 - water_offset, -size.y * 0.5 - water_offset), 
		Vector2(size.x * 0.5 + water_offset, size.y * 0.5 + water_offset)
	)
	terrain.update_dirty_quadrants()
