class_name ProgrammaticMovementLocomotionStrategy
extends LocomotionStrategy


@export var rotation_component: RotationComponent


func handle_movement(_delta: float) -> void:
	
	if not context.can_move: return
	
	var move_direction: Vector3 = rotation_component.move_direction
	if move_direction.length() > 0.05:
		
		var weight: float = 0.4 if context.entity.is_on_floor() else 0.2
		
		context.desired_velocity = context.desired_velocity.move_toward(
			Vector3(
				rotation_component.move_direction.x * context.speed,
				context.desired_velocity.y,
				rotation_component.move_direction.z * context.speed
			),
			weight
		)
	elif context.entity.is_on_floor():
		# if coming from a jump, quickly come to a stop.
		# otherwise, if just going from walking/runnning to a stop,
		# come to a gentle stop
		var weight: float = 1.0 if context. vertical_movement else 0.2
		
		context.desired_velocity = context.desired_velocity.move_toward(
			Vector3(
				0,
				context.desired_velocity.y,
				0
			),
			weight
		)
		
		if context.can_disable_vertical_movement and \
		Vector2(
			context.desired_velocity.x, 
			context.desired_velocity.z
		).length() < 0.05:
			
			context.vertical_movement = false
			context.can_disable_vertical_movement = false
