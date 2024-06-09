class_name Checkpoint
extends StaticBody3D


@export var max_angle: float = 90.0

var can_sit_at_checkpoint: bool

var _player_inside: bool
var _player_angle: float

var _can_set_current_checkpoint: bool
var _previously_enabled_hint: bool

@onready var respawn_point: Node3D = $RespawnPoint

@onready var _area: Area3D = $Area3D
@onready var _recovery_particles: GPUParticles3D = $RecoveryParticles
@onready var _recovery_audio: AudioStreamPlayer3D = $AudioRecover

@onready var _player: Player = Globals.player
@onready var _checkpoint_system: CheckpointSystem = Globals.checkpoint_system


func _ready() -> void:
	respawn_point.visible = false
	
	_area.body_entered.connect(
		func(_body: Node3D):
			_player_inside = true
			_can_set_current_checkpoint = true
	)
	
	_area.body_exited.connect(
		func(_body: Node3D):
			_player_inside = false
			_can_set_current_checkpoint = true
	)


func _physics_process(_delta: float) -> void:
	
	_player_angle = rad_to_deg(
			Vector3.FORWARD.rotated(Vector3.UP, _player.global_rotation.y).angle_to(
				_player.global_position.direction_to(global_position)
		)
	)
	
	if _can_set_current_checkpoint:
		_can_set_current_checkpoint = false
		if _player_inside:
			_checkpoint_system.current_checkpoint = self
	
	if _player_inside:
		if _player_angle < max_angle and \
		not _previously_enabled_hint and \
		_player.is_on_floor() and \
		_player.aggro_enemy_counter == 0:
			can_sit_at_checkpoint = true
			_checkpoint_system.enable_hint()
			_previously_enabled_hint = true
		elif (
			_player_angle >= max_angle or \
			not _player.is_on_floor()
		) and _previously_enabled_hint:
			can_sit_at_checkpoint = false
			_checkpoint_system.disable_hint()
			_previously_enabled_hint = false


func play_recovery_particles() -> void:
	_recovery_particles.restart()
	_recovery_audio.play()
