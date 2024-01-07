class_name MovementComponent
extends MotionComponent


@export var speed: float = 0.0


func handle_movement(_delta: float) -> void:
	if not enabled:
		return
	
	move_direction = rotation_component.move_direction
	looking_direction = rotation_component.looking_direction
	
#	if debug:
#		print(_got_hit)
#		prints(get_parent().name, desired_velocity, vertical_movement)
#		print(_secondary_movement_direction, " ", _secondary_movement_speed, " ", _secondary_movement_friction)
	
	if can_move:
		if move_direction.length() > 0.05:
			var weight: float = 0.2 if entity.is_on_floor() else 0.1
			desired_velocity.z = lerp(desired_velocity.z, move_direction.z * speed, weight)
			desired_velocity.x = lerp(desired_velocity.x, move_direction.x * speed, weight)
		elif entity.is_on_floor():
			# if coming from a jump, quickly come to a stop.
			# otherwise, if just going from walking/runnning to a stop,
			# come to a gentle stop
			var weight: float = 0.3 if vertical_movement else 0.05
			
			desired_velocity.x = lerp(desired_velocity.x, 0.0, weight)
			desired_velocity.z = lerp(desired_velocity.z, 0.0, weight)
			
			if can_disable_vertical_movement and \
				Vector2(
						desired_velocity.x, 
						desired_velocity.z
				).length() < 0.05:
				
				vertical_movement = false
				can_disable_vertical_movement = false
