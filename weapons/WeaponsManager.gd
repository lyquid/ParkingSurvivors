extends Node

class_name WeaponsManager

onready var player := get_tree().root.get_node("Main/YSort/Player")
var baseball_bat_scene := preload("res://weapons/baseball bat/BaseballBat.tscn")
var chain_scene := preload("res://weapons/chain/Chain.tscn")
var knife_launcher_scene := preload("res://weapons/knife/KnifeLauncher.tscn")
var molotov_launcher_scene := preload("res://weapons/molotov/MolotovLauncher.tscn")


func _ready():
	var baseball_bat := baseball_bat_scene.instance()
	player.call_deferred("add_child", baseball_bat)
	var knife_launcher := knife_launcher_scene.instance()
	player.call_deferred("add_child", knife_launcher)
	var chain := chain_scene.instance()
	player.call_deferred("add_child", chain)
	var molotov_launcher := molotov_launcher_scene.instance()
	player.call_deferred("add_child", molotov_launcher)
