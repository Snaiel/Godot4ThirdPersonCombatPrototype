class_name Enemy
extends CharacterBody3D

signal death(enemy)

@export var target: Node3D
@export var debug: bool = false
@export var friction: float = 0.05

# Get the gravity from the project settings to be synced with RigidBody nodes.
var gravity: float = ProjectSettings.get_setting("physics/3d/default_gravity")

@onready var _blackboard: Blackboard = $Blackboard
@onready var _character: PlayerAnimations = $Model
@onready var _rotation_component: RotationComponent = $EnemyRotationComponent
@onready var _movement_component: MovementComponent = $MovementComponent
@onready var _health_compoennt: HealthComponent = $HealthComponent
@onready var _backstab_component: BackstabComponent = $BackstabComponent
@onready var _notice_component: NoticeComponent = $NoticeComponent
@onready var _agent: NavigationAgent3D = $NavigationAgent3D

var _default_move_speed: float
var _dead: bool = false

func _ready() -> void:
	target = Globals.player
	_agent.target_position = target.global_position	
	_rotation_component.target = target
	
	_default_move_speed = _movement_component.speed
	_blackboard.set_value("move_speed", _default_move_speed)
	
	_rotation_component.debug = debug
	_movement_component.debug = debug
	_backstab_component.debug = debug
	_notice_component.debug = debug
	
	_notice_component.state_changed.connect(
		func(new_state: NoticeComponent.NoticeState, position_to_check: Vector3): 
			print(new_state)
			var val: bool = new_state == NoticeComponent.NoticeState.SUSPICIOUS
			_blackboard.set_value("locked_on", val)
			_blackboard.set_value("suspicious", val)
			_blackboard.set_value("look_at_target", val)
			if position_to_check != Vector3.ZERO:
				_agent.target_position = position_to_check
	)
	
	_blackboard.set_value("debug", debug)	
	_blackboard.set_value("notice_player", false)
	_blackboard.set_value("dead", false)


func _physics_process(_delta: float) -> void:

	var target_dist: float = _agent.distance_to_target()
	var target_dir: Vector3 = global_position.direction_to(_agent.target_position)
	var target_dir_angle: float = target_dir.angle_to(Vector3.FORWARD.rotated(Vector3.UP, global_rotation.y))

	_blackboard.set_value("target", target)
	_blackboard.set_value("target_dist", target_dist)
	_blackboard.set_value("target_dir", target_dir)
	_blackboard.set_value("target_dir_angle", target_dir_angle)

#	if debug:
#		prints(
#			_blackboard.get_value("input_direction"),
#			_blackboard.get_value("locked_on"),
#			_blackboard.get_value("look_at_target")
#		)
	
	_rotation_component.look_at_target = _blackboard.get_value("look_at_target", false)
	_movement_component.speed = _blackboard.get_value("move_speed", _default_move_speed)

	_character.anim_tree["parameters/Lock On Walk/4/TimeScale/scale"] = 0.5
	_character.anim_tree["parameters/Lock On Walk/5/TimeScale/scale"] = 0.5	
	_character.movement_animations.move(
		_blackboard.get_value("input_direction", Vector3.ZERO), 
		_blackboard.get_value("locked_on", false), 
		false
	)


func _on_entity_hitbox_weapon_hit(weapon: Sword) -> void:
	var opponent_position: Vector3 = weapon.get_entity().global_position
	var direction: Vector3 = global_position.direction_to(opponent_position)
	_movement_component.set_secondary_movement(weapon.get_knockback(), 5, 5, -direction)
	_blackboard.set_value("notice_player", true)


func _on_health_component_zero_health() -> void:
	if _dead:
		return
	
	death.emit(self)
	_dead = true
	_health_compoennt.active = false
	
	_blackboard.set_value("dead", true)
	_blackboard.set_value("interrupt_timers", true)
	
	collision_layer = 0
	collision_mask = 1
	
	if Globals.backstab_system.backstab_victim == _backstab_component:
		_character.anim_tree["parameters/Death/transition_request"] = "backstab"
	else:
		_character.anim_tree["parameters/Death/transition_request"] = "dead"
