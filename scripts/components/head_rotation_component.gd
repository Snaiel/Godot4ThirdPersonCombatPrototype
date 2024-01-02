class_name HeadRotationComponent
extends Node3D


@export var skeleton: Skeleton3D
@export var head_idx: int = 6
@export var rotation_component: RotationComponent

@onready var target: Node3D = $Target

var _default_target_pos: Vector3


func _ready():
	_default_target_pos = target.position


func _process(_delta):
	skeleton.clear_bones_global_pose_override()
	
	if rotation_component.rotate_towards_target and rotation_component.target:
		target.global_position = lerp(
			target.global_position,
			rotation_component.target.global_position,
			0.2
		)
	else:
		target.position = lerp(
			target.position,
			_default_target_pos,
			0.2
		)
	
	var pose: Transform3D = skeleton.get_bone_global_pose(
		head_idx
	)

	pose = pose.looking_at(
		skeleton.to_local(target.global_position),
		Vector3.UP,
		true
	)

	skeleton.set_bone_global_pose_override(
		head_idx,
		pose,
		0.8,
		true
	)
