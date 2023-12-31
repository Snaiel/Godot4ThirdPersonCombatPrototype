class_name Enemy
extends CharacterBody3D


signal death(enemy)


@export var target: Node3D
@export var debug: bool = false

var active_motion_component: MotionComponent

@onready var _blackboard: Blackboard = $Blackboard
@onready var _character: CharacterAnimations = $CharacterModel
@onready var _rotation_component: RotationComponent = $EnemyRotationComponent
@onready var _head_rotation_component: HeadRotationComponent = $HeadRotationComponent
@onready var _movement_component: MovementComponent = $MovementComponent
@onready var _root_motion_component: RootMotionComponent = $RootMotionComponent
@onready var _lock_on_component: LockOnComponent = $LockOnComponent
@onready var _hitbox_component: HitboxComponent = $HitboxComponent
@onready var _health_component: HealthComponent = $HealthComponent
@onready var _instability_component: InstabilityComponent = $InstabilityComponent
@onready var _backstab_component: BackstabComponent = $BackstabComponent
@onready var _dizzy_component: DizzyComponent = $DizzyComponent
@onready var _notice_component: NoticeComponent = $NoticeComponent
@onready var _attack_component: AttackComponent = $AttackComponent
@onready var _block_component: BlockComponent = $BlockComponent
@onready var _parry_component: ParryComponent = $ParryComponent
@onready var _agent: NavigationAgent3D = $NavigationAgent3D

@onready var skeleton: Skeleton3D = $CharacterModel/Armature_004/GeneralSkeleton


var _default_move_speed: float
var _dead: bool = false


func _ready() -> void:
	target = Globals.player
	_agent.target_position = target.global_position
	
	_attack_component.can_move.connect(
		func(flag: bool):
			_blackboard.set_value("can_move", flag)
	)
	
	active_motion_component = _movement_component
	
	_default_move_speed = _movement_component.speed
	_blackboard.set_value("move_speed", _default_move_speed)
	
	_blackboard.set_value("can_attack", true)	
	_blackboard.set_value("dead", false)


func _physics_process(_delta: float) -> void:
	## Debug Components
	_rotation_component.debug = debug
	_movement_component.debug = debug
	_backstab_component.debug = debug
	_notice_component.debug = debug
	_dizzy_component.debug = debug
	
	_blackboard.set_value("debug", debug)
	
	_agent.debug_enabled = debug
	
	
	## Target Operations
	var player_dist: float = global_position.distance_to(target.global_position)
	var target_dist: float = _agent.distance_to_target()
	var target_dir: Vector3 = global_position.direction_to(_agent.target_position)
	var target_dir_angle: float = target_dir.angle_to(Vector3.FORWARD.rotated(Vector3.UP, global_rotation.y))
	
	_blackboard.set_value("player_dist", player_dist)
	_blackboard.set_value("target", target)
	_blackboard.set_value("target_dist", target_dist)
	_blackboard.set_value("target_dir", target_dir)
	_blackboard.set_value("target_dir_angle", target_dir_angle)
	call_deferred("_set_target_reachable")
	
	if _blackboard.get_value("investigate_last_agent_position"):
		_blackboard.set_value("can_set_investigate_last_agent_position", false)
		_blackboard.set_value("investigate_last_agent_position", false)
		_blackboard.set_value(
			"agent_target_position",
			target.global_position
		)
	
	_agent.target_position = _blackboard.get_value(
		"agent_target_position",
		target.global_position
	)
	
	
	## Debug Prints
#	if debug:
#		prints(
#			_blackboard.get_value("agent_target_position"),
#			_rotation_component.target
#		)
	
	## Component Management
	_rotation_component.rotate_towards_target = _blackboard.get_value(
		"rotate_towards_target",
		false
	)
	
	_movement_component.can_move = _blackboard.get_value(
		"can_move",
		true
	)
	_movement_component.speed = _blackboard.get_value(
		"move_speed",
		_default_move_speed
	)
	
	_backstab_component.enabled = not _blackboard.get_value(
		"perceives_player",
		false
	)
	
	
	## Attacking
	if _blackboard.get_value("can_attack", false) and _blackboard.get_value("attack", false):
		_blackboard.set_value("can_attack", false)
		_blackboard.set_value("attack", false)
		_attack_component.attack_level = _blackboard.get_value("attack_level", 1)
		_attack_component.attack()
	
	
	## Character Animations
	_character.anim_tree["parameters/Lock On Walk/4/TimeScale/scale"] = 0.5
	_character.anim_tree["parameters/Lock On Walk/5/TimeScale/scale"] = 0.5	
	_character.movement_animations.move(
		_blackboard.get_value("input_direction", Vector3.ZERO), 
		_blackboard.get_value("locked_on", false), 
		false
	)
	
	
	## Head Rotation Component
	if _blackboard.get_value("agent_target_position") == null and \
	_blackboard.get_value("rotate_towards_target"):
		_head_rotation_component.desired_target_pos = \
			target.global_position
	else:
		_head_rotation_component.desired_target_pos = Vector3.INF


func set_root_motion(flag: bool) -> void:
	if flag:
		active_motion_component = _root_motion_component
		_root_motion_component.enabled = true
		_movement_component.enabled = false
	else:
		active_motion_component = _movement_component
		_root_motion_component.enabled = false
		_movement_component.enabled = true


func _set_target_reachable():
	await get_tree().physics_frame
	var target_reachable: bool = _agent.is_target_reachable()
	_blackboard.set_value("target_reachable", target_reachable)


func _on_entity_hitbox_weapon_hit(weapon: Sword) -> void:
	if Globals.backstab_system.backstab_victim == _backstab_component:
		_backstab_component.process_hit()
		_health_component.decrement_health(weapon)
		active_motion_component.knockback(weapon.get_entity().global_position)
		return
	
	if Globals.dizzy_system.dizzy_victim == _dizzy_component:
		_dizzy_component.process_hit(weapon)
		_health_component.decrement_health(weapon)
		if _instability_component.full_instability_from_parry:
			active_motion_component.knockback(weapon.get_entity().global_position)
		return
	
	
	var rng: float = RandomNumberGenerator.new().randf()
	
	if _blackboard.get_value("notice_state") != "aggro" or \
	_blackboard.get_value("dizzy", false):
		rng = 0.0
	
	
	if 0.8 < rng and rng <= 1.0:
		# 20% chance of parrying
		
		active_motion_component.knockback(weapon.get_entity().global_position)
		
		_parry_component.in_parry_window = true
		_attack_component.interrupt_attack()
		
		_character.parry_animations.parry()
		_block_component.anim.play("parried")
		
		_instability_component.process_parry()
		
		weapon.get_parried()
		
		_blackboard.set_value("can_attack", false)
		_blackboard.set_value("attack", false)
		
		var timer: SceneTreeTimer = get_tree().create_timer(0.2)
		timer.timeout.connect(
			func(): 
				_attack_component.attack()
		)
	elif 0.4 <= rng and rng <= 0.8:
		# 40% chance of blocking
		
		active_motion_component.knockback(weapon.get_entity().global_position)
		
		_block_component.blocking = true
		_block_component.blocked()
		_attack_component.interrupt_attack()
		
		_instability_component.process_block()
		
		_instability_component.enabled = false
		_health_component.enabled = false
		
		var timer: SceneTreeTimer = get_tree().create_timer(0.3)
		timer.timeout.connect(
			func(): 
				_block_component.blocking = false
				_instability_component.enabled = true
				_health_component.enabled = true
		)
	else:
		# 40% chance of being hit
		
		_health_component.decrement_health(weapon)
		_instability_component.process_hit()
		
		_attack_component.interrupt_attack()
		
		_character.hit_and_death_animations.hit()
#		_set_agent_target_to_target = true
		
		_blackboard.set_value("got_hit", true)
		_blackboard.set_value("interrupt_timers", true)
		
		if Globals.dizzy_system.dizzy_victim != _dizzy_component:
			active_motion_component.knockback(weapon.get_entity().global_position)


func _on_health_component_zero_health() -> void:
	if _dead:
		return
	
	_root_motion_component.enabled = true
	
	death.emit(self)
	_dead = true
	
	_hitbox_component.enabled = false
	_health_component.enabled = false
	_lock_on_component.enabled = false
	_backstab_component.enabled = false
	_dizzy_component.enabled = false
	_head_rotation_component.enabled = false
	_notice_component.enabled = false
	
	_blackboard.set_value("dead", true)
	_blackboard.set_value("interrupt_timers", true)
	
	collision_layer = 0
	collision_mask = 1
	
	if Globals.backstab_system.backstab_victim == _backstab_component:
		_character.hit_and_death_animations.death_2()
	elif Globals.dizzy_system.dizzy_victim == _dizzy_component and \
	not _dizzy_component.instability_component.full_instability_from_parry:
		_character.dizzy_animations.play_death_kneeling()
	else:
		_character.hit_and_death_animations.death_1()
