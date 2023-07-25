class_name LockOnSystem
extends LockOnComponent

signal lock_on(target: LockOnComponent)

@export var player: Player

@export_category("Enemies")
@export var target: LockOnComponent = null
@export var potential_target: LockOnComponent = null
@export var target_detection_range = 20


@export_category("Changing Target")
@export var change_target_mouse_threshold = 1
@export var change_target_controller_threshold = 0.2
@export var change_target_wait_time = 0.2
@export var can_change_target = true

var _targets_nearby: Array[LockOnComponent]

@onready var _change_target_timer = $ChangeTargetTimer


# Called when the node enters the scene tree for the first time.
func _ready():
	Globals.lock_on_system = self
	_change_target_timer.wait_time = change_target_wait_time
	$EnemyDetectionSphere.shape.radius = target_detection_range


# Called every frame. 'delta' is the elapsed time since the previous frame.
func _physics_process(_delta):
	position = player.position
	
	if Input.is_action_just_pressed("lock_on"):
		if target:
			target = null
		else:
			_choose_lock_on_target()
		lock_on.emit(target)
	
	# change target with controller
	var controller_r_joystick_x = Input.get_joy_axis(0, JOY_AXIS_RIGHT_X)
	if can_change_target and abs(controller_r_joystick_x) > change_target_controller_threshold and target:
		
		if controller_r_joystick_x > 0:
			_change_target_right()
		else:
			_change_target_left()
			
		lock_on.emit(target)			
		can_change_target = false
		_change_target_timer.start()
		
		
func _input(event):
	# change target with mouse
	if event is InputEventMouseMotion and target:
		var current_mouse_pos = event.relative
		if Vector2.ZERO.distance_to(current_mouse_pos) > change_target_mouse_threshold and can_change_target:
			if current_mouse_pos.x > 0:
				_change_target_right()
			else:
				_change_target_left()
			
			lock_on.emit(target)			
			can_change_target = false
			_change_target_timer.start()


func _on_area_entered(area: LockOnComponent):
	if area not in _targets_nearby:
		_targets_nearby.append(area)
		area.destroyed.connect(_target_destroyed)
	
	
func _on_area_exited(area: LockOnComponent):
	_targets_nearby.erase(area)
	area.destroyed.disconnect(_target_destroyed)
	
	
func _on_change_target_timer_timeout():
	can_change_target = true
	
	
func _target_destroyed(t):
	_targets_nearby.erase(t)
	_choose_lock_on_target()
	lock_on.emit(target)		
	
	
func _can_see_target(t: LockOnComponent) -> bool:
	var can_see: bool = true
	var cam = get_viewport().get_camera_3d()	
	
	var space_state = get_world_3d().direct_space_state
	var query = PhysicsRayQueryParameters3D.create(cam.global_position, t.global_position, 1)
	var result = space_state.intersect_ray(query)
	
	can_see = result.size() == 0
	
	return can_see
	
	
func _get_targets_in_front() -> Array[LockOnComponent]:
	var targets: Array[LockOnComponent] = []
	var cam = get_viewport().get_camera_3d()
	
	for t in _targets_nearby:
		if not cam.is_position_behind(t.global_position) and _can_see_target(t):
			targets.append(t)
			
	return targets
	
	
func _get_targets_in_frustum() -> Array[LockOnComponent]:
	var targets: Array[LockOnComponent] = []
	var cam = get_viewport().get_camera_3d()
	
	for t in _targets_nearby:
		if t != target and cam.is_position_in_frustum(t.global_position) and _can_see_target(t):
			targets.append(t)
			
	return targets


func _choose_lock_on_target():
	var cam = get_viewport().get_camera_3d()
	var viewport_center = Vector2(get_viewport().size / 2)	
	var targets_in_frustum = _get_targets_in_frustum()
	
	var closest_dist: float 
	var closest_target: LockOnComponent = null
			
	if targets_in_frustum.size() == 0:
		target = null
		return
	
	for t in targets_in_frustum:
		var dist = viewport_center.distance_to(cam.unproject_position(t.global_position))
		if closest_target == null or dist < closest_dist:
			closest_dist = dist
			closest_target = t
	
	target = closest_target


func _change_target_right():
	var cam = get_viewport().get_camera_3d()
	var targets_in_frustum = _get_targets_in_front()
			
	if targets_in_frustum.size() == 0:
		target = null
		return
	targets_in_frustum.erase(target)
	
	var closest_dist: float 
	var target_target: LockOnComponent = null
	var current_target_pos = cam.unproject_position(target.global_position)
	
	for t in targets_in_frustum:
		var pos = cam.unproject_position(t.global_position)
		var dist = current_target_pos.distance_to(pos)
		
		if pos.x > current_target_pos.x and (target_target == null or dist <= closest_dist):
			closest_dist = dist
			target_target = t
			
	if not target_target:
		var furthest_dst: float
		for t in targets_in_frustum:
			var pos = cam.unproject_position(t.global_position)
			var dist = current_target_pos.distance_to(pos)
			
			if pos.x < current_target_pos.x and (target_target == null or dist >= furthest_dst):
				furthest_dst = dist
				target_target = t
			
	target = target_target if target_target else target
	
	
func _change_target_left():
	var cam = get_viewport().get_camera_3d()
	var targets_in_frustum = _get_targets_in_front()
			
	if targets_in_frustum.size() == 0:
		target = null
		return
	targets_in_frustum.erase(target)
	
	var closest_dist: float 
	var target_target: LockOnComponent = null
	var current_target_pos = cam.unproject_position(target.global_position)
	
	for t in targets_in_frustum:
		var pos = cam.unproject_position(t.global_position)
		var dist = current_target_pos.distance_to(pos)
		
		if pos.x < current_target_pos.x and (target_target == null or dist <= closest_dist):
			closest_dist = dist
			target_target = t
			
	if not target_target:
		var furthest_dst: float
		for t in targets_in_frustum:
			var pos = cam.unproject_position(t.global_position)
			var dist = current_target_pos.distance_to(pos)
			
			if pos.x > current_target_pos.x and (target_target == null or dist >= furthest_dst):
				furthest_dst = dist
				target_target = t
			
	target = target_target if target_target else target
