extends Node3D


@export var meshes: Array[MeshInstance3D]
@export var entity: Node3D

@onready var cam = Globals.camera_controller.cam


# Called every frame. 'delta' is the elapsed time since the previous frame.
func _process(_delta):
	var dist: float = entity.global_position.distance_to(cam.global_position)

	var opacity: float = clamp(dist - 0.7, 0.0, 1.0)
	
	for mesh in meshes:
		mesh.set_instance_shader_parameter("opacity", opacity)
