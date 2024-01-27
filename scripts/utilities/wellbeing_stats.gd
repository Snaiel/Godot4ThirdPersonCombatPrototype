@tool

class_name WellbeingStats
extends Resource


@export var max_health: float = 100:
	set(value):
		if value < 0:
			value = 100
		max_health = value
@export var initial_health: float = 100:
	set(value):
		initial_health = clamp(value, 0, max_health)

@export var max_instability: float = 100:
	set(value):
		if value < 0:
			value = 100
		max_instability = value
@export var initial_instability: float = 0:
	set(value):
		initial_instability = clamp(value, 0, max_instability)
@export var can_reduce_instability: bool = true
