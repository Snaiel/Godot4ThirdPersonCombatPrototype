class_name PlayerAttackState
extends PlayerStateMachine


func _ready():
	super._ready()


func enter():
	if parent_state.previous_state is PlayerIdleState or \
	parent_state.previous_state is PlayerWalkState or \
	parent_state.previous_state is PlayerRunState or \
	parent_state.previous_state is PlayerJumpState:
		player.attack_component.attack()
		player.movement_component.can_move = false


func process_player():
	if not player.attack_component.attacking:
		if parent_state.previous_state is PlayerJumpState:
			parent_state.transition_to_default_state()
			return
		parent_state.transition_to_previous_state()
		return
	
	if Input.is_action_just_pressed("attack"):
		player.attack_component.attack()


func exit():
	player.movement_component.can_move = true
