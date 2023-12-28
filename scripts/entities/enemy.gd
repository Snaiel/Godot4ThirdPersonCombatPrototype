class_name Enemy
extends CharacterBody3D

signal death(enemy)

@export var target: Node3D
@export var debug: bool = false
@export var friction: float = 0.05

# Get the gravity from the project settings to be synced with RigidBody nodes.
var gravity: float = ProjectSettings.get_setting("physics/3d/default_gravity")

@onready var _blackboard: Blackboard = $Blackboard
@onready var _character: CharacterAnimations = $CharacterModel
@onready var _rotation_component: RotationComponent = $EnemyRotationComponent
@onready var _movement_component: MovementComponent = $MovementComponent
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

var _set_agent_target_to_target: bool = false

var _default_move_speed: float
var _dead: bool = false


func _ready() -> void:
	target = Globals.player
	_agent.target_position = target.global_position	
	_rotation_component.target = target
	
	_default_move_speed = _movement_component.speed
	_blackboard.set_value("move_speed", _default_move_speed)
	
	_notice_component.state_changed.connect(
		func(new_state: String, target_to_target: bool):
			if new_state == "aggro" and \
			not _blackboard.get_value("got_hit", false):
				_blackboard.set_value("interrupt_timers", true)
			_blackboard.set_value("notice_state", new_state)
			_set_agent_target_to_target = target_to_target
			if _notice_component.position_to_check != Vector3.INF:
				_agent.target_position = _notice_component.position_to_check
#				prints(_agent.target_position, target.global_position)
	)
	
#	_character.hit_and_death_animations.hit_finished.connect(
#		func():
#			_blackboard.set_value("got_hit", false)
#	)
	
	_blackboard.set_value("can_attack", true)	
	
	_blackboard.set_value("dead", false)


func _physics_process(_delta: float) -> void:
	_rotation_component.debug = debug
	_movement_component.debug = debug
	_backstab_component.debug = debug
	_notice_component.debug = debug
	_dizzy_component.debug = debug
	
	_blackboard.set_value("debug", debug)
	
	if _set_agent_target_to_target:
		_agent.target_position = target.global_position
	
	var target_dist: float = _agent.distance_to_target()
	var target_dir: Vector3 = global_position.direction_to(_agent.target_position)
	var target_dir_angle: float = target_dir.angle_to(Vector3.FORWARD.rotated(Vector3.UP, global_rotation.y))
	
	_blackboard.set_value("target", target)
	_blackboard.set_value("target_dist", target_dist)
	_blackboard.set_value("target_dir", target_dir)
	_blackboard.set_value("target_dir_angle", target_dir_angle)
	
#	if debug: print(_blackboard.get_value("can_move"))
#	if debug: print(global_position.distance_to(Globals.player.global_position))
	
	_rotation_component.look_at_target = _blackboard.get_value(
		"look_at_target",
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
	
	if _blackboard.get_value("can_attack", false) and _blackboard.get_value("attack", false):
		_blackboard.set_value("can_attack", false)
		_blackboard.set_value("attack", false)
		_attack_component.attack_level = _blackboard.get_value("attack_level", 1)
		_attack_component.attack()
	
	_character.anim_tree["parameters/Lock On Walk/4/TimeScale/scale"] = 0.5
	_character.anim_tree["parameters/Lock On Walk/5/TimeScale/scale"] = 0.5	
	_character.movement_animations.move(
		_blackboard.get_value("input_direction", Vector3.ZERO), 
		_blackboard.get_value("locked_on", false), 
		false
	)


func _on_entity_hitbox_weapon_hit(weapon: Sword) -> void:
	if Globals.backstab_system.backstab_victim == _backstab_component:
		_backstab_component.process_hit()
		_health_component.decrement_health(weapon)
		_movement_component.knockback(weapon.get_entity().global_position)
		return
	
	if Globals.dizzy_system.dizzy_victim == _dizzy_component:
		_dizzy_component.process_hit(weapon)
		_health_component.decrement_health(weapon)
		if _instability_component.full_instability_from_parry:
			_movement_component.knockback(weapon.get_entity().global_position)
		return
	
	
	var rng: float = RandomNumberGenerator.new().randf()
	
	if _blackboard.get_value("notice_state") != "aggro" or \
	_blackboard.get_value("dizzy", false):
		rng = 0.0
	
	
	if 0.8 < rng and rng <= 1.0:
		# 20% chance of parrying
		
		_movement_component.knockback(weapon.get_entity().global_position)
		
		_parry_component.in_parry_window = true
		_attack_component.interrupt_attack()
		
		_character.parry_animations.parry()
		_block_component.anim.play("parried")
		
		weapon.get_parried()
		
		var timer: SceneTreeTimer = get_tree().create_timer(0.2)
		timer.timeout.connect(
			func(): 
				_attack_component.attack()
		)
	elif 0.4 <= rng and rng <= 0.8:
		# 40% chance of blocking
		
		_movement_component.knockback(weapon.get_entity().global_position)
		
		_block_component.blocking = true
		_block_component.blocked()
		_attack_component.interrupt_attack()
		
		_instability_component.active = false
		_health_component.enabled = false
		
		_instability_component.increment_instability(15.0)
		
		var timer: SceneTreeTimer = get_tree().create_timer(0.3)
		timer.timeout.connect(
			func(): 
				_block_component.blocking = false
				_instability_component.active = true
				_health_component.enabled = true
		)
	else:
		# 40% chance of being hit
		
		_health_component.decrement_health(weapon)
		_instability_component.process_hit()
		
		_attack_component.interrupt_attack()
		
		_character.hit_and_death_animations.hit()
		_set_agent_target_to_target = true
		
		_blackboard.set_value("got_hit", true)
		_blackboard.set_value("interrupt_timers", true)
		
		if Globals.dizzy_system.dizzy_victim != _dizzy_component:
			_movement_component.knockback(weapon.get_entity().global_position)


func _on_health_component_zero_health() -> void:
	if _dead:
		return
	
	death.emit(self)
	_dead = true
	
	_hitbox_component.enabled = false
	_health_component.enabled = false
	_lock_on_component.enabled = false
	_backstab_component.enabled = false
	
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
