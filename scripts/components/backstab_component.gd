class_name BackstabComponent
extends Node3D


@export var debug: bool = false
@export var entity: CharacterBody3D
@export var _lock_on_component: LockOnComponent

var _angle_to_player: float = 0.0
var _dist_to_player: float = 0.0

@onready var _player: Player = Globals.player
@onready var _backstab_system = Globals.backstab_system

func _ready():
	if _lock_on_component:
		position = _lock_on_component.position


func _process(_delta):
	_dist_to_player = entity.global_position.distance_to(_player.global_position)
	_angle_to_player = rad_to_deg(
		Vector3.FORWARD.rotated(Vector3.UP, entity.global_rotation.y).angle_to(
			entity.global_position.direction_to(_player.global_position)
		)
	)

#	if debug: prints(_dist_to_player, _angle_to_player)
	if _angle_to_player > 125 and _dist_to_player < 1.5:
		_backstab_system.set_backstab_victim(self, _dist_to_player)
	else:
		_backstab_system.clear_backstab_victim(self)
