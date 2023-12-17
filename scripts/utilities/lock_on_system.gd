class_name LockOnSystem
extends Node3D

signal lock_on(target: LockOnComponent)

@export var player: Player
@export var retain_distance: float = 25.0

@export_category("Enemies")
@export var target: LockOnComponent = null
@export var potential_target: LockOnComponent = null
@export var target_detection_range: float = 20.0


@export_category("Changing Target")
@export var change_target_mouse_threshold: float = 60.0
@export var change_target_controller_threshold: float = 0.2
@export var change_target_wait_time: float = 0.5
@export var can_change_target = true

var _targets_nearby: Array[LockOnComponent]

@onready var _change_target_timer: Timer = $ChangeTargetTimer
@onready var _enemy_detection_sphere: CollisionShape3D = $EnemyDetectionSphere

@onready var _dizzy_system: DizzySystem = Globals.dizzy_system
@onready var _backstab_system: BackstabSystem = Globals.backstab_system


func _ready() -> void:
	Globals.lock_on_system = self
	_change_target_timer.wait_time = change_target_wait_time
	(_enemy_detection_sphere.shape as SphereShape3D).radius = target_detection_range


func _physics_process(_delta: float) -> void:
	
	position = player.position
	
	if target:
		var distance: float = player.global_position.distance_to(target.global_position)
		if distance > retain_distance:
			target = null
			lock_on.emit(target)
	
	if Input.is_action_just_pressed("lock_on"):
		if target:
			target = null
		else:
			_choose_lock_on_target()
		lock_on.emit(target)

	# change target with controller
	var controller_r_joystick_x: float = Input.get_joy_axis(0, JOY_AXIS_RIGHT_X)
	if can_change_target and abs(controller_r_joystick_x) > change_target_controller_threshold and target:

		if controller_r_joystick_x > 0:
			_change_target_right()
		else:
			_change_target_left()

		lock_on.emit(target)
		can_change_target = false
		_change_target_timer.start()


func _input(event: InputEvent) -> void:
	# change target with mouse
	if event is InputEventMouseMotion and target:
		event = event as InputEventMouseMotion
		var current_mouse_pos: Vector2 = event.relative
		if Vector2.ZERO.distance_to(current_mouse_pos) > change_target_mouse_threshold and can_change_target:
			if current_mouse_pos.x > 0:
				_change_target_right()
			else:
				_change_target_left()

			lock_on.emit(target)
			can_change_target = false
			_change_target_timer.start()


func _on_area_entered(area: LockOnComponent) -> void:
	if area not in _targets_nearby:
		_targets_nearby.append(area)
		area.destroyed.connect(_target_destroyed)


func _on_area_exited(area: LockOnComponent) -> void:
	_targets_nearby.erase(area)
	area.destroyed.disconnect(_target_destroyed)


func _on_change_target_timer_timeout() -> void:
	can_change_target = true


func _target_destroyed(t: LockOnComponent) -> void:
	_targets_nearby.erase(t)
	
	if  (
			_dizzy_system.prev_victim and \
			_dizzy_system.prev_victim.entity == target.component_owner
		) or \
		(
			_backstab_system.backstab_victim and \
			_backstab_system.backstab_victim.entity == target.component_owner
		):
			
		var timer: SceneTreeTimer = get_tree().create_timer(1.0)
		timer.timeout.connect(
			func():
				_choose_new_target()
		)
	elif target:
		_choose_new_target()


func _choose_new_target():
	_choose_lock_on_target()
	lock_on.emit(target)


func _can_see_target(t: LockOnComponent) -> bool:
	var can_see: bool = true
	var cam: Camera3D = get_viewport().get_camera_3d()

	var space_state: PhysicsDirectSpaceState3D = get_world_3d().direct_space_state
	var query: PhysicsRayQueryParameters3D = PhysicsRayQueryParameters3D.create(
		cam.global_position,
		t.global_position,
		1
	)
	var result: Dictionary = space_state.intersect_ray(query)
	
	if result.size() != 0 and result["collider"] != t.component_owner:
		can_see = false

	return can_see


func _get_targets_in_front() -> Array[LockOnComponent]:
	var targets: Array[LockOnComponent] = []
	var cam: Camera3D = get_viewport().get_camera_3d()

	for t in _targets_nearby:
		if not cam.is_position_behind(t.global_position) and _can_see_target(t):
			targets.append(t)

	return targets


func _get_targets_in_frustum() -> Array[LockOnComponent]:
	var targets: Array[LockOnComponent] = []
	var cam: Camera3D = get_viewport().get_camera_3d()

	for t in _targets_nearby:
		if t != target and cam.is_position_in_frustum(t.global_position) and _can_see_target(t):
			targets.append(t)

	return targets


func _choose_lock_on_target() -> void:
	var cam: Camera3D = get_viewport().get_camera_3d()
	var viewport_center: Vector2 = Vector2(get_viewport().size / 2)
	var targets_in_frustum: Array[LockOnComponent] = _get_targets_in_frustum()

	var closest_dist: float
	var closest_target: LockOnComponent = null

	if targets_in_frustum.size() == 0:
		target = null
		return

	for t in targets_in_frustum:
		var dist: float = viewport_center.distance_to(cam.unproject_position(t.global_position))
		if closest_target == null or dist < closest_dist:
			closest_dist = dist
			closest_target = t

	target = closest_target


func _change_target_right() -> void:
	var cam: Camera3D = get_viewport().get_camera_3d()
	var targets_in_frustum: Array[LockOnComponent] = _get_targets_in_front()

	if targets_in_frustum.size() == 0:
		target = null
		return
	targets_in_frustum.erase(target)

	var closest_dist: float
	var target_target: LockOnComponent = null
	var current_target_pos: Vector2 = cam.unproject_position(target.global_position)

	for t in targets_in_frustum:
		var pos: Vector2 = cam.unproject_position(t.global_position)
		var dist: float = current_target_pos.distance_to(pos)

		if pos.x > current_target_pos.x and (target_target == null or dist <= closest_dist):
			closest_dist = dist
			target_target = t

	if not target_target:
		var furthest_dst: float
		for t in targets_in_frustum:
			var pos: Vector2 = cam.unproject_position(t.global_position)
			var dist: float = current_target_pos.distance_to(pos)

			if pos.x < current_target_pos.x and (target_target == null or dist >= furthest_dst):
				furthest_dst = dist
				target_target = t

	target = target_target if target_target else target


func _change_target_left() -> void:
	var cam: Camera3D = get_viewport().get_camera_3d()
	var targets_in_frustum: Array[LockOnComponent] = _get_targets_in_front()

	if targets_in_frustum.size() == 0:
		target = null
		return
	targets_in_frustum.erase(target)

	var closest_dist: float
	var target_target: LockOnComponent = null
	var current_target_pos: Vector2 = cam.unproject_position(target.global_position)

	for t in targets_in_frustum:
		var pos: Vector2 = cam.unproject_position(t.global_position)
		var dist: float = current_target_pos.distance_to(pos)

		if pos.x < current_target_pos.x and (target_target == null or dist <= closest_dist):
			closest_dist = dist
			target_target = t

	if not target_target:
		var furthest_dst: float
		for t in targets_in_frustum:
			var pos: Vector2 = cam.unproject_position(t.global_position)
			var dist: float = current_target_pos.distance_to(pos)

			if pos.x > current_target_pos.x and (target_target == null or dist >= furthest_dst):
				furthest_dst = dist
				target_target = t

	target = target_target if target_target else target
