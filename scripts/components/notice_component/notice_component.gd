class_name NoticeComponent
extends Node3D


signal state_changed(new_state: NoticeComponentState)

@export_category("Configuration")
@export var debug: bool
@export var notice_triangle_scene: PackedScene
@export var health_component: HealthComponent
@export var initial_state: NoticeComponentState
@export var aggro_state: NoticeComponentAggroState

@export_category("Notice Thresholds")
@export var angle_threshold: float = 60.0
@export var inner_distance: float = 8.5
@export var outer_distance: float = 15.0

@export_category("Notice Value")
@export var min_notice_step: float = 0.15
@export var max_notice_step: float = 3.0
@export var notice_val_curve: Curve

@export_category("Notice Triangle")
@export var suspicion_color: Color
@export var aggro_color: Color
@export var background_color: Color
@export var expand_curve: Curve

var position_to_check: Vector3

var current_state: NoticeComponentState

var angle_to_player: float
var distance_to_player: float

var notice_triangle_sprite: Sprite2D
var notice_triangle_inner_sprite: Sprite2D
var notice_triangle_background_sprite: Sprite2D
var notice_triangle_mask: Sprite2D

var original_triangle_scale: Vector2

var _disabled: bool = false

@onready var entity: CharacterBody3D = get_parent()
@onready var player: Player = Globals.player
@onready var camera: Camera3D = Globals.camera_controller.cam


func _ready() -> void:
	notice_triangle_sprite = notice_triangle_scene.instantiate()
	Globals.user_interface.notice_triangles.add_child(notice_triangle_sprite)
	original_triangle_scale = notice_triangle_sprite.scale
	
	notice_triangle_inner_sprite = notice_triangle_sprite.get_node("TriangleMask/InsideTriangle")
	notice_triangle_background_sprite = notice_triangle_sprite.get_node("BackgroundTriangle")
	notice_triangle_mask = notice_triangle_sprite.get_node("TriangleMask")
	
	health_component.zero_health.connect(
		func():
			current_state.interrupt()
			notice_triangle_sprite.visible = false
			_disabled = true
	)
	
	current_state = initial_state
	current_state.enter()
	
	position_to_check = Vector3.INF


func _physics_process(delta) -> void:
	current_state.debug = debug
	
#	if debug: prints(angle_to_player, distance_to_player, get_notice_value())
	
	if _disabled:
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
	
	notice_triangle_sprite.position = camera.unproject_position(global_position)
	
	current_state.physics_process(delta)


func change_state(new_state: NoticeComponentState) -> void:
	prints(current_state, new_state)
	new_state.enter()
	current_state.exit()
	current_state = new_state
	state_changed.emit(new_state)


func inside_inner_threshold() -> bool:
	return angle_to_player < angle_threshold and \
		distance_to_player < inner_distance


func inside_outer_threshold() -> bool:
	return angle_to_player < angle_threshold and \
		distance_to_player < outer_distance


func get_mask_offset(value: float) -> float:
	return -62.0 * value + 80.0


func get_notice_value() -> float:
	var notice_value: float
	
	notice_value = inverse_lerp(outer_distance, inner_distance, distance_to_player)
	notice_value = clamp(notice_value, 0.0, 1.0)
	notice_value = notice_val_curve.sample(notice_value)
	notice_value = lerp(min_notice_step, max_notice_step, notice_value)
	
	return notice_value

func in_camera_frustum() -> bool:
	return camera.is_position_in_frustum(global_position)


func transition_to_aggro() -> void:
	notice_triangle_mask.offset.y = get_mask_offset(1.0)
	notice_triangle_inner_sprite.self_modulate = aggro_color
	notice_triangle_sprite.self_modulate = aggro_color
	change_state(aggro_state)
