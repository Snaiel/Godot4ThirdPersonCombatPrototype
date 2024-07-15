class_name InstabilityComponent
extends Node


signal instability_increased
signal full_instability


@export_category("Configuration")
@export var enabled: bool = true
@export var hitbox: HitboxComponent
@export var weapons: Array[DamageSource]
## can instability increase when we get parried
@export var instability_when_parried: bool = true
## can we reach max instability if we get parried
@export var max_from_parried: bool = true
## can we reach max instability if we parry others
@export var max_from_parrying: bool = true

@export_category("Instability")
@export var max_instability: float = 50.0
@export var instability: float = 0.0:
	set(value):
		instability = clamp(value, 0.0, max_instability)

@export_category("Instability Reduction")
@export var can_reduce_instability: bool = true
@export var reduction_pause_length: float = 2.0
@export var reduction_rate: float = 1

var full_instability_from_parry: bool = false
var source_causes_readied_finisher: bool = true

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
	
	for weapon in weapons:
		weapon.parried.connect(got_parried.bind(35))


func _physics_process(_delta):
	if _reduce_instability and can_reduce_instability:
		instability -= reduction_rate * _delta


func increment_instability(
		value: float,
		capped: bool = false,
		from_parry: bool = false,
		readied_finisher: bool = false
	) -> void:
	if not enabled: return
	if is_full_instability(): return
	
	if capped and instability + value >= max_instability:
		value = max_instability - instability - 0.01
	
	instability += value
	
	_reduce_instability = false
	_instability_reduction_pause_timer.stop()
	
	instability_increased.emit()
	
	source_causes_readied_finisher = readied_finisher
	
	if is_equal_approx(instability, max_instability):
		full_instability_from_parry = from_parry
		full_instability.emit()
	else:
		_instability_reduction_pause_timer.start()


func come_out_of_full_instability(multiplier: float) -> void:
	_reduce_instability = true
	instability = instability * multiplier


func is_full_instability() -> bool:
	return instability >= max_instability


func got_hit():
	if not enabled: return
	increment_instability(25)


func got_parried(amount: float, readied_finisher: bool = true) -> void:
	if not enabled: return
	if not instability_when_parried: return
	increment_instability(
		amount,
		not max_from_parried,
		true,
		readied_finisher
	)


func process_block():
	if not enabled: return
	increment_instability(15)


func process_parry():
	if not enabled: return
	increment_instability(8, not max_from_parrying, true)
