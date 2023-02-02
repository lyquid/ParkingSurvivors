extends Node2D

class_name Weapon

export var cooldown: float
export var damage: float
export var kinematic_force: float

onready var player := get_tree().root.get_node("Main/Player")
onready var graphics := $WeaponGraphics
