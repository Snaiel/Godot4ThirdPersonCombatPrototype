class_name BackstabComponent
extends Node3D


@export var debug: bool = false
@export var enabled: bool = true
@export var entity: CharacterBody3D
@export var lock_on_component: LockOnComponent
@export var health_component: HealthComponent
@export var notice_component: NoticeComponent
@export var puncture_sound: AudioStreamPlayer3D

var _dist_to_player: float = 0.0
var _angle_to_player: float = 0.0
var _angle_to_entity: float = 0.0

@onready var _player: Player = Globals.player
@onready var _backstab_system: BackstabSystem = Globals.backstab_system


func _process(_delta):
	if lock_on_component:
		position = lock_on_component.position
	
	if not enabled:
		return
	
	_dist_to_player = entity.global_position.distance_to(_player.global_position)
	
	_angle_to_player = rad_to_deg(
		Vector3.FORWARD.rotated(Vector3.UP, entity.global_rotation.y).angle_to(
			entity.global_position.direction_to(_player.global_position)
		)
	)
	
	_angle_to_entity = rad_to_deg(
			Vector3.FORWARD.rotated(Vector3.UP, _player.global_rotation.y).angle_to(
				_player.global_position.direction_to(entity.global_position)
		)
	)

#	if debug: prints(_dist_to_player, _angle_to_player, _angle_to_entity)

	if _dist_to_player < 1.5 and _angle_to_player > 125 and _angle_to_entity < 80:
		_backstab_system.set_backstab_victim(self, _dist_to_player)
	else:
		_backstab_system.clear_backstab_victim(self)


func being_backstabbed() -> bool:
	return _backstab_system.backstab_victim == self


func process_hit() -> void:
	if being_backstabbed():
		puncture_sound.play()
		health_component.deal_max_damage = true
		entity.rotation.y = _player.rotation.y
