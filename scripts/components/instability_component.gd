class_name InstabilityComponent
extends Node3D


signal instability_increased
signal full_instability


@export_category("Configuration")
@export var enabled: bool = true
@export var hitbox: HitboxComponent
@export var weapon: Sword
@export var receive_weapon_parried: bool = true

@export_category("Instability")
@export var max_instability: float = 100.0
@export var instability: float = 0.0:
	set(value):
		instability = clamp(value, 0.0, max_instability)

@export_category("Instability Reduction")
@export var can_reduce_instability: bool = true
@export var reduction_pause_length: float = 2.0
@export var reduction_rate: float = 0.2

var full_instability_from_parry: bool = false

var _instability_reduction_pause_timer: Timer
var _reduce_instability: bool = false




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
			if not enabled:
				return
			
			if not receive_weapon_parried:
				return
			
			increment_instability(35, true)
	)


func _physics_process(_delta):
	if _reduce_instability and can_reduce_instability:
		instability -= reduction_rate


func come_out_of_full_instability(multiplier: float) -> void:
	_reduce_instability = true
	instability = instability * multiplier


func is_full_instability() -> bool:
	return instability >= max_instability


func increment_instability(value: float, from_parry: bool = false):
	if is_full_instability():
		return
	
	instability += value
	
	_reduce_instability = false
	_instability_reduction_pause_timer.stop()
	
	instability_increased.emit()
	
	if is_equal_approx(instability, max_instability):
		full_instability_from_parry = from_parry
		full_instability.emit()
	else:
		_instability_reduction_pause_timer.start()


func process_hit():
	if not enabled:
		return
	increment_instability(25, false)


func process_block():
	if not enabled:
		return
	increment_instability(15, false)


func process_parry():
	if not enabled:
		return
	increment_instability(8, false)
