class_name NoticeComponentAggroState
extends NoticeComponentState


@export var idle_state: NoticeComponentIdleState
@export var curve: Curve

var _expand_x: float
var _expand_scale: float

var _aggro_timer: Timer
var _can_start_aggro_timer: bool = true
var _aggro_interval: float = 20.0
var _check_to_leave_aggro: bool = false


func _ready():
	_aggro_timer = Timer.new()
	_aggro_timer.wait_time = _aggro_interval
	_aggro_timer.one_shot = true
	_aggro_timer.autostart = false
	_aggro_timer.timeout.connect(
		func(): 
			_check_to_leave_aggro = true
	)
	add_child(_aggro_timer)


func enter() -> void:
	_expand_x = 0
	_check_to_leave_aggro = false
	_can_start_aggro_timer = true


func physics_process(delta) -> void:
	notice_component.notice_triangle_sprite.visible = true
	
	_expand_scale = curve.sample(_expand_x)
	
	notice_component.notice_triangle_sprite.scale = \
		notice_component.original_triangle_scale * \
		Vector2(_expand_scale, _expand_scale)
		
	_expand_x += 3.0 * delta
	
	if _expand_x >= 0.5:
		# make the entire triangle red
		notice_component.notice_triangle_sprite.self_modulate = \
			lerp(
				notice_component
					.notice_triangle_sprite
					.self_modulate,
				notice_component.aggro_color,
				0.2
			)
	if not notice_component.inside_outer_threshold():
		
		if _check_to_leave_aggro:
			notice_component.change_state(idle_state)
		elif _can_start_aggro_timer:
			_aggro_timer.start()
			_can_start_aggro_timer = false
	
	if not notice_component.in_camera_frustum():
		notice_component.notice_triangle_sprite.visible = false


func exit() -> void:
	pass


func interrupt() -> void:
	_aggro_timer.stop()
