class_name NoticeComponentGettingSuspiciousState
extends NoticeComponentState


@export var idle_state: NoticeComponentIdleState
@export var suspicious_state: NoticeComponentSuspiciousState
@export var aggro_state: NoticeComponentAggroState

var _notice_val: float

var _back_to_idle_timer: Timer
var _back_to_idle_pause: float = 1.0
var _can_go_back_to_idle: bool = false


func _ready():
	_back_to_idle_timer = Timer.new()
	_back_to_idle_timer.wait_time = _back_to_idle_pause
	_back_to_idle_timer.one_shot = true
	_back_to_idle_timer.autostart = false
	_back_to_idle_timer.timeout.connect(
		func(): 
			_can_go_back_to_idle = true
	)
	add_child(_back_to_idle_timer)



func enter() -> void:
	_notice_val = 0.0
	_back_to_idle_timer.start()
	_can_go_back_to_idle = false
	
	notice_component\
		.notice_triangle\
		.visible = true
	notice_component\
		.off_camera_notice_triangle\
		.visible = true
	
	notice_component\
		.notice_triangle\
		.modulate\
		.a = 1.0
	notice_component\
		.off_camera_notice_triangle\
		.modulate\
		.a = 1.0
	
	notice_component\
		.notice_triangle\
		.background_triangle\
		.self_modulate\
		.a = 1.0
	notice_component\
		.off_camera_notice_triangle\
		.background_triangle\
		.self_modulate\
		.a = 1.0


func physics_process(delta) -> void:
	# change the offset of the mask to reflect on the meter in the triangle
	notice_component.notice_triangle.process_mask_offset(_notice_val)
	notice_component.off_camera_notice_triangle.process_mask_offsets(_notice_val)
	
	if notice_component.inside_inner_threshold():
		notice_component.transition_to_aggro()
		return
	elif notice_component.inside_outer_threshold():
		# raise suspicion
		_notice_val += notice_component.get_notice_value() * delta
		notice_component.notice_triangle.visible = true
	else:
		_notice_val -= notice_component.get_notice_value() * delta
	
	_notice_val = clamp(_notice_val, 0.0, 1.0)
	
	if not notice_component.in_camera_frustum():
		notice_component.notice_triangle.visible = false
	
	
	if is_equal_approx(_notice_val, 1.0):
		notice_component.change_state(suspicious_state)
	elif is_equal_approx(_notice_val, 0.0) and _can_go_back_to_idle:
		notice_component.change_state(idle_state)


func exit() -> void:
	_back_to_idle_timer.stop()
