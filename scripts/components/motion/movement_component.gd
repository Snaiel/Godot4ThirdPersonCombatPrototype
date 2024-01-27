class_name MovementComponent
extends MotionComponent


@export var speed: float = 0.0


func handle_movement(_delta: float) -> void:
	if not enabled:
		return
	
	move_direction = rotation_component.move_direction
	looking_direction = rotation_component.looking_direction
	
	if can_move:
		if move_direction.length() > 0.05:
			
			var weight: float = 0.4 if entity.is_on_floor() else 0.2
			
			desired_velocity = desired_velocity.move_toward(
				Vector3(
					move_direction.x * speed,
					desired_velocity.y,
					move_direction.z * speed
				),
				weight
			)
			
		elif entity.is_on_floor():
			# if coming from a jump, quickly come to a stop.
			# otherwise, if just going from walking/runnning to a stop,
			# come to a gentle stop
			var weight: float = 0.4 if vertical_movement else 0.2
			
			desired_velocity = desired_velocity.move_toward(
				Vector3(
					0,
					desired_velocity.y,
					0
				),
				weight
			)
			
			if can_disable_vertical_movement and \
			Vector2(
				desired_velocity.x, 
				desired_velocity.z
			).length() < 0.05:
				
				vertical_movement = false
				can_disable_vertical_movement = false
