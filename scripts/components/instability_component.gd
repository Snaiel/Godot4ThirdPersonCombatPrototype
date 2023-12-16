class_name InstabilityComponent
extends Node3D


signal instability_increased
signal full_instability

@export_category("Configuration")
@export var active: bool = true
@export var hitbox: HitboxComponent

@export_category("Instability")
@export var max_instability: float = 100.0

@export_category("Instability Reduction")
var reduction_pause_length: float = 2.0
var reduction_rate: float = 5.0

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


func _process(delta):
	if _reduce_instability:
		_instability -= reduction_rate * delta


func get_instability() -> float:
	return _instability


func increment_instability(value: float):
	_instability += value
	instability_increased.emit()
	_reduce_instability = false
	_instability_reduction_pause_timer.start()


func _on_hitbox_component_weapon_hit(_weapon: Sword):
	increment_instability(8.0)


func _on_sword_parried():
	increment_instability(35.0)
