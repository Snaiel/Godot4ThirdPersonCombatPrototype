class_name NoticeComponentIdleState
extends NoticeComponentState


@export var getting_suspicious_state: NoticeComponentGettingSuspiciousState


func enter() -> void:
	notice_component.notice_triangle_sprite.visible = false


func physics_process(delta) -> void:
	if notice_component.angle_to_player < 60 and notice_component.distance_to_player < 15.0:
		notice_component.change_state(getting_suspicious_state)


func exit() -> void:
	pass
