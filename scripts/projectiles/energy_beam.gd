extends NonMeleeActionEffect


@export var projectile_scene: PackedScene
@export var delay: float = 0.05


var _enabled: bool = false

@onready var _current_delay_val: float = delay


func _process(delta: float):
	if not _enabled: return
	
	if _current_delay_val > 0:
		_current_delay_val -= delta
	else:
		shoot()
		_current_delay_val = delay 


func effect() -> void:
	_enabled = true


func end() -> void:
	_enabled = false


func shoot() -> void:
	var projectile: Projectile = projectile_scene.instantiate()
	projectile.entity = entity
	add_child(projectile)
	
	projectile.speed = 15
	
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
