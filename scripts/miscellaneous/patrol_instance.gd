class_name PatrolInstance
extends PathFollow3D


signal move(flag: bool)


enum PatrolType {LINEAR, OSCILLATE, CIRCUIT}


@export var show_mesh: bool = false
@export var patrol_type: PatrolType
@export var patrol: bool = true
@export var speed: float = 3.0
@export var stationary_time: float = 8.0
@export var initial_delay: float = 0.0

var direction: int = 1

var _previous_direction: int
var _can_emit_move: bool = true
var _stationary_timer: Timer


func _ready():
	$Mesh.visible = show_mesh
	
	if patrol_type != PatrolType.CIRCUIT:
		loop = false
	
	_stationary_timer = Timer.new()
	_stationary_timer.autostart = false
	_stationary_timer.wait_time = stationary_time
	_stationary_timer.one_shot = true
	_stationary_timer.timeout.connect(
		func():
			move.emit(true)
			if _previous_direction == 1:
				direction = -1
			elif _previous_direction == -1:
				direction = 1
	)
	add_child(_stationary_timer)
	
	if initial_delay > 0:
		patrol = false
		get_tree().create_timer(initial_delay).timeout.connect(
			func(): patrol = true
		)
	
	move.emit(true)


func _process(delta: float) -> void:
	if not patrol: return
	match patrol_type:
		PatrolType.LINEAR: _handle_linear_patrol(delta)
		PatrolType.OSCILLATE: _handle_oscillate_patrol(delta)
		PatrolType.CIRCUIT: _handle_circuit_patrol(delta)


func _handle_linear_patrol(delta: float) -> void:
	if progress_ratio < 1.0:
		progress += direction * speed * delta
	elif _can_emit_move:
		move.emit(false)
		_can_emit_move = false


func _handle_oscillate_patrol(delta: float) -> void:
	if (direction == 1 and progress_ratio >= 1) or \
	(direction == -1 and progress_ratio <= 0):
		_previous_direction = direction
		direction = 0
		if _can_emit_move:
			_can_emit_move = false
			move.emit(false)
			_stationary_timer.start()
	else:
		progress += direction * speed * delta
		_can_emit_move = true


func _handle_circuit_patrol(delta: float) -> void:
	progress += direction * speed * delta
