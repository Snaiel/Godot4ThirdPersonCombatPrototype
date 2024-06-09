class_name Player
extends CharacterBody3D


@export_category("Mechanisms")
@export var state_machine: PlayerStateMachine
@export var character: CharacterAnimations
@export var movement_component: MovementComponent
@export var root_motion_component: RootMotionComponent
@export var hitbox_component: HitboxComponent
@export var health_component: HealthComponent
@export var instability_component: InstabilityComponent
@export var jump_component: JumpComponent
@export var block_component: BlockComponent
@export var dodge_component: DodgeComponent
@export var rotation_component: PlayerRotationComponent
@export var head_rotation_component: HeadRotationComponent
@export var attack_component: AttackComponent
@export var parry_component: ParryComponent
@export var fade_component: FadeComponent
@export var health_charge_component: HealthChargeComponent

@export_category("Character")
@export var weapon: Sword
@export var lock_on_attachment_point: Node3D

@export_category("Audio")
@export var footsteps: AudioFootsteps

signal aggro_enemy_counter_changed(old_value : int, new_value : int)

var active_motion_component: MotionComponent

var input_direction: Vector3 = Vector3.ZERO
var last_input_on_ground: Vector3 = Vector3.ZERO

var lock_on_target: LockOnComponent = null
var locked_on_turning_in_place: bool = false

var holding_down_run: bool = false
var _holding_down_run_timer: Timer

var _aggro_enemy_counter: int = 0

var aggro_enemy_counter: int:
	set(value):
		var old = _aggro_enemy_counter
		_aggro_enemy_counter = value
		if _aggro_enemy_counter < 0:
			_aggro_enemy_counter = 0
		
		aggro_enemy_counter_changed.emit(old, _aggro_enemy_counter)
	get:
		return _aggro_enemy_counter

@onready var drink_state: PlayerDrinkState = $StateMachine/Drink
@onready var checkpoint_state: PlayerCheckpointState = $StateMachine/Checkpoint

@onready var dizzy_system: DizzySystem = Globals.dizzy_system
@onready var backstab_system: BackstabSystem = Globals.backstab_system
@onready var checkpoint_system: CheckpointSystem = Globals.checkpoint_system

func _ready() -> void:
	active_motion_component = movement_component
	hitbox_component.weapon_hit.connect(_on_hitbox_component_weapon_hit)
	
	attack_component.can_rotate.connect(
		func(flag: bool):
			rotation_component.can_rotate = flag
	)
	
	_holding_down_run_timer = Timer.new()
	_holding_down_run_timer.timeout.connect(
		func():
			holding_down_run = true
	)
	add_child(_holding_down_run_timer)
	
	dizzy_system.dizzy_victim_killed.connect(
		func():
			instability_component.instability = 0.0
	)
	
	state_machine.enter_state_machine()
	
	character.walk_or_jog_animations.to_jogging()
	
	Globals.void_death_system.fallen_into_the_void.connect(
		func(body: Node3D):
			if body is Player:
				health_component.deal_max_damage = true
				health_component.decrement_health(1)
	)


func _physics_process(_delta: float) -> void:
	
	if Input.is_action_just_pressed("exit"):
		get_tree().quit()
	elif Input.is_action_just_pressed("ui_text_backspace"):
		Input.mouse_mode = Input.MOUSE_MODE_VISIBLE
	elif Input.is_action_just_pressed("attack") and \
	not checkpoint_system.at_checkpoint:
		Input.mouse_mode = Input.MOUSE_MODE_CAPTURED
	
	state_machine.process_player_state_machine()
	state_machine.process_movement_animations_state_machine()
	
	# player inputs
	input_direction.x = Input.get_action_strength("right") - Input.get_action_strength("left")
	input_direction.z = Input.get_action_strength("backward") - Input.get_action_strength("forward")

	last_input_on_ground = input_direction if is_on_floor() else last_input_on_ground
	
	movement_component.move_direction = rotation_component.move_direction
	
	
	# make sure the user is actually holding down
	# the run key to make the player run
	if Input.is_action_just_pressed("run"):
		_holding_down_run_timer.start(0.1)
	if Input.is_action_just_released("run"):
		_holding_down_run_timer.stop()
		holding_down_run = false
	
	
	if Input.is_action_just_pressed("consume_item") and \
	not state_machine.current_state is PlayerDrinkState and \
	not state_machine.current_state is PlayerCheckpointState:
		state_machine.change_state(drink_state)
	
	if Input.is_action_just_pressed("interact") and \
	not state_machine.current_state is PlayerCheckpointState and \
	checkpoint_system.current_checkpoint and \
	checkpoint_system.current_checkpoint.can_sit_at_checkpoint and \
	Globals.player.aggro_enemy_counter <= 0:
		state_machine.change_state(checkpoint_state)
	
	
	if rotation_component.rotate_towards_target and \
	rotation_component.target != null:
		head_rotation_component.desired_target_pos = \
			rotation_component.target.global_position
	elif backstab_system.backstab_victim != null:
		head_rotation_component.desired_target_pos = \
			backstab_system.backstab_victim.global_position
	else:
		head_rotation_component.desired_target_pos = Vector3.INF
	
	
	footsteps.on_floor = is_on_floor()
	footsteps.running = state_machine.current_state is PlayerRunState


func set_rotation_target_to_lock_on_target() -> void:
	rotation_component.target = lock_on_target


func process_default_movement_animations() -> void:
	var dir: Vector3 = input_direction
	var lock_on: bool = lock_on_target != null
	
	if movement_component.has_secondary_movement():
		dir = Vector3.ZERO
		lock_on = true
	
	character.movement_animations.move(
		dir,
		lock_on, 
		false
	)


func set_root_motion(flag: bool) -> void:
	if flag:
		active_motion_component = root_motion_component
		root_motion_component.enabled = true
		movement_component.enabled = false
	else:
		active_motion_component = movement_component
		root_motion_component.enabled = false
		movement_component.enabled = true


func _on_lock_on_system_lock_on(target: LockOnComponent) -> void:
	lock_on_target = target


func _on_hitbox_component_weapon_hit(incoming_weapon: Sword) -> void:
	if state_machine.current_state is PlayerParryState or \
	state_machine.current_state is PlayerParriedEnemyHitState or \
	state_machine.current_state is PlayerBlockState:
		return
	
	health_component.damage_from_weapon(incoming_weapon)
	instability_component.process_hit()
