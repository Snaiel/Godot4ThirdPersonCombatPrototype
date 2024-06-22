class_name FadeComponent
extends Node


@export var enabled: bool = true
@export var origin_point: Node3D
@export var meshes: Array[MeshInstance3D]
@export var margin: float = 0.7
@export var min_opacity: float = 0.0

@onready var cam = Globals.camera_controller.cam


# Called every frame. 'delta' is the elapsed time since the previous frame.
func _process(_delta):
	if not enabled:
		return
	
	var dist: float = origin_point.global_position.distance_to(
		cam.global_position
	)
	
	var opacity: float = clamp(dist - margin, min_opacity, 1.0)
	
	for mesh in meshes:
		mesh.set_instance_shader_parameter("opacity", opacity)
