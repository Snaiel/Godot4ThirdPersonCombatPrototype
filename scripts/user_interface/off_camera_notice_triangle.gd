class_name OffCameraNoticeTriangle
extends Node2D


var debug: bool = false

var _original_scales: Array[Vector2] = []

@onready var triangle_arc_base: Sprite2D = $TriangleArcBase
@onready var inner_mask: Sprite2D = $InsideTriangleMask
@onready var inner_sprite: Sprite2D = $InsideTriangleMask/InsideTriangle
@onready var background_mask: Sprite2D = $BackgroundTriangleMask
@onready var background_sprite: Sprite2D = $BackgroundTriangleMask/BackgroundTriangle

@onready var player: Player = Globals.player
@onready var camera_controller: CameraController = Globals.camera_controller


func _ready():
	for index in get_child_count() - 1:
		_original_scales.append(get_child(index).scale)


func process_mask_offsets(value: float) -> void:
	inner_mask.offset.y = get_off_cam_inside_offset(value)
	background_mask.offset.y = get_off_cam_background_offset(value)


func process_desired_rotation(entity: Node3D) -> void:
	var r = rad_to_deg(
	Vector3.FORWARD\
		.rotated(
			Vector3.UP,
			deg_to_rad(camera_controller.rotation_degrees.y)
		)\
		.signed_angle_to(
			player\
				.global_position\
				.direction_to(
					entity.global_position
				),
			Vector3.UP
		)
	)
	
	var desired_rotation: float = -r + 180
	rotation_degrees = desired_rotation
	
	visible = debug


func process_scale(expand_scale: float) -> void:
	for index in get_child_count() - 1:
		get_child(index).scale = _original_scales[index] * Vector2(expand_scale, expand_scale)


func process_colour(colour: Color) -> void:
	triangle_arc_base.self_modulate = lerp(
		triangle_arc_base.self_modulate,
		colour,
		0.2
	)


func get_off_cam_inside_offset(value: float) -> float:
	return 65.0 * value - 76.0


func get_off_cam_background_offset(value: float) -> float:
	return 67.0 * value + 23.0
