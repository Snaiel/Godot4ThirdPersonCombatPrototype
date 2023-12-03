extends Node3D


@export var debug: bool = false
@export var _entity: CharacterBody3D
@export var _lock_on_component: LockOnComponent

var _angle_to_player: float = 0.0
var _dist_to_player: float = 0.0

@onready var _player: Player = Globals.player


func _ready():
	if _lock_on_component:
		position = _lock_on_component.position


func _process(_delta):
	_dist_to_player = _entity.global_position.distance_to(_player.global_position)
	_angle_to_player = rad_to_deg(
		Vector3.FORWARD.rotated(Vector3.UP, _entity.global_rotation.y).angle_to(
			_entity.global_position.direction_to(_player.global_position)
		)
	)

#	if debug: prints(_dist_to_player, _angle_to_player)
	if _angle_to_player > 125:
		if _dist_to_player < 1.5:
			Globals.user_interface.set_backstab_visible(self, true)
		else:
			Globals.user_interface.set_backstab_visible(self, false)			
	else:
		Globals.user_interface.set_backstab_visible(null, false)		
