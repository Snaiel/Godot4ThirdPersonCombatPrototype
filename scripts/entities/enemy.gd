class_name Enemy
extends CharacterBody3D


signal death(enemy)


@export var target: Node3D
@export var debug: bool = false

@export var wellbeing_stats: WellbeingStats

@export_category("Incoming Weapon Hit Weights")
@export var hit_weight: float = 0.4
@export var block_weight: float = 0.4
@export var parry_weight: float = 0.2

@export_category("Audio")
@export var parry_sfx: AudioStreamPlayer3D
@export var block_sfx: AudioStreamPlayer3D
@export var hit_sfx: AudioStreamPlayer3D

@export_category("Components")
@export var character: CharacterAnimations
@export var rotation_component: NPCRotationComponent
@export var head_rotation_component: HeadRotationComponent
@export var movement_component: MovementComponent
@export var root_motion_component: RootMotionComponent
@export var lock_on_component: LockOnComponent
@export var hitbox_component: HitboxComponent
@export var health_component: HealthComponent
@export var instability_component: InstabilityComponent
@export var backstab_component: BackstabComponent
@export var dizzy_component: DizzyComponent
@export var notice_component: NoticeComponent
@export var attack_component: AttackComponent
@export var block_component: BlockComponent
@export var parry_component: ParryComponent
@export var wellbeing_component: WellbeingComponent

@export_category("AI Behaviour")
@export var beehave_tree: BeehaveTree
@export var blackboard: Blackboard
@export var agent: NavigationAgent3D

var active_motion_component: MotionComponent

var _default_move_speed: float
var _dead: bool = false


@onready var player: Player = Globals.player


func _enter_tree():
	var path_names: PackedStringArray = str(get_path()).split("/")
	var beehave_name: String = path_names[-3] + "_" + path_names[-1]
	if beehave_tree == null:
		beehave_tree = get_node("BeehaveTree")
	beehave_tree.name = beehave_name


func _ready() -> void:
	target = player
	agent.target_position = target.global_position
	
	Globals.void_death_system.fallen_into_the_void.connect(
		func(body: Node3D):
			if body == self:
				health_component.deal_max_damage = true
				health_component.decrement_health(1)
				var timer: SceneTreeTimer = get_tree().create_timer(5)
				timer.timeout.connect(queue_free)
	)
	
	hitbox_component.weapon_hit.connect(
		_on_entity_hitbox_weapon_hit
	)
	
	health_component.zero_health.connect(
		_on_health_component_zero_health
	)
	
	attack_component.can_move.connect(
		func(flag: bool):
			blackboard.set_value("can_move", flag)
	)
	
	active_motion_component = movement_component
	_default_move_speed = movement_component.speed
	
	blackboard.set_value("move_speed", _default_move_speed)
	blackboard.set_value("can_attack", true)
	blackboard.set_value("dead", false)
	
	health_component.health = wellbeing_stats.initial_health
	health_component.max_health = wellbeing_stats.max_health
	instability_component.instability = wellbeing_stats.initial_instability
	instability_component.can_reduce_instability = wellbeing_stats\
		.can_reduce_instability
	wellbeing_component.setup()
	
	print(name)


func _physics_process(_delta: float) -> void:
	## Debug Components
	rotation_component.debug = debug
	movement_component.debug = debug
	backstab_component.debug = debug
	notice_component.debug = debug
	dizzy_component.debug = debug
	wellbeing_component.debug = debug
	
	blackboard.set_value("debug", debug)
	
	agent.debug_enabled = debug
	
	
	## Target Operations
	var player_dist: float = global_position.distance_to(target.global_position)
	var target_dist: float = agent.distance_to_target()
	var target_dir: Vector3 = global_position.direction_to(agent.target_position)
	var target_dir_angle: float = target_dir.angle_to(Vector3.FORWARD.rotated(Vector3.UP, global_rotation.y))
	
	blackboard.set_value("player_dist", player_dist)
	blackboard.set_value("target", target)
	blackboard.set_value("target_dist", target_dist)
	blackboard.set_value("target_dir", target_dir)
	blackboard.set_value("target_dir_angle", target_dir_angle)
	call_deferred("_set_target_reachable")
	
	if blackboard.get_value("investigate_last_agent_position"):
		blackboard.set_value("can_set_investigate_last_agent_position", false)
		blackboard.set_value("investigate_last_agent_position", false)
		blackboard.set_value(
			"agent_target_position",
			target.global_position
		)
	
	agent.target_position = blackboard.get_value(
		"agent_target_position",
		target.global_position
	)
	
	
	## Debug Prints
#	if debug:
#		prints(
#			active_motion_component,
#		)
	
	
	## Component Management
	attack_component.active_motion_component = active_motion_component
	
	rotation_component.rotate_towards_target = blackboard.get_value(
		"rotate_towards_target",
		false
	)
	
	movement_component.can_move = blackboard.get_value(
		"can_move",
		true
	)
	movement_component.speed = blackboard.get_value(
		"move_speed",
		_default_move_speed
	)
	
	backstab_component.enabled = not blackboard.get_value(
		"perceives_player",
		false
	)
	
	
	## Attacking
	if blackboard.get_value("can_attack", false) and blackboard.get_value("attack", false):
		blackboard.set_value("can_attack", false)
		blackboard.set_value("attack", false)
		attack_component.attack_level = blackboard.get_value("attack_level", 0)
		attack_component.attack()
	blackboard.set_value("attacking", attack_component.attacking)
	
	
	## Character Animations
	character.anim_tree["parameters/Locked On Walk Direction/4/TimeScale/scale"] = 0.5
	character.anim_tree["parameters/Locked On Walk Direction/5/TimeScale/scale"] = 0.5	
	character.movement_animations.move(
		blackboard.get_value("input_direction", Vector3.ZERO), 
		blackboard.get_value("locked_on", false), 
		false
	)
	
	
	## Head Rotation Component
	if blackboard.get_value("agent_target_position") == null and \
	blackboard.get_value("rotate_towards_target"):
		head_rotation_component.desired_target_pos = \
			player.lock_on_attachment_point.global_position
	else:
		head_rotation_component.desired_target_pos = Vector3.INF


func set_root_motion(flag: bool) -> void:
	if flag:
		active_motion_component = root_motion_component
		root_motion_component.enabled = true
		movement_component.enabled = false
	else:
		active_motion_component = movement_component
		root_motion_component.enabled = false
		movement_component.enabled = true


func _set_target_reachable():
	await get_tree().physics_frame
	var target_reachable: bool = agent.is_target_reachable()
	blackboard.set_value("target_reachable", target_reachable)


func _on_entity_hitbox_weapon_hit(incoming_weapon: Weapon) -> void:
	if Globals.backstab_system.backstab_victim == backstab_component:
		backstab_component.process_hit()
		health_component.damage_from_weapon(incoming_weapon)
		active_motion_component.knockback(incoming_weapon.entity.global_position)
		return
	
	if Globals.dizzy_system.dizzy_victim == dizzy_component:
		dizzy_component.process_hit(incoming_weapon)
		health_component.damage_from_weapon(incoming_weapon)
		if instability_component.full_instability_from_parry:
			active_motion_component.knockback(incoming_weapon.entity.global_position)
		return
	
	blackboard.set_value("can_attack", false)
	blackboard.set_value("attack", false)
	
	var total_weight: float = hit_weight + block_weight + parry_weight
	var rng: float = RandomNumberGenerator.new().randf() * total_weight
	
	
	if blackboard.get_value("notice_state") != "aggro" or \
	blackboard.get_value("dizzy", false):
		rng = 0.0
	
	if rng < hit_weight:
		# incoming hit goes through
		health_component.damage_from_weapon(incoming_weapon)
		instability_component.process_hit()
		
		attack_component.interrupt_attack()
		
		character.hit_and_death_animations.hit()
#		_set_agent_target_to_target = true
		
		blackboard.set_value("got_hit", true)
		blackboard.set_value("interrupt_timers", true)
		
		hit_sfx.play()
		
		if Globals.dizzy_system.dizzy_victim != dizzy_component:
			active_motion_component.knockback(incoming_weapon.entity.global_position)
		
	elif rng < hit_weight + block_weight:
		# block incoming hit
		active_motion_component.knockback(incoming_weapon.entity.global_position)
		
		block_component.blocking = true
		block_component.blocked()
		attack_component.interrupt_attack()
		
		instability_component.process_block()
		
		notice_component.transition_to_aggro()
		
		instability_component.enabled = false
		health_component.enabled = false
		
		block_sfx.play()
		
		var timer: SceneTreeTimer = get_tree().create_timer(0.3)
		timer.timeout.connect(
			func(): 
				block_component.blocking = false
				instability_component.enabled = true
				health_component.enabled = true
		)
		
	elif rng < hit_weight + block_weight + parry_weight:
		# parry incoming hit
		active_motion_component.knockback(incoming_weapon.entity.global_position)
		
		parry_component.in_parry_window = true
		parry_component.play_parry_particles()
		
		attack_component.interrupt_attack()
		
		character.parry_animations.parry()
		block_component.anim.play("parried")
		
		notice_component.transition_to_aggro()
		
		instability_component.process_parry()
		
		incoming_weapon.parry_weapon()
		
		parry_sfx.play()
		
		var timer: SceneTreeTimer = get_tree().create_timer(0.2)
		timer.timeout.connect(
			func(): 
				attack_component.attack()
		)
	


func _on_health_component_zero_health() -> void:
	if _dead:
		return
	
	set_root_motion(true)
	
	_dead = true
	
	attack_component.set_can_damage_of_weapons(false)
	
	hitbox_component.enabled = false
	health_component.enabled = false
	lock_on_component.enabled = false
	backstab_component.enabled = false
	dizzy_component.enabled = false
	rotation_component.can_rotate = false
	head_rotation_component.enabled = false
	notice_component.enabled = false
	notice_component.hide_notice_triangles()
	
	disable_mode = CollisionObject3D.DISABLE_MODE_MAKE_STATIC
	
	blackboard.set_value("dead", true)
	blackboard.set_value("interrupt_timers", true)
	
	collision_layer = 0
	collision_mask = 1
	
	if Globals.backstab_system.backstab_victim == backstab_component:
		character.hit_and_death_animations.death_2()
	elif Globals.dizzy_system.dizzy_victim == dizzy_component and \
	not dizzy_component.instability_component.full_instability_from_parry:
		character.dizzy_victim_animations.play_death_kneeling()
	else:
		character.hit_and_death_animations.death_1()
	
	if blackboard.get_value("notice_state") == "aggro":
		Globals.music_system.fade_to_idle()
	
	death.emit(self)
