class_name Player
extends CharacterBody3D


@export_category("Mechanisms")
@export var state_machine: PlayerStateMachine
@export var character: CharacterAnimations
@export var camera_controller: CameraController
@export var movement_component: MovementComponent
@export var hitbox_component: HitboxComponent
@export var jump_component: JumpComponent
@export var block_component: BlockComponent
@export var dodge_component: DodgeComponent
@export var rotation_component: PlayerRotationComponent
@export var attack_component: AttackComponent
@export var parry_component: ParryComponent
@export var fade_component: FadeComponent
@export var weapon: Sword

var input_direction: Vector3 = Vector3.ZERO
var last_input_on_ground: Vector3 = Vector3.ZERO

var lock_on_target: LockOnComponent = null
var locked_on_turning_in_place: bool = false

var holding_down_run: bool = false
var _holding_down_run_timer: Timer

@onready var dizzy_system: DizzySystem = Globals.dizzy_system


func _ready() -> void:
	Globals.backstab_system.attack_component = attack_component

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
	
	state_machine.enter_state_machine()


func _physics_process(_delta: float) -> void:
	state_machine.process_player_state_machine()
	
	# player inputs
	input_direction.x = Input.get_action_strength("right") - Input.get_action_strength("left")
	input_direction.z = Input.get_action_strength("backward") - Input.get_action_strength("forward")

	last_input_on_ground = input_direction if is_on_floor() else last_input_on_ground
	
	movement_component.move_direction = rotation_component.move_direction	
	
	var _animation_input_dir: Vector3 = input_direction
	if locked_on_turning_in_place or \
	(
		dodge_component.dodging and \
		input_direction.length() < 0.1
	):
		_animation_input_dir = Vector3.FORWARD
	
	character.movement_animations.move(
		_animation_input_dir, 
		lock_on_target != null or Globals.backstab_system.backstab_victim, 
		state_machine.current_state is PlayerRunState
	)
	
	# make sure the user is actually holding down
	# the run key to make the player run
	if Input.is_action_just_pressed("run"):
		_holding_down_run_timer.start(0.1)
	if Input.is_action_just_released("run"):
		_holding_down_run_timer.stop()
		holding_down_run = false


func set_rotation_target_to_lock_on_target() -> void:
	rotation_component.target = lock_on_target


func _on_lock_on_system_lock_on(target: LockOnComponent) -> void:
	lock_on_target = target
	
	if input_direction.length() < 0.1 and \
	target and \
	rotation_component.get_lock_on_rotation_difference() > 0.1:
		
		var diff: float = rotation_component\
			.get_lock_on_rotation_difference()
		
		locked_on_turning_in_place = true
		
		var duration: float = clamp(diff / PI * 0.18, 0.1, 0.18)
		var pressed_lock_on_timer: SceneTreeTimer = get_tree()\
			.create_timer(duration)
		
		pressed_lock_on_timer.timeout.connect(
			func():
				locked_on_turning_in_place = false
		)


func _knockback(incoming_weapon: Sword) -> void:
	var opponent_position: Vector3 = incoming_weapon.get_entity().global_position
	var direction: Vector3 = global_position.direction_to(opponent_position)
	movement_component.set_secondary_movement(incoming_weapon.get_knockback(), 5, 5, -direction)


func _on_hitbox_component_weapon_hit(incoming_weapon: Sword):
	if parry_component.in_parry_window:
		parry_component.reset_parry_cooldown()
		character.parry_animations.parry()
		block_component.anim.stop()
		block_component.anim.play("parried")
		incoming_weapon.get_parried()
		if not dizzy_system.dizzy_victim:
			_knockback(incoming_weapon)
		print("PARRIED")
	elif block_component.blocking or parry_component.is_spamming():
		_knockback(incoming_weapon)
		block_component.blocked()
	elif not state_machine.current_state is PlayerParriedEnemyHitState:
		print("HIT")
		_knockback(incoming_weapon)
		character.hit_and_death_animations.hit()
		movement_component.got_hit()
		attack_component.interrupt_attack()
