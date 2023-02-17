extends Node2D

class_name Weapon

var cooldown: float
var damage: int
var kinematic_force: float

onready var player := get_tree().root.get_node("Main/YSort/Player")
