class_name HeadRotationComponent
extends Node3D


@export var skeleton: Skeleton3D
@export var head_idx: int = 5

@onready var target: Node3D = $LookAtTarget


func _ready():
	pass # Replace with function body.


func _process(_delta):
	skeleton.clear_bones_global_pose_override()
	
	var neck_bone_idx: int = skeleton.find_bone("Head")
	var pose: Transform3D = skeleton.get_bone_global_pose(
		neck_bone_idx
	)

	pose = pose.looking_at(
		skeleton.to_local(target.global_position),
		Vector3.UP,
		true
	)

	skeleton.set_bone_global_pose_override(
		neck_bone_idx,
		pose,
		0.8,
		true
	)
