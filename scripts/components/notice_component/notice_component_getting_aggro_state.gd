class_name NoticeComponentGettingAggroState
extends NoticeComponentState


@export var suspicious_state: NoticeComponentSuspiciousState
@export var aggro_state: NoticeComponentAggroState

var _notice_val: float


func enter() -> void:
	_notice_val = 0.0
	
	notice_component.notice_triangle.inner_triangle.visible = false
	notice_component.notice_triangle.inner_triangle.self_modulate = \
		notice_component.aggro_color
	notice_component.notice_triangle.background_triangle.self_modulate = \
		notice_component.suspicion_color
	
	notice_component.off_camera_notice_triangle.inner_triangle.visible = false
	notice_component.off_camera_notice_triangle.inner_triangle.self_modulate = \
		notice_component.aggro_color
	notice_component.off_camera_notice_triangle.background_triangle.self_modulate = \
		notice_component.suspicion_color


func physics_process(delta) -> void:
	notice_component.notice_triangle.visible = true
	notice_component.notice_triangle.inner_triangle.visible = true
	notice_component.off_camera_notice_triangle.inner_triangle.visible = true
	
	# change the offset of the mask to reflect on the meter in the triangle
	notice_component.notice_triangle.process_mask_offset(_notice_val)
	notice_component.off_camera_notice_triangle.process_mask_offsets(_notice_val)
	
	if notice_component.inside_inner_threshold():
		notice_component.transition_to_aggro()
		return
	elif notice_component.inside_outer_threshold():
		# raise suspicion
		_notice_val += notice_component.get_notice_value() * delta
	else:
		_notice_val -= notice_component.get_notice_value() * delta
	
	_notice_val = clamp(_notice_val, 0.0, 1.0)
	
	if not notice_component.in_camera_frustum():
		notice_component.notice_triangle.visible = false
	
	
	if is_equal_approx(_notice_val, 1.0):
		notice_component.change_state(aggro_state)
	elif is_equal_approx(_notice_val, 0.0):
		notice_component.change_state(suspicious_state)


func exit() -> void:
	pass
