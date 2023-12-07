class_name NoticeComponent
extends Node3D


signal state_changed(new_state: NoticeState, position_to_check: Vector3)

enum NoticeState {
	IDLE,
	SUSPICIOUS,
	AGGRO
}

@export var curve: Curve
@export var debug: bool
@export var notice_triangle: PackedScene

var current_state: NoticeState = NoticeState.IDLE

var _notice_val: float = 0.0
var _notice_triangle_sprite: Sprite2D
var _expand_x: float = 0.0
var _original_triangle_scale: Vector2

var _can_emit_suspicious: bool = true
var _suspicion_timer: Timer
var _can_start_suspicion_timer: bool = true
var _suspicion_interval: float = 20.0
var _check_to_leave_suspicion: bool = false

@onready var _entity: CharacterBody3D = get_parent()
@onready var _player: Player = Globals.player
@onready var _camera: Camera3D = Globals.camera_controller.cam


func _ready() -> void:
	_notice_triangle_sprite = notice_triangle.instantiate()
	Globals.user_interface.notice_triangles.add_child(_notice_triangle_sprite)
	_original_triangle_scale = _notice_triangle_sprite.scale
	
	_suspicion_timer = Timer.new()
	_suspicion_timer.wait_time = _suspicion_interval
	_suspicion_timer.one_shot = true
	_suspicion_timer.autostart = false
	_suspicion_timer.timeout.connect(
		func(): 
			_check_to_leave_suspicion = true
	)
	add_child(_suspicion_timer)

func _process(delta) -> void:
	# the angle of the player relative to where the entity is facing
	var _angle_to_player: float = rad_to_deg(
		Vector3.FORWARD.rotated(Vector3.UP, _entity.global_rotation.y).angle_to(
			_entity.global_position.direction_to(_player.global_position)
		)
	)
	
	# the distance between the entity and the player
	var _distance_to_player: float = _entity.global_position.distance_to(
		_player.global_position
	)
	
#	if debug:
#		prints(_suspicion_timer.time_left)
	
	# check for angle and distance threshold
	if _angle_to_player < 60 and _distance_to_player < 15.0:
		# raise suspicion
		_notice_val += 0.3 * delta
		_notice_triangle_sprite.visible = true
		_suspicion_timer.stop()
		_can_start_suspicion_timer = true
	elif _notice_val <= 0:
		# turn off triangle if there's nothing
		_notice_triangle_sprite.visible = false
	elif current_state == NoticeState.IDLE:
		# lower suspicion
		_notice_val -= 0.3 * delta
	elif current_state == NoticeState.SUSPICIOUS:
		if _check_to_leave_suspicion:
			# if not in any threshold and
			# suspicion time has elapsed
			_notice_val = 0.0
			current_state = NoticeState.IDLE
			state_changed.emit(current_state, Vector3.ZERO)
			_check_to_leave_suspicion = false
			_notice_triangle_sprite.visible = false
			_can_start_suspicion_timer = true
		elif _can_start_suspicion_timer:
			# if not in any threshold, start timer
			_suspicion_timer.start()
			_can_start_suspicion_timer = false
	
	_notice_val = clamp(_notice_val, 0.0, 1.0)
	
	# change the offset of the mask to reflect on the meter in the triangle
	var mask_offset: float = -62 * _notice_val + 80
	var mask: Sprite2D = _notice_triangle_sprite.get_node("TriangleMask")
	mask.offset.y = mask_offset
	
	# only make triangle visible if can be seen by camera
	if _camera.is_position_in_frustum(global_position) and _notice_val > 0:
		_notice_triangle_sprite.position = _camera.unproject_position(global_position)
		_notice_triangle_sprite.visible = true
	else:
		_notice_triangle_sprite.visible = false
	
	# do a nice little expand animation once suspicion is reached
	if is_equal_approx(_notice_val, 1.0):
		var expand_scale: float = curve.sample(_expand_x)
		_notice_triangle_sprite.scale = _original_triangle_scale * Vector2(expand_scale, expand_scale)
		_expand_x += 3.0 * delta
	else:
		_can_emit_suspicious = true
		_expand_x = 0.0
		_notice_triangle_sprite.self_modulate = lerp(
			_notice_triangle_sprite.self_modulate,
			Color.WHITE,
			0.2
		)
	
	# the moment where the entity is now considered suspicious
	if _notice_triangle_sprite.scale.y > _original_triangle_scale.y * 1.45:
		if _can_emit_suspicious:
			current_state = NoticeState.SUSPICIOUS
			state_changed.emit(current_state, _player.global_position)
			_can_emit_suspicious = false
			
		# make the entire triangle yellow
		_notice_triangle_sprite.self_modulate = lerp(
			_notice_triangle_sprite.self_modulate,
			Color.html("#dec123"),
			0.2
		)
