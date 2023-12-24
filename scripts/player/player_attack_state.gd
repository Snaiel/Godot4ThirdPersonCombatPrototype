class_name PlayerAttackState
extends PlayerStateMachine


func _ready():
	super._ready()


func enter():
	player.movement_component.can_move = false
	if parent_state.previous_state is PlayerBackstabState:
		player.attack_component.thrust()
	elif parent_state.previous_state is PlayerIdleState or \
	parent_state.previous_state is PlayerWalkState or \
	parent_state.previous_state is PlayerRunState or \
	parent_state.previous_state is PlayerJumpState:
		player.attack_component.attack()


func process_player():
	if not player.attack_component.attacking:
		parent_state.transition_to_default_state()
		return
	
	if Input.is_action_just_pressed("attack"):
		player.attack_component.attack()


func exit():
	player.movement_component.can_move = true
