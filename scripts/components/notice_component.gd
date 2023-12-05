extends Node3D

@export var curve: Curve
@export var debug: bool
@export var notice_triangle: PackedScene

var _notice_val: float = 0.0
var _notice_triangle_sprite: Sprite2D
var _expand_x: float = 0.0
var _original_triangle_scale: Vector2

@onready var _entity: CharacterBody3D = get_parent()
@onready var _player: Player = Globals.player
@onready var _camera: Camera3D = Globals.camera_controller.cam


func _ready() -> void:
	_notice_triangle_sprite = notice_triangle.instantiate()
	Globals.user_interface.notice_triangles.add_child(_notice_triangle_sprite)
	_original_triangle_scale = _notice_triangle_sprite.scale


func _process(delta) -> void:
	if debug:
		pass
		prints(_notice_triangle_sprite.modulate, Color.html("#dec123"), _notice_triangle_sprite.scale)
		
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
	
	if is_equal_approx(_notice_val, 1.0):
		var expand_scale: float = curve.sample(_expand_x)
		_notice_triangle_sprite.scale = _original_triangle_scale * Vector2(expand_scale, expand_scale)
		_expand_x += 2.5 * delta
	
	if _notice_triangle_sprite.scale.y > _original_triangle_scale.y * 1.45:
		_notice_triangle_sprite.self_modulate = lerp(
			_notice_triangle_sprite.self_modulate,
			Color.html("#dec123"),
			0.2
		)
