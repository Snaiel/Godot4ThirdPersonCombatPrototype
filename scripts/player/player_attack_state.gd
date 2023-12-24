class_name PlayerAttackState
extends PlayerStateMachine


@export var dizzy_finisher_state: PlayerStateMachine
@export var finisher_from_damage_state: PlayerDizzyFinisherFromDamageState

var _transition_to_dizzy_finisher: bool = false

func _ready():
	super._ready()


func enter():
	_transition_to_dizzy_finisher = false
	if check_for_dizzy_finisher():
		return
	
	player.movement_component.can_move = false
	if parent_state.previous_state is PlayerBackstabState:
		player.attack_component.thrust()
	elif parent_state.previous_state is PlayerIdleState or \
	parent_state.previous_state is PlayerWalkState or \
	parent_state.previous_state is PlayerRunState or \
	parent_state.previous_state is PlayerJumpState:
		player.attack_component.attack()


func process_player():
	if _transition_to_dizzy_finisher:
		transition_to_dizzy_finisher()
	
	if not player.attack_component.attacking:
		parent_state.transition_to_default_state()
		return
	
	if Input.is_action_just_pressed("attack"):
		if check_for_dizzy_finisher():
			return
		player.attack_component.attack()


func exit():
	player.movement_component.can_move = true


func check_for_dizzy_finisher() -> bool:
	var dizzy_victim: DizzyComponent = Globals.dizzy_system.dizzy_victim
	if dizzy_victim and not dizzy_victim.instability_component.full_instability_from_parry:
		_transition_to_dizzy_finisher = true
	return _transition_to_dizzy_finisher


func transition_to_dizzy_finisher() -> void:
	if _transition_to_dizzy_finisher:
		dizzy_finisher_state.change_state(finisher_from_damage_state)
		parent_state.change_state(dizzy_finisher_state)
