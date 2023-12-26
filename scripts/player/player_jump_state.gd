class_name PlayerJumpState
extends PlayerStateMachine


@export var walk_state: PlayerWalkState
@export var attack_state: PlayerAttackState
@export var block_state: PlayerBlockState
@export var parry_state: PlayerParryState


func _ready():
	super._ready()
	
	player.jump_component.just_landed.connect(
		func():
			if parent_state.current_state == self:
				parent_state.transition_to_previous_state()
	)


func enter():
	player.jump_component.start_jump()
	
	if parent_state.previous_state == walk_state:
		player.movement_component.speed = 3.5


func process_player():
	if Input.is_action_just_pressed("attack"):
		parent_state.change_state(attack_state)
		return
	
	if Input.is_action_just_pressed("block"):
		parent_state.change_state(parry_state)
		return
	
	if Input.is_action_pressed("block"):
		parent_state.change_state(block_state)
		return
	
	player.set_rotation_target_to_lock_on_target()
	
	if parent_state.previous_state is PlayerRunState or \
	not player.lock_on_target:
		player.rotation_component.rotate_towards_target = false
	else:
		player.rotation_component.rotate_towards_target = true


func exit():
	pass

