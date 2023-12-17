class_name AttackComponent
extends Node3D

signal can_rotate(flag: bool)
signal can_move(flag: bool)

@export var _attack_animations: AttackAnimations
@export var _movement_component: MovementComponent
@export var _weapon: Sword
@export var _can_attack: bool = true

var attacking: bool = false
var attack_level: int = 1:
	set = set_attack_level

var _manually_set_attack_level: bool = false
var _can_stop_attack: bool = true
var _can_attack_again: bool = false
var _attack_interrupted: bool = false

@onready var _backstab_system: BackstabSystem = Globals.backstab_system
@onready var _dizzy_system: DizzySystem = Globals.dizzy_system


# Called when the node enters the scene tree for the first time.
func _ready() -> void:
	_attack_animations.secondary_movement.connect(_receive_movement)
	_attack_animations.can_rotate.connect(_receive_rotation)
	_attack_animations.can_damage.connect(_receive_can_damage)
	_attack_animations.can_attack_again.connect(_receive_can_attack_again)
	_attack_animations.can_play_animation.connect(_receive_can_play_animation)
	_attack_animations.attacking_finished.connect(_receive_attacking_finished)


func attack(can_stop: bool = true) -> void:
	if not _can_attack:
		return
		
	attacking = true
	_can_stop_attack = can_stop
	_attack_interrupted = false
	
	if not _manually_set_attack_level:
		if _can_attack_again and attack_level < 2:
			attack_level += 1
		else:
			attack_level = 1
	
	_can_attack = false
	
	can_rotate.emit(true)
	can_move.emit(false)
	
	if _backstab_system.backstab_victim or _dizzy_system.dizzy_victim:
		_attack_animations.thrust()
	else:
		_attack_animations.attack(attack_level, _manually_set_attack_level)
		
	_manually_set_attack_level = false


func stop_attacking() -> bool:
	if _can_stop_attack:
		if attacking:
			_attack_interrupted = true
		can_move.emit(true)
		attacking = false
		attack_level = 1
		_can_attack_again = false
		_attack_animations.stop_attacking()
	return not attacking


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


func _receive_movement() -> void:
	if _attack_interrupted:
		return
		
	match attack_level:
		1:
			_movement_component.set_secondary_movement(6, 5, 15)
		2:
			_movement_component.set_secondary_movement(6, 5, 15)
		3:
			_movement_component.set_secondary_movement(6, 5, 15)
		4:
			_movement_component.set_secondary_movement(6, 5, 15)


func _receive_can_damage(can_damage: bool) -> void:
	_can_stop_attack = false
	if not _attack_interrupted:
		_weapon.can_damage = can_damage


func _on_hitbox_component_weapon_hit(_w: Sword):
	if attacking:
		_attack_interrupted = true
	can_move.emit(true)
	attacking = false
	attack_level = 1
	_can_attack_again = false
	_attack_animations.stop_attacking()
