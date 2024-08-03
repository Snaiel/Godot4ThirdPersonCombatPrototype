class_name Player
extends CharacterBody3D


@export_category("Mechanisms")
@export var state_machine: PlayerStateMachine
@export var character: PlayerAnimations
@export var locomotion_component: LocomotionComponent
@export var hitbox_component: HitboxComponent
@export var health_component: HealthComponent
@export var instability_component: InstabilityComponent
@export var jump_component: JumpComponent
@export var shield_component: ShieldComponent
@export var dodge_component: DodgeComponent
@export var rotation_component: PlayerRotationComponent
@export var head_rotation_component: HeadRotationComponent
@export var melee_component: MeleeComponent
@export var parry_component: ParryComponent
@export var fade_component: FadeComponent
@export var health_charge_component: HealthChargeComponent
var combat_tracking_component: CombatTrackingComponent = CombatTrackingComponent.new()

@export_category("Character")
@export var weapon: DamageSource
@export var lock_on_attachment_point: Node3D

@export_category("Audio")
@export var footsteps: AudioFootsteps

var input_direction: Vector3 = Vector3.ZERO
var last_input_on_ground: Vector3 = Vector3.ZERO

var lock_on_target: LockOnComponent = null
var locked_on_turning_in_place: bool = false



@onready var drink_state: PlayerDrinkState = $StateMachine/Drink
@onready var checkpoint_state: PlayerCheckpointState = $StateMachine/Checkpoint

@onready var backstab_system: BackstabSystem = Globals.backstab_system
@onready var checkpoint_system: CheckpointSystem = Globals.checkpoint_system


func _ready() -> void:
	Globals.lock_on_system.lock_on.connect(
		func(target: LockOnComponent): lock_on_target = target
	)
	
	Globals.dizzy_system.dizzy_victim_killed.connect(
		func(): instability_component.instability = 0.0
	)
	
	Globals.void_death_system.fallen_into_the_void.connect(
		func(body: Node3D):
			if not (body is Player): return
			health_component.deal_max_damage = true
			health_component.decrement_health(1)
	)
	
	melee_component.can_rotate.connect(
		func(flag: bool): rotation_component.can_rotate = flag
	)
	
	state_machine.enter_state_machine()


func _physics_process(_delta: float) -> void:
	## State Machine
	state_machine.process_player_state_machine()
	state_machine.process_movement_animations_state_machine()
	
	
	## Utility Inputs
	if Input.is_action_just_pressed("exit"):
		get_tree().quit()
	elif Input.is_action_just_pressed("ui_text_backspace"):
		Input.mouse_mode = Input.MOUSE_MODE_VISIBLE
	elif Input.is_action_just_pressed("attack") and \
	not checkpoint_system.at_checkpoint:
		Input.mouse_mode = Input.MOUSE_MODE_CAPTURED
	
	
	## Player Movement Inputs
	input_direction.x = Input.get_action_strength("right") - \
		Input.get_action_strength("left")
	input_direction.z = Input.get_action_strength("backward") - \
		Input.get_action_strength("forward")
	last_input_on_ground = input_direction if is_on_floor() else \
		last_input_on_ground
	
	
	## Head Rotation
	if rotation_component.rotate_towards_target and \
	rotation_component.target != null and \
	not state_machine.current_state is PlayerDizzyState:
		head_rotation_component.desired_target_pos = \
			rotation_component.target.global_position
	elif backstab_system.backstab_victim != null:
		head_rotation_component.desired_target_pos = \
			backstab_system.backstab_victim.global_position
	else:
		head_rotation_component.desired_target_pos = Vector3.INF
	
	
	## Footsteps
	footsteps.on_floor = is_on_floor()
	footsteps.running = state_machine.current_state is PlayerRunState


func set_rotation_target_to_lock_on_target() -> void:
	rotation_component.target = lock_on_target


func set_rotate_towards_target_if_lock_on_target() -> void:
	rotation_component.rotate_towards_target = \
		true if lock_on_target else false


func process_default_movement_animations() -> void:
	var dir: Vector3 = input_direction
	var idle_active: bool = lock_on_target != null
	
	if locomotion_component.has_secondary_movement():
		dir = Vector3.ZERO
		idle_active = true
	
	character.idle_animations.active = idle_active
	character.movement_animations.dir = dir
	character.movement_animations.set_state(
		"walk" if idle_active else "jog"
	)


func _on_lock_on_system_lock_on(target: LockOnComponent) -> void:
	lock_on_target = target
