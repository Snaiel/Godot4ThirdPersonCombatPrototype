class_name PlayerAttackState
extends PlayerStateMachine


@export var parry_state: PlayerParryState
@export var block_state: PlayerBlockState
@export var dizzy_finisher_state: PlayerDizzyFinisherState

var _transition_to_dizzy_finisher: bool = false


func _ready():
	super._ready()


func enter():
	_transition_to_dizzy_finisher = false
	if check_for_dizzy_finisher():
		return
	
	player.movement_component.can_move = false
	
	if parent_state.previous_state is PlayerBlockState:
		player.attack_component.attack(false)
	else:
		player.attack_component.attack()


func process_player():
	if _transition_to_dizzy_finisher:
		transition_to_dizzy_finisher()
		return
	
	if Input.is_action_just_pressed("attack"):
		if check_for_dizzy_finisher():
			return
		player.attack_component.attack()
	
	if not player.attack_component.attacking:
		parent_state.transition_to_default_state()
		return
	
	if Input.is_action_just_pressed("block") and \
	player.attack_component.stop_attacking():
		parent_state.change_state(parry_state)
		return
	
	if Input.is_action_pressed("block") and \
	player.attack_component.stop_attacking():
		parent_state.change_state(block_state)
		return
	


func exit():
	player.movement_component.can_move = true
	player.attack_component.interrupt_attack()


func check_for_dizzy_finisher() -> bool:
	var dizzy_victim: DizzyComponent = Globals.dizzy_system.dizzy_victim
	if dizzy_victim and not dizzy_victim.instability_component.full_instability_from_parry:
		_transition_to_dizzy_finisher = true
	return _transition_to_dizzy_finisher


func transition_to_dizzy_finisher() -> void:
	if _transition_to_dizzy_finisher:
		parent_state.change_state(dizzy_finisher_state)
