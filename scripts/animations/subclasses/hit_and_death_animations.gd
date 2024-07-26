class_name HitAndDeathAnimations
extends BaseAnimations


signal hit_finished

@export_category("Hit Configuration")
@export var hit_duration: float = 0.3
@export var hit_trim: float = 0.0
@export var hit_speed: float = 1.0

@export_category("Death Forwards Configuration")
@export var death_forwards_trim: float = 0.0
@export var death_forwards_speed: float = 1.0

@export_category("Death Backwards Configuration")
@export var death_backwards_trim: float = 0.0
@export var death_backwards_speed: float = 1.0

var _death: bool = false
var _blend_death: bool = false

var _blend: float = 0.0

var _hit_timer: Timer

var _can_emit_hit_finished: bool = false


func _ready():
	_hit_timer = Timer.new()
	_hit_timer.wait_time = hit_duration
	_hit_timer.one_shot = true
	_hit_timer.autostart = false
	_hit_timer.timeout.connect(
		func():
			_blend_death = false
	)
	add_child(_hit_timer)


func _physics_process(_delta) -> void:
	if _death:
		_blend_death = true
	
	if BaseAnimations.should_return_blend(_blend_death, _blend): return
	
	var blend = anim_tree.get(&"parameters/Death/blend_amount")
	if blend == null: return
	
	_blend = lerp(
		float(blend),
		1.0 if _blend_death else 0.0,
		0.2 if _blend_death else 0.05
	)
	
	anim_tree.set(
		&"parameters/Death/blend_amount",
		_blend
	)
	
	if _can_emit_hit_finished and float(blend) < 0.1:
		_can_emit_hit_finished = false
		hit_finished.emit()


func hit() -> void:
	if _death:
		return
	
	_can_emit_hit_finished = true
	
	anim_tree.set(&"parameters/Death 2 Trim/seek_request", hit_trim)
	anim_tree.set(&"parameters/Death 2 Speed/scale", hit_speed)
	anim_tree.set(&"parameters/Death Which One/transition_request", &"death_2")
	_blend_death = true
	_hit_timer.start()


func death_1() -> void:
	anim_tree.set(&"parameters/Death 1 Trim/seek_request", death_backwards_trim)
	anim_tree.set(&"parameters/Death 1 Speed/scale", death_backwards_speed)
	anim_tree.set(&"parameters/Death Which One/transition_request", &"death_1")
	_death = true


func death_2() -> void:
	anim_tree.set(&"parameters/Death 2 Trim/seek_request", death_forwards_trim)
	anim_tree.set(&"parameters/Death 2 Speed/scale", death_forwards_speed)
	anim_tree.set(&"parameters/Death Which One/transition_request", &"death_2")
	_death = true


func interrupt_blend_death() -> void:
	_blend_death = false
	anim_tree.set(&"parameters/Death/blend_amount", 0.0)


func reset_death() -> void:
	_death = false
	_blend_death = false
