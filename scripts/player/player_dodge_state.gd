class_name PlayerDodgeState
extends PlayerStateMachine


@export var run_state: PlayerRunState
@export var jump_state: PlayerJumpState


func _ready():
	super._ready()


func enter() -> void:
	player.melee_component.interrupt_attack()
	player.dodge_component.intent_to_dodge = true
	player.hitbox_component.enabled = false


func process_player() -> void:
	if Input.is_action_just_pressed("jump") and \
	player.is_on_floor():
		parent_state.change_state(jump_state)
		return
	
	if run_state.holding_down_run:
		parent_state.change_state(run_state)
		return
	
	if not player.dodge_component.dodging:
		parent_state.transition_to_default_state()
		return
	
	player.set_rotation_target_to_lock_on_target()


func process_movement_animations() -> void:
	var _animation_input_dir: Vector3 = player.input_direction
	if _animation_input_dir.length() < 0.1:
		_animation_input_dir = Vector3.FORWARD
	
	player.character.idle_animations.active = player.lock_on_target != null
	player.character.movement_animations.dir = _animation_input_dir


func exit() -> void:
	player.hitbox_component.enabled = true
