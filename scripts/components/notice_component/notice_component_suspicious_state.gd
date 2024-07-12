class_name NoticeComponentSuspiciousState
extends NoticeComponentState


@export var idle_state: NoticeComponentIdleState
@export var getting_aggro_state: NoticeComponentGettingAggroState
@export var aggro_state: NoticeComponentAggroState

@export var before_getting_aggro_dist_threshold: float = 0.8

var _expand_x: float
var _expand_scale: float

var _prev_looked_around_val: bool = false
var _check_to_leave_suspicion: bool = false

var _before_getting_aggro_timer: Timer
var _before_getting_aggro_pause: float = 2.0
var _check_to_get_aggro: bool = false


func _ready():
	_before_getting_aggro_timer = Timer.new()
	_before_getting_aggro_timer.wait_time = _before_getting_aggro_pause
	_before_getting_aggro_timer.one_shot = true
	_before_getting_aggro_timer.autostart = false
	_before_getting_aggro_timer.timeout.connect(
		func(): _check_to_get_aggro = true
	)
	add_child(_before_getting_aggro_timer)


func enter() -> void:
	_expand_x = 0
	
	_check_to_leave_suspicion = false
	
	if notice_component.previous_state is NoticeComponentGettingAggroState:
		_expand_x = 1.0
	else:
		notice_component.blackboard.set_value(
			"agent_target_position",
			notice_component.player.global_position
		)
	
	if notice_component.distance_to_player > \
		before_getting_aggro_dist_threshold * \
		notice_component.outer_distance:
			
		_before_getting_aggro_timer.start()
	else:
		_check_to_get_aggro = true


func physics_process(delta) -> void:
	notice_component.notice_triangle.visible = true
	
	_expand_scale = notice_component.expand_curve.sample(_expand_x)
	
	notice_component.notice_triangle.process_scale(_expand_scale)
	notice_component.off_camera_notice_triangle.process_scale(_expand_scale)
	
	_expand_x += 3.0 * delta
	_expand_x = clamp(_expand_x, 0.0, 1.0)
	
	if _expand_x >= 0.5:
		# make the entire triangle yellow
		notice_component.notice_triangle.process_colour(
			notice_component.suspicion_color
		)
		notice_component.off_camera_notice_triangle.process_colour(
			notice_component.suspicion_color
		)
	
	if _prev_looked_around_val == false and \
	notice_component.blackboard.get_value("looked_around"):
		get_tree().create_timer(0.3).timeout.connect(
			func(): _check_to_leave_suspicion = true
		)
	_prev_looked_around_val = notice_component.blackboard.get_value(
		"looked_around",
		false
	)
	
	if notice_component.inside_inner_threshold():
		notice_component.transition_to_aggro()
		_before_getting_aggro_timer.stop()
		return
	
	if notice_component.inside_outer_threshold():
		if _check_to_get_aggro and _expand_x >= 1.0:
			notice_component.change_state(getting_aggro_state)
	elif _check_to_leave_suspicion:
		notice_component.change_state(idle_state)
	
	if not notice_component.in_camera_frustum():
		notice_component.notice_triangle.visible = false


func exit() -> void:
	pass
