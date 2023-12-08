class_name NoticeComponentIdleState
extends NoticeComponentState


@export var getting_suspicious_state: NoticeComponentGettingSuspiciousState
@export var aggro_state: NoticeComponentAggroState


func enter() -> void:
	notice_component.notice_triangle_sprite.visible = false
	notice_component.notice_triangle_sprite.self_modulate = Color.WHITE
	notice_component.notice_triangle_inner_sprite.self_modulate = notice_component.suspicion_color


func physics_process(_delta) -> void:
	if notice_component.inside_inner_threshold():
		notice_component.transition_to_aggro()
		return
	elif notice_component.inside_outer_threshold():
		notice_component.change_state(getting_suspicious_state)


func exit() -> void:
	pass


func interrupt() -> void:
	pass
