extends Node3D


@export var notice_triangle: PackedScene

var _notice_triangle_sprite: Sprite2D 

@onready var camera: Camera3D = Globals.camera_controller.cam


func _ready() -> void:
	_notice_triangle_sprite = notice_triangle.instantiate()
	Globals.user_interface.notice_triangles.add_child(_notice_triangle_sprite)


func _process(_delta) -> void:
	if camera.is_position_in_frustum(global_position):
		_notice_triangle_sprite.position = camera.unproject_position(global_position)
		_notice_triangle_sprite.visible = true		
	else:
		_notice_triangle_sprite.visible = false
