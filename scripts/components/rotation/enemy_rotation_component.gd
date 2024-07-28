class_name EnemyRotationComponent
extends RotationComponent


@export var debug: bool = false
@export var locomotion_component: LocomotionComponent
@export var blackboard: Blackboard
@export var agent: NavigationAgent3D
@export var use_agent_path: bool = true

var enemy: Enemy

var _saved_agent_next_path_position: Vector3 = Vector3.ZERO
var _frames_between_agent_call: int = 20
var _frames_since_last_call: int


func _ready() -> void:
	enemy = entity as Enemy
	looking_direction = looking_direction.rotated(
		Vector3.UP,
		entity.rotation.y
	).normalized()
	
	_frames_since_last_call = RandomNumberGenerator.new()\
		.randi_range(0, _frames_between_agent_call)


func _physics_process(delta: float) -> void:
	super(delta)
	
	if not can_rotate: return
	
	var _input_direction: Vector3 = blackboard.get_value(
		"input_direction",
		Vector3.ZERO
	)
	
	move_direction = _input_direction
	
	if debug:
		pass
	
	if rotate_towards_target:
		# get the angle towards the target and smoothly rotate towards it
		
		if _frames_since_last_call <= 0:
			if use_agent_path: _saved_agent_next_path_position = \
				agent.get_next_path_position()
			_frames_since_last_call = _frames_between_agent_call
		_frames_since_last_call -= 1
		
		var _next_location: Vector3
		
		if use_agent_path and blackboard.get_value("agent_target_reachable"):
			_next_location = _saved_agent_next_path_position
		else:
			_next_location = enemy.target.global_position
		
		looking_direction = entity.global_position.direction_to(_next_location)
		target_look = atan2(-looking_direction.x, -looking_direction.z)
		
		var rotation_difference: float = abs(entity.rotation.y - target_look)
		
		# smooth rotation of larger difference
		var rotation_weight: float
		rotation_weight = 0.2 if rotation_difference < 0.05 else 0.1
		
		entity.rotation.y = lerp_angle(
			entity.rotation.y,
			target_look,
			rotation_weight
		)
		
		# change move direction so it orbits the locked on target
		# (not a perfect orbit, needs tuning but not unplayable)
		if move_direction.length() > 0.2:
			move_direction = move_direction.rotated(
				Vector3.UP,
				entity.rotation.y + sign(move_direction.x) * 0.02
			).normalized()
		
	elif _input_direction.length() > 0.2:
		
		looking_direction = lerp(
			Vector3.FORWARD.rotated(
				Vector3.UP,
				get_parent().global_rotation.y
			),
			_input_direction.rotated(
				Vector3.UP,
				get_parent().global_rotation.y
			),
			0.15
		)
		
		target_look = atan2(-looking_direction.x, -looking_direction.z)
		entity.rotation.y = lerp_angle(
			entity.rotation.y,
			target_look,
			0.1
		)
		
		move_direction = Vector3.ZERO


func set_rotate_towards_target(value: bool) -> void:
	if value == rotate_towards_target: return
	if rotate_towards_target == false and value == true and use_agent_path:
		_saved_agent_next_path_position = agent.get_next_path_position()
		_frames_since_last_call = _frames_between_agent_call
	rotate_towards_target = value
