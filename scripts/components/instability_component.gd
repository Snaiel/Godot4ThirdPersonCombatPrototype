class_name InstabilityComponent
extends Node3D


signal instability_increased
signal full_instability


@export_category("Configuration")
@export var active: bool = true
@export var hitbox: HitboxComponent
@export var weapon: Sword

@export_category("Instability")
@export var max_instability: float = 100.0

@export_category("Instability Reduction")
var reduction_pause_length: float = 2.0
var reduction_rate: float = 0.2

var full_instability_from_parry: bool = false

var _instability_reduction_pause_timer: Timer
var _reduce_instability: bool = false

var _instability: float = 0.0:
	set(value):
		_instability = clamp(value, 0.0, max_instability)


func _ready():
	_instability_reduction_pause_timer = Timer.new()
	_instability_reduction_pause_timer.wait_time = reduction_pause_length
	_instability_reduction_pause_timer.autostart = false
	_instability_reduction_pause_timer.one_shot = true
	_instability_reduction_pause_timer.timeout.connect(
		func():
			_reduce_instability = true
	)
	add_child(_instability_reduction_pause_timer)
	
	weapon.parried.connect(
		func():
			if not active:
				return
			increment_instability(35, true)
	)


func _physics_process(_delta):
	if _reduce_instability:
		_instability -= reduction_rate


func come_out_of_full_instability(multiplier: float) -> void:
	_reduce_instability = true
	_instability = _instability * multiplier


func is_full_instability() -> bool:
	return _instability >= max_instability


func get_instability() -> float:
	return _instability


func increment_instability(value: float, from_parry: bool = false):
	if is_full_instability():
		return
	
	_instability += value
	
	_reduce_instability = false
	_instability_reduction_pause_timer.stop()
	
	instability_increased.emit()
	
	if is_equal_approx(_instability, max_instability):
		full_instability_from_parry = from_parry
		full_instability.emit()
	else:
		_instability_reduction_pause_timer.start()


func process_hit():
	if not active:
		return
	increment_instability(25, false)
