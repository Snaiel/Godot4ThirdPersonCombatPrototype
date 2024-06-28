class_name ParryComponent
extends Node3D


signal parried_incoming_hit(incoming_weapon: Weapon)


@export var hitbox_component: HitboxComponent
@export var block_component: BlockComponent
@export var parry_particles_scene: PackedScene = preload("res://scenes/particles/ParryParticles.tscn")
@export var parry_particles_colour: Color

var in_parry_window: bool = false:
	set = set_in_parry_window

var _parry_particles: GPUParticles3D

var _parry_timer: Timer
var _parry_index: int = 0
var _parry_interval: Array[float] = [
	0.2,
	0.1,
	0.05,
	0
]

var _parry_cooldown_timer: Timer
var _parry_cooldown: float = 0.4


func _ready() -> void:
	hitbox_component.weapon_hit.connect(
		func(incoming_weapon: Weapon):
			if in_parry_window:
				parried_incoming_hit.emit(incoming_weapon)
	)
	
	
	_parry_particles = parry_particles_scene.instantiate()
	# this is ridiculous. you need to do duplicate the various
	# attributes so that they aren't shared across instances.
	#
	# found similar problem and subsequent solution:
	# https://forum.godotengine.org/t/reusing-particlesmaterial-causes-referencing-issues/28299/3
	#
	# relevent github issue:
	# https://github.com/godotengine/godot/issues/74918
	_parry_particles.process_material = _parry_particles.process_material.duplicate()
	_parry_particles.process_material.color_ramp = _parry_particles.process_material.color_ramp.duplicate()
	_parry_particles.process_material.color_ramp.gradient = _parry_particles.process_material.color_ramp.gradient.duplicate()
	_parry_particles.process_material.color_ramp.gradient.set_color(
		1, 
		parry_particles_colour
	)
	add_child(_parry_particles)
	
	
	_parry_timer = Timer.new()
	_parry_timer.wait_time = _parry_interval[_parry_index]
	_parry_timer.autostart = false
	_parry_timer.one_shot = true
	_parry_timer.timeout.connect(
		func():
			in_parry_window = false
#			print("parry window closed!")
	)
	add_child(_parry_timer)
	
	_parry_cooldown_timer = Timer.new()
	_parry_cooldown_timer.wait_time = _parry_cooldown
	_parry_cooldown_timer.autostart = false
	_parry_cooldown_timer.one_shot = true
	add_child(_parry_cooldown_timer)


func set_in_parry_window(value: bool) -> void:
	if value == in_parry_window: return
	in_parry_window = value


func parry() -> void:
#	prints('spamming?', is_spamming())
	if _parry_cooldown_timer.is_stopped():
		_parry_index = 0
	else:
		_parry_index += 1
	
	if _parry_index > 3:
		_parry_index = 3
	
#	prints("parry interval:", _parry_interval[_parry_index])
	
	_parry_cooldown_timer.start()
	if _parry_index == 3:
		return
	
	in_parry_window = true
	_parry_timer.start(_parry_interval[_parry_index])
	
#	print("parry window open!")


func is_spamming() -> bool:
	return not _parry_cooldown_timer.is_stopped() and \
	_parry_index > 0


func reset_parry_cooldown() -> void:
	_parry_cooldown_timer.stop()


func play_parry_particles() -> void:
	_parry_particles.restart()
