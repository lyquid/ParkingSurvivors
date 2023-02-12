extends Node

class_name LevelingManager

var current_xp_needed := 5

func new_level(current_level: int) -> int:
	if current_level == 1:
		return current_xp_needed

	if current_level <= 20:
		current_xp_needed += 10
		return current_xp_needed

	if current_level <= 40:
		current_xp_needed += 13
		return current_xp_needed

	# level 41 and onward
	current_xp_needed += 16
	return current_xp_needed;
