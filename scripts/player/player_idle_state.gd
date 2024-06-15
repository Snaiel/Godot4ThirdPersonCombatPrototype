class_name PlayerIdleState
extends PlayerStateMachine


@export var walk_state: PlayerWalkState
@export var dodge_state: PlayerDodgeState
@export var jump_state: PlayerJumpState
@export var attack_state: PlayerAttackState
@export var block_state: PlayerBlockState
@export var parry_state: PlayerParryState
@export var backstab_state: PlayerBackstabState

var _locked_on_turning_in_place: bool = false

@onready var lock_on_system: LockOnSystem = Globals.lock_on_system


func _ready():
	super._ready()
	lock_on_system.lock_on.connect(_on_lock_on_system_lock_on)

func enter():
	player.rotation_component.move_direction = Vector3.ZERO
	player.rotation_component.can_rotate = true

func process_player() -> void:
	if player.input_direction.length() > 0:
		parent_state.change_state(walk_state)
		return
	
	if Input.is_action_just_pressed("run"):
		parent_state.change_state(dodge_state)
		return
	
	if Input.is_action_just_pressed("jump") and \
	player.is_on_floor():
		parent_state.change_state(jump_state)
		return
	
	if Input.is_action_just_pressed("attack"):
		parent_state.change_state(attack_state)
		return
	
	if Input.is_action_just_pressed("block"):
		parent_state.change_state(parry_state)
		return
	
	if Input.is_action_pressed("block"):
		parent_state.change_state(block_state)
		return
	
	if Globals.backstab_system.backstab_victim:
		parent_state.change_state(backstab_state)
		return
	
	player.set_rotation_target_to_lock_on_target()
	
	if player.lock_on_target:
		player.rotation_component.rotate_towards_target = true
	else:
		player.rotation_component.rotate_towards_target = false


func process_movement_animations() -> void:
	var _animation_input_dir: Vector3 = player.input_direction
	if _locked_on_turning_in_place:
		_animation_input_dir = Vector3.FORWARD
	
	player.character.movement_animations.move(
		_animation_input_dir,
		player.lock_on_target != null, 
		false
	)


func _on_lock_on_system_lock_on(target: LockOnComponent) -> void:
	if target and \
	player.rotation_component.get_lock_on_rotation_difference() > 0.1:
		
		var diff: float = player.rotation_component\
			.get_lock_on_rotation_difference()
		
		_locked_on_turning_in_place = true
		
		var duration: float = clamp(diff / PI * 0.18, 0.1, 0.18)
		var pressed_lock_on_timer: SceneTreeTimer = get_tree()\
			.create_timer(duration)
		
		pressed_lock_on_timer.timeout.connect(
			func():
				_locked_on_turning_in_place = false
		)
