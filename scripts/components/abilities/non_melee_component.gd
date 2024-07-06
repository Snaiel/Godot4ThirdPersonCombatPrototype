class_name NonMeleeComponent
extends Node


signal can_rotate(flag: bool)


@export var non_melee_animations: NonMeleeAnimations
@export var locomotion_component: LocomotionComponent
@export var can_perform_action: bool = true

# flag indicating whether an action is currently being executed
var executing_action: bool = false

# this is pretty much read only. changing this wont affect
# the level when start_action() is called. you must supply
# the desired level as a parameter in the start_action() function.
var action_index: int = 0

## The label of a single action occurrence.
# Used to make sure an entity is only hit
# once in a single instance of an action.
var instance: int = 0

var _can_stop_execution: bool = true
var _can_perform_again: bool = false
var _action_interrupted: bool = false


func _ready() -> void:
	non_melee_animations.can_rotate.connect(_receive_rotation)
	non_melee_animations.secondary_movement.connect(_receive_movement)
	non_melee_animations.action_effect.connect(_receive_action_effect)
	non_melee_animations.end_effect.connect(_receive_end_effect)
	non_melee_animations.can_perform_again.connect(_receive_can_perform_again)
	non_melee_animations.can_play_animation.connect(_receive_can_play_animation)
	non_melee_animations.animation_finished.connect(_receive_finished)


func perform_action(
		index: int = 0,
		override_can_play: bool = false,
		can_stop: bool = true
	) -> void:
		
	instance += 1
	
	if not can_perform_action:
		return
	
	can_rotate.emit(true)
	
	executing_action = true
	action_index = index
	can_perform_action = false
	
	_can_stop_execution = can_stop
	_action_interrupted = false
	
	non_melee_animations.start_action(action_index, override_can_play)


func disable_attack_interrupted() -> void:
	_action_interrupted = false


## request to stop action
func stop_action() -> bool:
	if _can_stop_execution:
		interrupt_action()
	return not executing_action


func interrupt_action() -> void:
	if executing_action:
		_action_interrupted = true
	
	executing_action = false
	action_index = 0
	
	can_perform_action = true
	_can_perform_again = false
	
	non_melee_animations.stop_action()
	
	for child in get_children():
		if not (child is NonMeleeActionEffect): continue
		var effect: NonMeleeActionEffect = child
		effect.end()


func _receive_rotation(flag: bool) -> void:
	can_rotate.emit(flag)


func _receive_movement(action: NonMeleeAction) -> void:
	_can_stop_execution = false
	
	if _action_interrupted:
		return
	
	locomotion_component.set_secondary_movement(
		action.move_speed,
		action.time,
		action.friction,
		action.direction
	)


func _receive_action_effect(index: int) -> void:
	var child = get_child(index)
	if not (child is NonMeleeActionEffect): return
	var effect: NonMeleeActionEffect = child
	effect.effect()


func _receive_end_effect(index: int) -> void:
	var child = get_child(index)
	if not (child is NonMeleeActionEffect): return
	var effect: NonMeleeActionEffect = child
	effect.end()


func _receive_can_perform_again(can_perform_again: bool) -> void:
	can_perform_action = true
	if not _action_interrupted:
		_can_perform_again = can_perform_again


func _receive_can_play_animation() -> void:
	_can_stop_execution = true


func _receive_finished() -> void:
	can_perform_action = true
	stop_action()
