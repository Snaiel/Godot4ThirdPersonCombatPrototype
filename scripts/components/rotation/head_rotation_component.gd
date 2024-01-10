class_name HeadRotationComponent
extends Node3D


@export var debug: bool = false
@export var enabled: bool = true
@export var target_visible: bool = false
@export var skeleton: Skeleton3D
@export var head_idx: int = 6
@export var rotation_component: RotationComponent
@export var head_attachment_target: Node3D

var desired_target_pos: Vector3 = Vector3.INF

var _default_target_pos: Vector3
var _last_enabled_value: bool = enabled

@onready var _target: Node3D = $Target


func _ready():
	_default_target_pos = _target.position


func _physics_process(_delta):
	_target.visible = target_visible
	
	skeleton.clear_bones_global_pose_override()
	
	var pose: Transform3D = skeleton.get_bone_global_pose(
		head_idx
	)
	
	if not enabled:
		_target.global_position = head_attachment_target.global_position
		return
	
	if desired_target_pos != Vector3.INF:
		_target.global_position = lerp(
			_target.global_position,
			desired_target_pos,
			0.02
		)
	else:
		_target.position = lerp(
			_target.position,
			_default_target_pos,
			0.01
		)
	
	pose = pose.looking_at(
		skeleton.to_local(_target.global_position),
		Vector3.UP,
		true
	)
	
	skeleton.set_bone_global_pose_override(
		head_idx,
		pose,
		0.8,
		true
	)
	
	_last_enabled_value = enabled
