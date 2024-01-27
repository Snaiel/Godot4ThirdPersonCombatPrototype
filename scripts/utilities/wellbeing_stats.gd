@tool

class_name WellbeingStats
extends Resource


@export var max_health: float:
	set(value):
		if value < 0:
			value = 100
		max_health = value
@export var initial_health: float:
	set(value):
		initial_health = clamp(value, 0, max_health)

@export var max_instability: float:
	set(value):
		if value < 0:
			value = 100
		max_instability = value
@export var initial_instability: float:
	set(value):
		initial_instability = clamp(value, 0, max_instability)


func _init(
	p_max_health: float = 100,
	p_initial_health: float = 100,
	p_max_instability: float = 100,
	p_initial_instability: float = 0
	):
	
	self.max_health = p_max_health
	self.initial_health = p_initial_health
	self.max_instability = p_max_instability
	self.initial_instability = p_initial_instability
