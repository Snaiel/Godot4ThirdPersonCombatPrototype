class_name NoticeComponentGettingSuspiciousState
extends NoticeComponentState

@export var idle_state: NoticeComponentIdleState
@export var suspicious_state: NoticeComponentSuspiciousState

var _notice_val: float


func enter() -> void:
	_notice_val = 0.0


func physics_process(delta) -> void:
	super.physics_process(delta)
	
	# change the offset of the mask to reflect on the meter in the triangle
	var mask_offset: float = -62 * _notice_val + 80
	var mask: Sprite2D = notice_component.notice_triangle_sprite.get_node("TriangleMask")
	mask.offset.y = mask_offset
	
	if notice_component.angle_to_player < 60 and notice_component.distance_to_player < 15.0:
		# raise suspicion
		_notice_val += 0.3 * delta
		notice_component.notice_triangle_sprite.visible = true
	else:
		_notice_val -= 0.3 * delta
	
	_notice_val = clamp(_notice_val, 0.0, 1.0)
	
	if is_equal_approx(_notice_val, 1.0):
		notice_component.change_state(suspicious_state)
	elif is_equal_approx(_notice_val, 0.0):
		notice_component.change_state(idle_state)


func exit() -> void:
	pass
