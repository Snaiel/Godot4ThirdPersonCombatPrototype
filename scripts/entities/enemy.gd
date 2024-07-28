class_name Enemy
extends CharacterBody3D


signal dead


@export var debug: bool = false
@export var patrol: PathFollow3D

@onready var character: CharacterAnimations = $Character
@onready var hitbox_component: HitboxComponent = $HitboxComponent
@onready var lock_on_component: LockOnComponent = $Utility/LockOnComponent

@onready var locomotion_component: LocomotionComponent = $LocomotionComponent
@onready var idle_animations: IdleAnimations = $Character/Animations/Idle
@onready var movement_animations: MovementAnimations = $Character/Animations/Movement

@onready var rotation_component: RotationComponent = $Rotation/RotationComponent
@onready var head_rotation_component: HeadRotationComponent = $Rotation/HeadRotationComponent

@onready var wellbeing_component: WellbeingComponent = $Wellbeing/WellbeingComponent
@onready var health_component: HealthComponent = $Wellbeing/HealthComponent
@onready var instability_component: InstabilityComponent = $Wellbeing/InstabilityComponent

@onready var backstab_component: BackstabComponent = $Combat/BackstabComponent
@onready var dizzy_component: DizzyComponent = $Combat/DizzyComponent
@onready var notice_component: NoticeComponent = $Combat/NoticeComponent
@onready var dizzy_victim_animations: DizzyVictimAnimations = $Character/Animations/DizzyVictim
@onready var hit_and_death_animations: HitAndDeathAnimations = $Character/Animations/HitAndDeath

@onready var visibility_notifier: VisibleOnScreenNotifier3D = $Utility/VisibilityNotifier

var beehave_tree: BeehaveTree
@onready var blackboard: Blackboard = $Blackboard
@onready var navigation_agent: NavigationAgent3D = $NavigationAgent

var is_dead: bool = false

var target: Node3D
var original_position: Vector3

var saved_locomotion_stragey: String


func _enter_tree():
	var path_names: PackedStringArray = str(get_path()).split("/")
	var beehave_name: String = path_names[-3] + "_" + path_names[-1]
	if beehave_tree == null:
		beehave_tree = get_node("BeehaveTree")
	beehave_tree.name = beehave_name


func _exit_tree():
	notice_component.hide_notice_triangles()
	wellbeing_component.hide_wellbeing_widget()


func _ready() -> void:
	if patrol:
		target = patrol
		patrol.move.connect(
			func(flag: bool): blackboard.set_value("patrol_move", flag)
		)
	else:
		target = Globals.player
	
	original_position = global_position
	blackboard.set_value("original_position", original_position)
	blackboard.set_value("original_rotation", rotation.y)
	
	health_component.zero_health.connect(_on_health_component_zero_health)
	
	blackboard.set_value("move_speed", 3)
	blackboard.set_value("can_attack", true)
	
	visibility_notifier.screen_entered.connect(
		func():
			locomotion_component.can_change_state = true
			locomotion_component.set_active_strategy(saved_locomotion_stragey)
	)
	visibility_notifier.screen_exited.connect(
		func():
			var old_strat: LocomotionStrategy = locomotion_component\
				.active_strategy
			saved_locomotion_stragey = old_strat.strategy_name
			if old_strat is RootMotionLocomotionStrategy and \
			blackboard.get_value(
				"input_direction", Vector3.ZERO
			).length() > 0.1:
				blackboard.set_value(
					"move_speed",
					old_strat.root_motion_speed
				)
			locomotion_component.set_active_strategy("programmatic")
			locomotion_component.can_change_state = false
	)
	
	character.anim_player.active = false
	character.anim_tree.active = false
	locomotion_component.set_active_strategy("programmatic")
	locomotion_component.can_change_state = false
	
	print(name)


func _physics_process(_delta: float) -> void:
	
	blackboard.set_value("debug", debug)
	navigation_agent.debug_enabled = debug
	
	#if debug:
		#prints(
			#blackboard.get_value("idle")
		#)
	
	if is_dead: return
	
	if blackboard.get_value("idle") and \
	blackboard.get_value("notice_state") == "idle":
		if beehave_tree.enabled: beehave_tree.disable()
		return
	elif not beehave_tree.enabled:
		beehave_tree.enable()
	
	## Target
	_set_target_values()
	
	## Navigation Agent
	_set_agent_values()
	
	blackboard.set_value(
		"dist_original_position",
		global_position.distance_to(original_position)
	)
	
	## Patrol
	blackboard.set_value("patrol", patrol != null)
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
	locomotion_component.set_active_strategy(
		blackboard.get_value("locomotion_strategy", "root_motion")
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
	movement_animations.set_state(
		blackboard.get_value(
			"anim_move_state",
			"walk"
		)
	)
	movement_animations.speed = blackboard.get_value(
		"anim_move_speed",
		1.0
	)
	movement_animations.dir = blackboard.get_value(
		"input_direction",
		Vector3.ZERO
	)
	idle_animations.active = blackboard.get_value(
		"locked_on",
		false
	)


func switch_target(player: bool) -> void:
	if patrol and not player:
		target = patrol as Node3D
	else:
		target = Globals.player as Node3D
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
		get_tree().create_timer(0.5).timeout.connect(
			func():
				blackboard.set_value(
					"agent_target_position",
					target.global_position
				)
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
	is_dead = true
	dead.emit()
	
	locomotion_component.set_active_strategy("root_motion")
	locomotion_component.can_move = true
	
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
	
	blackboard.set_value("input_direction", Vector3.ZERO)
	beehave_tree.interrupt()
	beehave_tree.disable()
	
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
	
	character.can_set_anim_tree_active = false
	
	get_tree().create_timer(5.0).timeout.connect(
		func(): character.anim_tree.active = false
	)
