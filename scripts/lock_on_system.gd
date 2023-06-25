class_name LockOnSystem
extends Area3D

signal lock_on(enemy: Enemy)

@export var player: Player

@export_category("Enemies")
@export var enemy: Enemy = null
@export var potential_target: Enemy = null
@export var enemy_detection_range = 20


@export_category("Changing Target")
@export var change_target_mouse_threshold = 1
@export var change_target_wait_time = 0.2
@export var can_change_target = true

var _enemies_nearby: Array[Enemy]

@onready var _change_target_timer = $ChangeTargetTimer


# Called when the node enters the scene tree for the first time.
func _ready():
	Globals.lock_on_system = self
	_change_target_timer.wait_time = change_target_wait_time
	$EnemyDetectionSphere.shape.radius = enemy_detection_range

# Called every frame. 'delta' is the elapsed time since the previous frame.
func _process(_delta):
	position = player.position
	
	if Input.is_action_just_pressed("lock_on"):
		if enemy:
			enemy = null
		else:
			_choose_lock_on_enemy()
		lock_on.emit(enemy)
		print(enemy)
		
func _input(event):
	if event is InputEventMouseMotion:
		if not enemy:
			return
		
		var current_mouse_pos = event.relative
		
		if Vector2.ZERO.distance_to(current_mouse_pos) > change_target_mouse_threshold and can_change_target:
			if current_mouse_pos.x > 0:
				_change_target_right()
			else:
				_change_target_left()
			
			lock_on.emit(enemy)			
			can_change_target = false
			_change_target_timer.start()

func _on_body_entered(body):
	if body not in _enemies_nearby:
		_enemies_nearby.append(body)
	
func _on_body_exited(body):
	_enemies_nearby.erase(body)
	
func _on_change_target_timer_timeout():
	can_change_target = true
	
func _can_see_enemy(e: Enemy) -> bool:
	var can_see: bool = true
	var cam = get_viewport().get_camera_3d()	
	
	var space_state = get_world_3d().direct_space_state
	var query = PhysicsRayQueryParameters3D.create(cam.global_position, e.position, 1)
	var result = space_state.intersect_ray(query)
	
	can_see = result.size() == 0
	
	return can_see
	
func _get_enemies_in_front() -> Array[Enemy]:
	var enemies: Array[Enemy] = []
	var cam = get_viewport().get_camera_3d()
	
	for e in _enemies_nearby:
		if not cam.is_position_behind(e.position) and _can_see_enemy(e):
			enemies.append(e)
			
	return enemies
	
func _get_enemies_in_frustum() -> Array[Enemy]:
	var enemies: Array[Enemy] = []
	var cam = get_viewport().get_camera_3d()
	
	for e in _enemies_nearby:
		if cam.is_position_in_frustum(e.position) and _can_see_enemy(e):
			enemies.append(e)
			
	return enemies

func _choose_lock_on_enemy():
	var cam = get_viewport().get_camera_3d()
	var viewport_center = Vector2(get_viewport().size / 2)	
	var enemies_in_frustum = _get_enemies_in_frustum()
	
	var closest_dist: float 
	var closest_enemy: Enemy = null
			
	if enemies_in_frustum.size() == 0:
		enemy = null
		return
	
	print(enemies_in_frustum)
	for e in enemies_in_frustum:
		var dist = viewport_center.distance_to(cam.unproject_position(e.position))
		
		if closest_enemy == null or dist < closest_dist:
			closest_dist = dist
			closest_enemy = e
			
	enemy = closest_enemy

func _change_target_right():
	var cam = get_viewport().get_camera_3d()
	var enemies_in_frustum = _get_enemies_in_front()
			
	if enemies_in_frustum.size() == 0:
		enemy = null
		return
	enemies_in_frustum.erase(enemy)
	
	var closest_dist: float 
	var target_enemy: Enemy = null
	var current_target_pos = cam.unproject_position(enemy.position)
	
	for e in enemies_in_frustum:
		var pos = cam.unproject_position(e.position)
		var dist = current_target_pos.distance_to(pos)
		
		if pos.x > current_target_pos.x and (target_enemy == null or dist <= closest_dist):
			closest_dist = dist
			target_enemy = e
			
	if not target_enemy:
		var furthest_dst: float
		for e in enemies_in_frustum:
			var pos = cam.unproject_position(e.position)
			var dist = current_target_pos.distance_to(pos)
			
			if pos.x < current_target_pos.x and (target_enemy == null or dist >= furthest_dst):
				furthest_dst = dist
				target_enemy = e
			
	enemy = target_enemy if target_enemy else enemy
	
	
func _change_target_left():
	var cam = get_viewport().get_camera_3d()
	var enemies_in_frustum = _get_enemies_in_front()
			
	if enemies_in_frustum.size() == 0:
		enemy = null
		return
	enemies_in_frustum.erase(enemy)
	
	var closest_dist: float 
	var target_enemy: Enemy = null
	var current_target_pos = cam.unproject_position(enemy.position)
	
	for e in enemies_in_frustum:
		var pos = cam.unproject_position(e.position)
		var dist = current_target_pos.distance_to(pos)
		
		if pos.x < current_target_pos.x and (target_enemy == null or dist <= closest_dist):
			closest_dist = dist
			target_enemy = e
			
	if not target_enemy:
		var furthest_dst: float
		for e in enemies_in_frustum:
			var pos = cam.unproject_position(e.position)
			var dist = current_target_pos.distance_to(pos)
			
			if pos.x > current_target_pos.x and (target_enemy == null or dist >= furthest_dst):
				furthest_dst = dist
				target_enemy = e
			
	enemy = target_enemy if target_enemy else enemy
	
