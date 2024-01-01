class_name NoticeComponentAggroState
extends NoticeComponentState


@export var idle_state: NoticeComponentIdleState

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
	
	notice_component\
		.notice_triangle_background_sprite\
		.self_modulate\
		.a = 0
	notice_component\
		.off_camera_notice_triangle\
		.background_sprite\
		.self_modulate\
		.a = 0


func physics_process(delta) -> void:
	notice_component.notice_triangle_sprite.visible = true
	notice_component.off_camera_notice_triangle.visible = true
	
	notice_component.off_camera_notice_triangle.process_mask_offsets(1.0)
	
	_expand_scale = notice_component.expand_curve.sample(_expand_x)
	
	notice_component.notice_triangle_sprite.scale = \
		notice_component.original_triangle_scale * \
		Vector2(_expand_scale, _expand_scale)
	
	print(notice_component.off_camera_notice_triangle.inner_sprite.self_modulate)
	
	notice_component\
		.off_camera_notice_triangle\
		.process_scale(_expand_scale)
	
	_expand_x += 3.0 * delta
	_expand_x = clamp(_expand_x, 0.0, 1.0)
	
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
		
		notice_component\
			.off_camera_notice_triangle\
			.process_colour(
				notice_component.aggro_color
			)
		
		if _expand_x >= 1.0:
			notice_component.notice_triangle_sprite.modulate.a = \
			lerp(
				notice_component
					.notice_triangle_sprite
					.modulate
					.a,
				0.0,
				0.1
			)
			
			notice_component\
				.off_camera_notice_triangle\
				.process_alpha(0.0)
	
	if not notice_component.inside_outer_threshold():
		
		if _check_to_leave_aggro:
			notice_component.change_state(idle_state)
		elif _can_start_aggro_timer:
			_aggro_timer.start()
			_can_start_aggro_timer = false
	
	if not notice_component.in_camera_frustum():
		notice_component.notice_triangle_sprite.visible = false


func exit() -> void:
	_aggro_timer.stop()
