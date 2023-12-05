extends Node3D


@export var debug: bool
@export var notice_triangle: PackedScene

var _notice_val: float = 0.0
var _notice_triangle_sprite: Sprite2D 

@onready var _entity: CharacterBody3D = get_parent()
@onready var _player: Player = Globals.player
@onready var _camera: Camera3D = Globals.camera_controller.cam


func _ready() -> void:
	_notice_triangle_sprite = notice_triangle.instantiate()
	Globals.user_interface.notice_triangles.add_child(_notice_triangle_sprite)


func _process(delta) -> void:
	if debug:
		pass
		prints(_notice_val)
		
	var _angle_to_player: float = rad_to_deg(
		Vector3.FORWARD.rotated(Vector3.UP, _entity.global_rotation.y).angle_to(
			_entity.global_position.direction_to(_player.global_position)
		)
	)
	
	if _angle_to_player < 80:
		_notice_val += 0.5 * delta
	else:
		_notice_val -= 0.5 * delta
	
	_notice_val = clamp(_notice_val, 0.0, 1.0)
	
	var mask_offset:float = -62 * _notice_val + 80
	var mask: Sprite2D = _notice_triangle_sprite.get_node("TriangleMask")
	mask.offset.y = mask_offset
	
	if _camera.is_position_in_frustum(global_position):
		_notice_triangle_sprite.position = _camera.unproject_position(global_position)
		_notice_triangle_sprite.visible = true		
	else:
		_notice_triangle_sprite.visible = false
