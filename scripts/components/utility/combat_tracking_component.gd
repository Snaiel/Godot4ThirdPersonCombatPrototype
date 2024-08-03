class_name CombatTrackingComponent
extends Node


@export var debug: bool = false
var _enemies_in_combat_with: Array[Enemy] = []


func _ready() -> void:
	if debug:
		print("Combat tracking component ready")

func reset() -> void:
	_enemies_in_combat_with.clear()

func is_in_combat() -> bool:
	return _enemies_in_combat_with.size() > 0

func add_enemy_in_combat(enemy: Enemy) -> void:
	if _enemies_in_combat_with.find(enemy) == -1:
		_enemies_in_combat_with.append(enemy)
		if debug:
			print("Adding enemy in combat with")
			print(_enemies_in_combat_with)

func remove_enemy_in_combat(enemy: Enemy) -> void:
	var index: int = _enemies_in_combat_with.find(enemy)
	if index != -1:
		_enemies_in_combat_with.remove_at(index)
		if debug:
			print("Removing enemy in combat with")
			print(_enemies_in_combat_with)
