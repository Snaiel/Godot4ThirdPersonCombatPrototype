class_name FadeComponent
extends Node3D


@export var enabled: bool = true
@export var origin_point: Node3D
@export var meshes: Array[MeshInstance3D]

@onready var cam = Globals.camera_controller.cam


# Called every frame. 'delta' is the elapsed time since the previous frame.
func _process(_delta):
	if not enabled:
		return
	
	var dist: float = origin_point.global_position.distance_to(
		cam.global_position
	)
	
	var opacity: float = clamp(dist - 0.7, 0.0, 1.0)
	
	for mesh in meshes:
		mesh.set_instance_shader_parameter("opacity", opacity)
