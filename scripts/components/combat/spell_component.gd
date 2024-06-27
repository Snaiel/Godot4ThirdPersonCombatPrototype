class_name SpellComponent
extends Node


signal can_rotate(flag: bool)
signal can_move(flag: bool)

@export var spell_animations: SpellAnimations
@export var can_attack: bool = true

var active_motion_component: LocomotionStrategy

var executing: bool = false
var spell_index: int = 0:
	set = set_spell_index

## The label of a single spell occurrence.
# Used to make sure an entity is only hit
# once in a single instance of an spell.
# For example, a swing may enter a hitbox
# twice, separately, but on the same animation.
# This should only just count for one hit since
# it's in the same animation/instance.
var instance: int = 0

var _manually_set_spell_index: bool = false
var _can_stop_execution: bool = true
var _can_cast_again: bool = false
var _spell_interrupted: bool = false


# Called when the node enters the scene tree for the first time.
func _ready() -> void:
	spell_animations.can_rotate.connect(_receive_rotation)
	spell_animations.secondary_movement.connect(_receive_movement)
	spell_animations.can_cast_again.connect(_receive_can_attack_again)
	spell_animations.can_play_animation.connect(_receive_can_play_animation)
	spell_animations.animation_finished.connect(_receive_finished)


func cast_spell(can_stop: bool = true) -> void:
	instance += 1
	
	if not can_attack:
		return
		
	executing = true
	_can_stop_execution = can_stop
	_spell_interrupted = false
	
	if not _manually_set_spell_index:
		if _can_cast_again and spell_index < 1:
			spell_index += 1
		else:
			spell_index = 0
	
	can_attack = false
	
	can_rotate.emit(true)
	can_move.emit(false)
	
	spell_animations.cast_spell(spell_index, _manually_set_spell_index)
		
	_manually_set_spell_index = false


func disable_attack_interrupted() -> void:
	_spell_interrupted = false


## request to stop executing (for example, when blocking)
func stop_attacking() -> bool:
	if _can_stop_execution:
		interrupt_attack()
	return not executing


func interrupt_attack() -> void:
	if executing:
		_spell_interrupted = true
	
	can_move.emit(true)
	executing = false
	spell_index = 0
	
	can_attack = true
	_can_cast_again = false
	
	spell_animations.stop_attacking()


func set_spell_index(level: int) -> void:
	spell_index = level
	_manually_set_spell_index = true


func _receive_rotation(flag: bool) -> void:
	can_rotate.emit(flag)


func _receive_movement(spell: SpellStrategy) -> void:
	_can_stop_execution = false
	
	if _spell_interrupted:
		return
	
	active_motion_component.set_secondary_movement(
		spell.move_speed,
		spell.time,
		spell.friction,
		spell.direction
	)


func _receive_can_attack_again(can_attack_again: bool) -> void:
	can_attack = true
	if not _spell_interrupted:
		_can_cast_again = can_attack_again


func _receive_can_play_animation() -> void:
	_can_stop_execution = true


func _receive_finished() -> void:
	can_attack = true
	stop_attacking()
