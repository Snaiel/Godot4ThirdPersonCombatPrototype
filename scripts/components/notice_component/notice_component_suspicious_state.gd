class_name NoticeComponentSuspiciousState
extends NoticeComponentState


@export var idle_state: NoticeComponentIdleState
@export var curve: Curve

var _expand_x: float
var _expand_scale: float

var _suspicion_timer: Timer
var _can_start_suspicion_timer: bool = true
var _suspicion_interval: float = 20.0
var _check_to_leave_suspicion: bool = false


func _ready():
	_suspicion_timer = Timer.new()
	_suspicion_timer.wait_time = _suspicion_interval
	_suspicion_timer.one_shot = true
	_suspicion_timer.autostart = false
	_suspicion_timer.timeout.connect(
		func(): 
			_check_to_leave_suspicion = true
	)
	add_child(_suspicion_timer)


func enter() -> void:
	_expand_x = 0
	_check_to_leave_suspicion = false
	_can_start_suspicion_timer = true
	notice_component.position_to_check = notice_component.player.global_position


func physics_process(delta) -> void:
#	if notice_component.debug: prints(_suspicion_timer.time_left)
	
	notice_component.notice_triangle_sprite.visible = true
	
	_expand_scale = curve.sample(_expand_x)
	
	notice_component.notice_triangle_sprite.scale = \
		notice_component.original_triangle_scale * \
		Vector2(_expand_scale, _expand_scale)
		
	_expand_x += 3.0 * delta
	
	if notice_component.notice_triangle_sprite.scale.y > \
		notice_component.original_triangle_scale.y * 1.45:
			
		# make the entire triangle yellow
		notice_component.notice_triangle_sprite.self_modulate = \
			lerp(
				notice_component
					.notice_triangle_sprite
					.self_modulate,
				Color.html("#dec123"),
				0.2
			)
	
	if not (
		notice_component.angle_to_player < 60 and 
		notice_component.distance_to_player < 15.0
		):
		
		if _check_to_leave_suspicion:
			notice_component.change_state(idle_state)
		elif _can_start_suspicion_timer:
			_suspicion_timer.start()
			_can_start_suspicion_timer = false
	
	if not notice_component.in_camera_frustum():
		notice_component.notice_triangle_sprite.visible = false

func exit() -> void:
	pass


func interrupt() -> void:
	_suspicion_timer.stop()
