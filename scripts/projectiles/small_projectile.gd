extends NonMeleeActionEffect


@export var projectile_scene: PackedScene


func effect() -> void:
	var projectile: Projectile = projectile_scene.instantiate()
	projectile.entity = entity
	add_child(projectile)
	
	projectile.speed = 20
	
	projectile.global_position = entity\
		.lock_on_component\
		.attachment_point\
		.global_position
	
	var target_pos: Vector3
	if entity.target is Player:
		target_pos = entity.target.lock_on_attachment_point.global_position
	else:
		target_pos = entity.target.global_positio
	
	projectile.direction = entity.lock_on_component.attachment_point.global_position.direction_to(target_pos)
	projectile.look_at(entity.target.global_position)


func end() -> void:
	pass
