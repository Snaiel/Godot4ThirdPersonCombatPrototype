class_name Enemy
extends CharacterBody3D


signal combat_interaction
signal got_hit
signal block_weapon
signal parry_weapon

signal dead

@export var debug: bool = false

@export_category("Incoming Weapon Hit Weights")
@export var hit_weight: float = 0.4
@export var block_weight: float = 0.4
@export var parry_weight: float = 0.2

@export_category("Utility")
@export var character: CharacterAnimations
@export var hitbox_component: HitboxComponent
@export var lock_on_component: LockOnComponent

@export_category("Movement")
@export var locomotion_component: LocomotionComponent

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

@export_category("AI Behaviour")
@export var beehave_tree: BeehaveTree
@export var blackboard: Blackboard
@export var navigation_agent: NavigationAgent3D

var target: Node3D


func _enter_tree():
	var path_names: PackedStringArray = str(get_path()).split("/")
	var beehave_name: String = path_names[-3] + "_" + path_names[-1]
	if beehave_tree == null:
		beehave_tree = get_node("BeehaveTree")
	beehave_tree.name = beehave_name


func _ready() -> void:
	if target == null:
		target = Globals.player
	
	hitbox_component.weapon_hit.connect(_on_hitbox_component_weapon_hit)
	health_component.zero_health.connect(_on_health_component_zero_health)
	
	blackboard.set_value("move_speed", 3)
	blackboard.set_value("can_attack", true)
	blackboard.set_value("dead", false)
	
	print(name)


func _physics_process(_delta: float) -> void:
	
	blackboard.set_value("debug", debug)
	navigation_agent.debug_enabled = debug
	
	#if debug:
		#prints(
			#notice_component.current_state
		#)
	
	
	## Target
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
	character.anim_tree["parameters/Locked On Walk Direction/4/TimeScale/scale"] = 0.5
	character.anim_tree["parameters/Locked On Walk Direction/5/TimeScale/scale"] = 0.5
	character.movement_animations.move(
		blackboard.get_value("input_direction", Vector3.ZERO), 
		blackboard.get_value("locked_on", false), 
		false
	)
	
	## Navigation Agent
	blackboard.set_value("agent_target_dist", navigation_agent.distance_to_target())
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
	blackboard.set_value("agent_target_reachable", navigation_agent.is_target_reachable())


func _on_hitbox_component_weapon_hit(incoming_weapon: Weapon) -> void:
	if Globals.backstab_system.backstab_victim == backstab_component:
		backstab_component.process_hit()
		health_component.damage_from_weapon(incoming_weapon)
		locomotion_component.knockback(incoming_weapon.entity.global_position)
		return
	
	if Globals.dizzy_system.dizzy_victim == dizzy_component:
		dizzy_component.process_hit(incoming_weapon)
		health_component.damage_from_weapon(incoming_weapon)
		if instability_component.full_instability_from_parry:
			locomotion_component.knockback(incoming_weapon.entity.global_position)
		return
	
	combat_interaction.emit()
	
	blackboard.set_value("interrupt_timers", true)
	blackboard.set_value("can_attack", false)
	blackboard.set_value("attack", false)
	
	var total_weight: float = hit_weight + block_weight + parry_weight
	var rng: float = RandomNumberGenerator.new().randf() * total_weight
	
	if blackboard.get_value("notice_state") != "aggro" or \
	blackboard.get_value("dizzy", false):
		rng = 0.0
	
	locomotion_component.knockback(incoming_weapon.entity.global_position)
	notice_component.transition_to_aggro()
	
	if rng < hit_weight:
		# incoming hit goes through
		got_hit.emit()
		blackboard.set_value("got_hit", true)
		health_component.damage_from_weapon(incoming_weapon)
		instability_component.process_hit()
	elif rng < hit_weight + block_weight:
		# block incoming hit
		block_weapon.emit()
		instability_component.process_block()
		instability_component.enabled = false
		health_component.enabled = false
		get_tree().create_timer(0.3).timeout.connect(
			func():
				instability_component.enabled = true
				health_component.enabled = true
		)
	elif rng < hit_weight + block_weight + parry_weight:
		# parry incoming hit
		parry_weapon.emit()
		instability_component.process_parry()
		incoming_weapon.parry_weapon()


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
	
	dead.emit()
