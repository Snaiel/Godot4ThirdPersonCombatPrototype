class_name PlayerBackstabPrepareState
extends PlayerStateMachine


@export var dodge_state: PlayerDodgeState
@export var jump_state: PlayerJumpState
@export var attack_state: PlayerAttackState
@export var block_state: PlayerBlockState
@export var parry_state: PlayerParryState
@export var backstab_attack_state: PlayerBackstabAttackState

var main_state : PlayerStateMachine

func _ready():
	super._ready()


func enter() -> void:
	main_state = parent_state.parent_state


func process_player() -> void:
	var victim: = Globals.backstab_system.backstab_victim
	if victim:
		player.rotation_component.target = victim
	else:
		player.set_rotation_target_to_lock_on_target()
	
	
	if Input.is_action_just_pressed("run"):
		main_state.change_state(dodge_state)
		return
	
	if Input.is_action_just_pressed("jump") and \
	player.is_on_floor():
		main_state.change_state(jump_state)
		return
	
	if Input.is_action_just_pressed("attack"):
		parent_state.change_state(backstab_attack_state)
		return
	
	if Input.is_action_just_pressed("block"):
		main_state.change_state(parry_state)
		return
	
	if Input.is_action_pressed("block"):
		main_state.change_state(block_state)
		return
	
	
	if not Globals.backstab_system.backstab_victim:
		main_state.transition_to_default_state()


func process_movement_animations() -> void:
	player.character.idle_animations.active = true
	player.character.movement_animations.dir = player.input_direction


func exit() -> void:
	pass
