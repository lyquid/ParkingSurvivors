extends MarginContainer

onready var xpbar_gauge := $HBoxContainer/Bars/XPBar/Gauge

func update_xpbar(value: int):
	xpbar_gauge.value = value
