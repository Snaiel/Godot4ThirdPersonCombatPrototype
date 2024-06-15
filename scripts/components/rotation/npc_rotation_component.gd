class_name NPCRotationComponent
extends RotationComponent


@export var debug: bool = false
@export var movement_component: MovementComponent
@export var blackboard: Blackboard
@export var agent: NavigationAgent3D
var npc: Enemy
var speed: float = 1 # mainly for testing purporse

func _ready() -> void:
	npc = entity as Enemy
	looking_direction = looking_direction.rotated(Vector3.UP, entity.rotation.y).normalized()


func _physics_process(delta: float) -> void:
	super._physics_process(delta)
	
	if not can_rotate:
		return
	
	var _input_direction: Vector3 = blackboard.get_value("input_direction", Vector3.ZERO)
	var _can_move: bool = movement_component.can_move
	var _velocity: Vector3 = movement_component.desired_velocity

#	print(_blackboard.has_value("rotate_towards_target"))
	move_direction = _input_direction
	
	if debug:
		pass

	if rotate_towards_target:
		# get the angle towards the lock on target and
		# smoothyl rotate the player towards it
		var _next_location: Vector3
		if blackboard.get_value("target_reachable"):
			_next_location = agent.get_next_path_position()
		else:
			_next_location = npc.target.global_position
		looking_direction = entity.global_position.direction_to(_next_location)
		target_look = atan2(-looking_direction.x, -looking_direction.z)
		

		var rotation_difference: float = abs(entity.rotation.y - target_look)

		# This makes the rotation smoother when the player is locked
		# on and transitions from sprinting to walking
		var rotation_weight: float
		if rotation_difference < 0.05:
			rotation_weight = 0.2
		else:
			rotation_weight = 0.1

		entity.rotation.y = lerp_angle(entity.rotation.y, target_look, rotation_weight * speed)

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
		entity.rotation.y = lerp_angle(entity.rotation.y, target_look, 0.1 * speed)
		
		move_direction = Vector3.ZERO
		
