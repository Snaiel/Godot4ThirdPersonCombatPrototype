class_name NoticeComponent
extends Node3D


signal state_changed(new_state: NoticeComponentState)

@export_category("Configuration")
@export var debug: bool
@export var notice_triangle: PackedScene
@export var health_component: HealthComponent
@export var initial_state: NoticeComponentState

@export_category("Notice Thresholds")
@export var angle_threshold: float = 60.0
@export var outer_distance: float = 15.0

@export_category("Notice Triangle")
@export var suspicion_color: Color
@export var aggro_color: Color
@export var background_color: Color

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
	notice_triangle_sprite = notice_triangle.instantiate()
	Globals.user_interface.notice_triangles.add_child(notice_triangle_sprite)
	original_triangle_scale = notice_triangle_sprite.scale
	
	notice_triangle_inner_sprite = notice_triangle_sprite.get_node("TriangleMask/InsideTriangle")
	notice_triangle_background_sprite = notice_triangle_sprite.get_node("BackgroundTriangle")
	notice_triangle_mask = notice_triangle_sprite.get_node("TriangleMask")
	
	health_component.zero_health.connect(
		func():
			notice_triangle_sprite.visible = false
			_disabled = true
	)
	
	current_state = initial_state
	current_state.enter()
	
	position_to_check = Vector3.INF


func _physics_process(delta) -> void:
	current_state.debug = debug
	
#	if debug: print(current_state)
	
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
	print(new_state)
	new_state.enter()
	current_state.exit()
	current_state = new_state
	state_changed.emit(new_state)


func inside_outer_threshold() -> bool:
	return angle_to_player < angle_threshold and \
		distance_to_player < outer_distance


func get_mask_offset(value: float) -> float:
	return -62.0 * value + 80.0


func in_camera_frustum() -> bool:
	return camera.is_position_in_frustum(global_position)
