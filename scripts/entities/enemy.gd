class_name Enemy
extends CharacterBody3D


signal dead


@export var debug: bool = false

@export_category("Utility")
@export var character: CharacterAnimations
@export var hitbox_component: HitboxComponent
@export var lock_on_component: LockOnComponent

@export_category("Movement")
@export var locomotion_component: LocomotionComponent
@export var movement_animations: MovementAnimations

@export_category("Rotation")
@export var rotation_component: RotationComponent
@export var head_rotation_component: HeadRotationComponent

@export_category("Wellbeing")
@export var health_component: HealthComponent
@export var instability_component: InstabilityComponent

@export_category("Combat")
@export var backstab_component: BackstabComponent
@export var dizzy_component: DizzyComponent
@export var notice_component: NoticeComponent
@export var dizzy_victim_animations: DizzyVictimAnimations
@export var hit_and_death_animations: HitAndDeathAnimations

@export_category("AI Behaviour")
@export var beehave_tree: BeehaveTree
@export var blackboard: Blackboard
@export var navigation_agent: NavigationAgent3D

@export var patrol: PathFollow3D

var target: Node3D


func _enter_tree():
	var path_names: PackedStringArray = str(get_path()).split("/")
	var beehave_name: String = path_names[-3] + "_" + path_names[-1]
	if beehave_tree == null:
		beehave_tree = get_node("BeehaveTree")
	beehave_tree.name = beehave_name


func _ready() -> void:
	if patrol:
		target = patrol
		patrol.move.connect(
			func(flag: bool): blackboard.set_value("patrol_move", flag)
		)
	else:
		target = Globals.player
	
	health_component.zero_health.connect(_on_health_component_zero_health)
	
	blackboard.set_value("move_speed", 3)
	blackboard.set_value("can_attack", true)
	blackboard.set_value("dead", false)
	
	print(name)


func _physics_process(_delta: float) -> void:
	
	blackboard.set_value("debug", debug)
	navigation_agent.debug_enabled = debug
	
	if debug:
		prints(
			navigation_agent.distance_to_target()
		)
	
	## Target
	_set_target_values()
	
	## Navigation Agent
	_set_agent_values()
	
	## Patrol
	if patrol: blackboard.set_value(
		"patrol_dist",
		global_position.distance_to(patrol.global_position)
	)
	
	## Locomotion Component
	locomotion_component.can_move = blackboard.get_value(
		"can_move",
		true
	)
	locomotion_component.speed = blackboard.get_value(
		"move_speed",
		locomotion_component.default_speed
	)
	
	## Rotation Component
	rotation_component.rotate_towards_target = blackboard.get_value(
		"rotate_towards_target",
		false
	)
	
	## Head Rotation Component
	head_rotation_component.enabled = blackboard.get_value(
		"head_rotation_enabled",
		false
	)
	if blackboard.get_value("agent_target_position") == null and \
	blackboard.get_value("rotate_towards_target"):
		if target == Globals.player:
			head_rotation_component.desired_target_pos = \
				Globals.player.lock_on_attachment_point.global_position
		else:
			head_rotation_component.desired_target_pos = target.global_position
	else:
		head_rotation_component.desired_target_pos = Vector3.INF
	
	## Backstab Component
	backstab_component.enabled = not blackboard.get_value(
		"perceives_player",
		false
	)
	
	## Character Animations
	character.anim_tree.set(&"parameters/Locked On Walk Direction/4/TimeScale/scale", 0.5)
	character.anim_tree.set(&"parameters/Locked On Walk Direction/5/TimeScale/scale", 0.5)
	character.anim_tree.set(&"parameters/Locked On Walk Speed/scale", 0.6)
	movement_animations.move(
		blackboard.get_value("input_direction", Vector3.ZERO), 
		blackboard.get_value("locked_on", false), 
		false
	)


func switch_target(player: bool) -> void:
	target = Globals.player as Node3D if player else patrol as Node3D
	_set_target_values()
	_set_agent_values()


func _set_target_values() -> void:
	var target_dist: float = global_position.distance_to(target.global_position)
	var target_dir: Vector3 = global_position.direction_to(target.global_position)
	var target_dir_angle: float = target_dir.angle_to(
		Vector3.FORWARD.rotated(
			Vector3.UP,
			global_rotation.y
		)
	)
	blackboard.set_value("target", target)
	blackboard.set_value("target_dist", target_dist)
	blackboard.set_value("target_dir", target_dir)
	blackboard.set_value("target_dir_angle", target_dir_angle)


func _set_agent_values() -> void:
	blackboard.set_value(
		"agent_target_dist",
		navigation_agent.distance_to_target()
	)
	call_deferred("_set_agent_target_reachable")
	if blackboard.get_value("investigate_last_agent_position"):
		blackboard.set_value("can_set_investigate_last_agent_position", false)
		blackboard.set_value("investigate_last_agent_position", false)
		blackboard.set_value(
			"agent_target_position",
			target.global_position
		)
	navigation_agent.target_position = blackboard.get_value(
		"agent_target_position",
		target.global_position
	)


func _set_agent_target_reachable():
	await get_tree().physics_frame
	blackboard.set_value(
		"agent_target_reachable",
		navigation_agent.is_target_reachable()
	)


func _on_health_component_zero_health() -> void:
	locomotion_component.set_active_strategy("root_motion")
	
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
	beehave_tree.interrupt()
	
	collision_layer = 0
	collision_mask = 1
	
	if Globals.backstab_system.backstab_victim == backstab_component:
		hit_and_death_animations.death_2()
	elif Globals.dizzy_system.dizzy_victim == dizzy_component and \
	not dizzy_component.instability_component.full_instability_from_parry:
		dizzy_victim_animations.play_death_kneeling()
	else:
		hit_and_death_animations.death_1()
	
	if blackboard.get_value("notice_state") == "aggro":
		Globals.music_system.fade_to_idle()
	
	dead.emit()
