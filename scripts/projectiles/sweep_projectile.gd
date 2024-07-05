extends NonMeleeActionEffect


@export var projectile_scene: PackedScene


func effect() -> void:
	var pos: Vector3 = entity\
		.lock_on_component\
		.attachment_point\
		.global_position
	var target_pos: Vector3
	if entity.target is Player:
		target_pos = entity.target.lock_on_attachment_point.global_position
	else:
		target_pos = entity.target.global_position
	
	shoot(pos, Vector3(3, 0, 0.6), target_pos)
	shoot(pos, Vector3(2.5, 0, 0.5), target_pos)
	shoot(pos, Vector3(2, 0, 0.4), target_pos)
	shoot(pos, Vector3(1.5, 0, 0.3), target_pos)
	shoot(pos, Vector3(1, 0, 0.2), target_pos)
	shoot(pos, Vector3(0.5, 0, 0.1), target_pos)
	shoot(pos, Vector3.ZERO, target_pos)
	shoot(pos, Vector3(-0.5, 0, 0.1), target_pos)
	shoot(pos, Vector3(-1, 0, 0.2), target_pos)
	shoot(pos, Vector3(-1.5, 0, 0.3), target_pos)
	shoot(pos, Vector3(-2, 0, 0.4), target_pos)
	shoot(pos, Vector3(-2.5, 0, 0.5), target_pos)
	shoot(pos, Vector3(-3, 0, 0.6), target_pos)



func shoot(pos: Vector3, offset: Vector3, target_pos: Vector3) -> void:
	var projectile: Projectile = projectile_scene.instantiate()
	projectile.entity = entity
	add_child(projectile)
	
	projectile.parried.connect(
		entity.instability_component.got_parried.bind(20)
	)
	
	projectile.speed = 5
	
	var dir: Vector3 = entity\
		.lock_on_component\
		.attachment_point\
		.global_position\
		.direction_to(target_pos)
	projectile.direction = dir
	
	var r: float = atan2(-dir.x, -dir.z)
	projectile.rotation.y = r
	
	projectile.global_position = pos
	projectile.position += offset.rotated(Vector3.UP, r)
