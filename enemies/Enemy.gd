extends KinematicBody2D

class_name Enemy

var damage: float
var direction := Vector2.ZERO
var health: float
var speed: float

onready var player := get_tree().root.get_node("Main/Player")
