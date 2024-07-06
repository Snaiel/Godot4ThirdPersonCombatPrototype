class_name PlayerAttackState
extends PlayerStateMachine


@export var parry_state: PlayerParryState
@export var block_state: PlayerBlockState
@export var dizzy_finisher_state: PlayerDizzyFinisherState

var _transition_to_dizzy_finisher: bool = false


func _ready() -> void:
	super._ready()


func enter() -> void:
	_transition_to_dizzy_finisher = false
	if _check_for_dizzy_finisher():
		return
	
	player.locomotion_component.can_move = false
	
	if parent_state.previous_state is PlayerBlockState:
		player.melee_component.attack(0, false, false)
	else:
		player.melee_component.attack()


func process_player() -> void:
	if _transition_to_dizzy_finisher:
		parent_state.change_state(dizzy_finisher_state)
		return
	
	if Input.is_action_just_pressed("attack"):
		if _check_for_dizzy_finisher(): return
		var attack_level = player.melee_component.attack_level
		player.melee_component.attack(not attack_level)
	
	if not player.melee_component.attacking:
		parent_state.transition_to_default_state()
		return
	
	if Input.is_action_just_pressed("block") and \
	player.melee_component.stop_attacking():
		parent_state.change_state(parry_state)
		return
	
	if Input.is_action_pressed("block") and \
	player.melee_component.stop_attacking():
		parent_state.change_state(block_state)
		return
	


func exit() -> void:
	player.locomotion_component.can_move = true
	player.melee_component.interrupt_attack()


func _check_for_dizzy_finisher() -> bool:
	var dizzy_system: DizzySystem = Globals.dizzy_system
	if dizzy_system.dizzy_victim and dizzy_system.can_kill_victim:
		_transition_to_dizzy_finisher = true
	return _transition_to_dizzy_finisher
