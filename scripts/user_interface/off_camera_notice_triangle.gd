class_name OffCameraNoticeTriangle
extends Node2D


var debug: bool = false

@onready var off_cam_inner_mask: Sprite2D = $InsideTriangleMask
@onready var off_cam_inner_sprite: Sprite2D = $InsideTriangleMask/InsideTriangle
@onready var off_cam_background_mask: Sprite2D = $BackgroundTriangleMask
@onready var off_cam_background_sprite: Sprite2D = $BackgroundTriangleMask/BackgroundTriangle

@onready var player: Player = Globals.player
@onready var camera_controller: CameraController = Globals.camera_controller


func process_mask_offsets(value: float) -> void:
	off_cam_inner_mask.offset.y = get_off_cam_inside_offset(value)
	off_cam_background_mask.offset.y = get_off_cam_background_offset(value)


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


func get_off_cam_inside_offset(value: float) -> float:
	return 57 * value - 75.0


func get_off_cam_background_offset(value: float) -> float:
	return 55 * value + 25
