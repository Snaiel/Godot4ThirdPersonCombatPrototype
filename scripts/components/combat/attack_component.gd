class_name AttackComponent
extends Node

signal can_rotate(flag: bool)
signal can_move(flag: bool)

@export var _attack_animations: AttackAnimations
@export var _weapons: Dictionary
@export var _can_attack: bool = true

var attacking: bool = false
var attack_level: int = 0:
	set = set_attack_level

## The label of a single attack occurrence.
# Used to make sure an entity is only hit
# once in a single instance of an attack.
# For example, a swing may enter a hitbox
# twice, separately, but on the same animation.
# This should only just count for one hit since
# it's in the same animation/instance.
var instance: int = 0

var _manually_set_attack_level: bool = false
var _can_stop_attack: bool = true
var _can_attack_again: bool = false
var _attack_interrupted: bool = false


# Called when the node enters the scene tree for the first time.
func _ready() -> void:
	_attack_animations.secondary_movement.connect(_receive_movement)
	_attack_animations.can_rotate.connect(_receive_rotation)
	_attack_animations.can_damage.connect(_receive_can_damage)
	_attack_animations.can_attack_again.connect(_receive_can_attack_again)
	_attack_animations.can_play_animation.connect(_receive_can_play_animation)
	_attack_animations.attacking_finished.connect(_receive_attacking_finished)


func attack(can_stop: bool = true) -> void:
	instance += 1
	
	if not _can_attack:
		return
		
	attacking = true
	_can_stop_attack = can_stop
	_attack_interrupted = false
	
	if not _manually_set_attack_level:
		if _can_attack_again and attack_level < 1:
			attack_level += 1
		else:
			attack_level = 0
	
	_can_attack = false
	
	can_rotate.emit(true)
	can_move.emit(false)
	
	_attack_animations.attack(attack_level, _manually_set_attack_level)
		
	_manually_set_attack_level = false


func disable_attack_interrupted() -> void:
	_attack_interrupted = false


## request to stop attacking (for example, when blocking)
func stop_attacking() -> bool:
	if _can_stop_attack:
		interrupt_attack()
	return not attacking


func set_can_damage_of_weapons(flag: bool) -> void:
	for i in _weapons.values():
		var weapon: Weapon = get_node(i)
		weapon.can_damage = flag


func interrupt_attack() -> void:
	if attacking:
		_attack_interrupted = true
	
	can_move.emit(true)
	attacking = false
	attack_level = 0
	
	_can_attack = true
	_can_attack_again = false
	
	_attack_animations.stop_attacking()
	
	set_can_damage_of_weapons(false)


func set_attack_level(level: int) -> void:
	attack_level = level
	_manually_set_attack_level = true


func _receive_can_attack_again(can_attack_again: bool) -> void:
	_can_attack = true
	if not _attack_interrupted:
		_can_attack_again = can_attack_again


func _receive_can_play_animation() -> void:
	_can_stop_attack = true


func _receive_attacking_finished() -> void:
	_can_attack = true
	stop_attacking()


func _receive_rotation(flag: bool) -> void:
	can_rotate.emit(flag)


func _receive_movement(attack_strat: AttackStrategy) -> void:
	_can_stop_attack = false
	
	if _attack_interrupted:
		return
	
	attack_strat.receive_movement()


func _receive_can_damage(can_damage: bool, weapon_name: StringName) -> void:
	if _attack_interrupted:
		return
	
	prints(can_damage, weapon_name)
	
	if _weapons.has(weapon_name):
		var weapon: Weapon = get_node(_weapons[weapon_name])
		weapon.can_damage = can_damage
	else:
		set_can_damage_of_weapons(can_damage)
