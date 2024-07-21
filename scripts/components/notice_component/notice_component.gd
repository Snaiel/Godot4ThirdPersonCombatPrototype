class_name NoticeComponent
extends Node


@export_category("Configuration")
@export var debug: bool
@export var enabled: bool = true
@export var entity: Enemy
@export var head_attachment: BoneAttachment3D
@export var hud_info: Node3D

@export_category("Behaviour")
@export var beehave_tree: BeehaveTree
@export var blackboard: Blackboard

@export_category("States")
@export var initial_state: NoticeComponentState
@export var aggro_state: NoticeComponentAggroState

@export_category("Notice Thresholds")
@export var inner_angle: float = 50.0
@export var outer_angle: float = 70.0
@export var inner_distance: float = 10.0
@export var outer_distance: float = 10.0

@export_category("Notice Value")
@export var min_notice_step: float = 0.15
@export var max_notice_step: float = 3.0
@export var notice_val_curve: Curve

@export_category("Notice Triangle")
@export var notice_triangle_scene: PackedScene
@export var off_camera_notice_triangle_scene: PackedScene
@export var suspicion_color: Color
@export var aggro_color: Color
@export var background_color: Color
@export var expand_curve: Curve

var current_state: NoticeComponentState
var previous_state: NoticeComponentState

var angle_to_player: float
var distance_to_player: float

var notice_triangle: NoticeTriangle
var off_camera_notice_triangle: OffCameraNoticeTriangle

var triangle_y_offset: float = -25

var _is_inside_outer_threshold: bool = false

@onready var player: Player = Globals.player
@onready var camera: Camera3D = Globals.camera_controller.cam


func _ready() -> void:
	notice_triangle = notice_triangle_scene.instantiate()
	Globals.user_interface.hud.notice_triangles.add_child(notice_triangle)
	notice_triangle.visible = false
	
	off_camera_notice_triangle = off_camera_notice_triangle_scene.instantiate()
	Globals.user_interface.hud.off_camera_notice_triangles.add_child(off_camera_notice_triangle)
	off_camera_notice_triangle.visible = false
	
	current_state = initial_state
	current_state.enter()


func _physics_process(delta) -> void:
	current_state.debug = debug
	
	if not enabled:
		return
	
	# the angle of the player relative to where the entity is facing
	angle_to_player = rad_to_deg(
		Vector3.FORWARD.rotated(Vector3.UP, entity.global_rotation.y).angle_to(
			entity.global_position.direction_to(player.global_position)
		)
	)
	
	# the distance between the entity and the player
	distance_to_player = entity.global_position.distance_to(
		player.global_position
	)
	
	notice_triangle.position = camera.unproject_position(
		hud_info.global_position
	) + Vector2(0, triangle_y_offset)
	
	off_camera_notice_triangle.debug = debug
	off_camera_notice_triangle.visible = not in_camera_frustum() and \
		not current_state is NoticeComponentIdleState
	off_camera_notice_triangle.process_desired_rotation(entity)
	
	
	if inside_outer_threshold() and not _is_inside_outer_threshold:
		_is_inside_outer_threshold = true
		blackboard.set_value("perceives_player", true)
		if current_state is NoticeComponentAggroState:
			beehave_tree.interrupt()
			blackboard.set_value(
				"agent_target_position",
				null
			)
	elif not inside_outer_threshold() and _is_inside_outer_threshold:
		_is_inside_outer_threshold = false
		blackboard.set_value("perceives_player", false)
	
	
	current_state.physics_process(delta)


func change_state(new_state: NoticeComponentState) -> void:
	#prints(current_state, new_state)
	
	if new_state == current_state:
		return
	
	current_state.exit()
	previous_state = current_state
	new_state.enter()
	current_state = new_state
	
	var new_state_string: String
	
	if new_state is NoticeComponentIdleState:
		new_state_string = "idle"
	elif new_state is NoticeComponentGettingSuspiciousState:
		new_state_string = "getting_suspicious"
	elif new_state is NoticeComponentSuspiciousState:
		new_state_string = "suspicious"
	elif new_state is NoticeComponentGettingAggroState:
		new_state_string = "getting_aggro"
	elif new_state is NoticeComponentAggroState:
		new_state_string = "aggro"
	
	blackboard.set_value("notice_state", new_state_string)


func inside_inner_threshold() -> bool:
	return angle_to_player < inner_angle and \
		distance_to_player < inner_distance and \
		_can_see_target(player.lock_on_attachment_point.global_position)


func inside_outer_threshold() -> bool:
	return angle_to_player < outer_angle and \
		distance_to_player < outer_distance and \
		_can_see_target(player.lock_on_attachment_point.global_position)


func get_notice_value() -> float:
	var normalized_distance: float = inverse_lerp(
		outer_distance, 
		inner_distance, 
		distance_to_player
	)
	normalized_distance = clamp(normalized_distance, 0.0, 1.0)
	
	var normalized_angle: float = inverse_lerp(
		outer_angle,
		0.0,
		angle_to_player
	)
	normalized_angle = clamp(normalized_angle, 0.0, 1.0)
	
	var notice_value: float = (normalized_distance + normalized_angle) / 2.0
	
	notice_value = notice_val_curve.sample(notice_value)
	notice_value = lerp(min_notice_step, max_notice_step, notice_value)
	
	return notice_value


func in_camera_frustum() -> bool:
	return camera.is_position_in_frustum(hud_info.global_position)


func transition_to_aggro() -> void:
	notice_triangle.process_mask_offset(1.0)
	change_state(aggro_state)


func hide_notice_triangles() -> void:
	notice_triangle.visible = false
	off_camera_notice_triangle.visible = false


func _can_see_target(target_pos: Vector3) -> bool:
	var can_see: bool = true

	var space_state: PhysicsDirectSpaceState3D = head_attachment.\
		get_world_3d().\
		direct_space_state
	var query: PhysicsRayQueryParameters3D = PhysicsRayQueryParameters3D.create(
		head_attachment.global_position,
		target_pos,
		1
	)
	var result: Dictionary = space_state.intersect_ray(query)
	
	if result.size() != 0:
		can_see = false
	
	return can_see
