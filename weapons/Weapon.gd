extends Node2D

class_name Weapon

var cooldown: float
var damage: float
var kinematic_force: float

onready var player := get_tree().root.get_node("Main/Player")
