class_name Checkpoint
extends StaticBody3D


@export var max_distance: float = 2.0
@export var max_angle: float = 90.0

var _dist_to_player: float
var _player_angle: float

var _show_hint: bool
var _previous_show_hint_value: bool = _show_hint

@onready var player: Player = Globals.player
@onready var checkpoint_system: CheckpointSystem = Globals.checkpoint_system


func _process(_delta):
	_dist_to_player = global_position.distance_to(
		player.global_position
	)
	
	_player_angle = rad_to_deg(
			Vector3.FORWARD.rotated(Vector3.UP, player.global_rotation.y).angle_to(
				player.global_position.direction_to(global_position)
		)
	)
	
	if _dist_to_player < max_distance and \
	_player_angle < max_angle:
		_show_hint = true
	else:
		_show_hint = false
	
	if _show_hint == true and \
	_previous_show_hint_value == false:
		checkpoint_system.player_close_to_checkpoint()
	elif _show_hint == false and \
	_previous_show_hint_value == true:
		checkpoint_system.player_far_from_checkpoint()
	
	_previous_show_hint_value = _show_hint 
