class_name DodgeComponent
extends Node


@export var dodge_strength: float = 7

# This is the time before touching the ground
# that an intent to dodge can be made and it
# letting the dodge go through once on the ground
@export var _in_air_buffer: float = 0.1

@export_category("References")
@export var entity: Player
@export var rotation_component: RotationComponent
@export var locomotion_component: LocomotionComponent
@export var jump_component: JumpComponent
@export var sfx: AudioStreamPlayer3D


var dodging: bool = false
var can_dodge: bool = true

var intent_to_dodge: bool:
	set = set_intent_to_dodge
	
var can_set_intent_to_dodge: bool = true

var _intent_start_time: int
var _time_since_intent_and_floor: float

var _in_air: bool = false


func _ready():
	jump_component.just_landed.connect(_receieve_just_landed)


func _physics_process(_delta: float) -> void:
	if not entity.is_on_floor():
		_in_air = true
	
	if can_dodge and intent_to_dodge and not _in_air:
		_dodge()


func set_intent_to_dodge(intent: bool) -> void:
	if intent:
		_intent_start_time = Time.get_ticks_msec()
	intent_to_dodge = intent
	

func _dodge() -> void:
	intent_to_dodge = false
	can_set_intent_to_dodge = false
	can_dodge = false
	dodging = true
	
	locomotion_component.vertical_movement = false
	
	if rotation_component.move_direction.length() > 0.05:
		locomotion_component.desired_velocity += rotation_component\
			.move_direction.normalized() * dodge_strength
	elif entity.lock_on_target:
		locomotion_component.desired_velocity += -Vector3(
			locomotion_component.looking_direction.x,
			0,
			locomotion_component.looking_direction.z
		).normalized() * dodge_strength
	else:
		locomotion_component.desired_velocity += locomotion_component\
			.looking_direction.normalized() * dodge_strength
	
	sfx.play()
	
	# how long the dodge status lasts
	var dodge_timer: SceneTreeTimer = get_tree().create_timer(0.2)
	# after this time, presing dodge again will dodge as soon as possible
	var register_next_dodge_timer: SceneTreeTimer = get_tree().create_timer(0.3)
	# this is the time it takes for the next dodge to actually occur
	var can_dodge_timer: SceneTreeTimer = get_tree().create_timer(0.8)

	dodge_timer.connect("timeout", _finish_dodging)
	register_next_dodge_timer.connect("timeout", _register_next_dodge_input)
	can_dodge_timer.connect("timeout", _can_dodge_again)


func _finish_dodging() -> void:
	dodging = false


func _register_next_dodge_input() -> void:
	can_set_intent_to_dodge = true


func _can_dodge_again() -> void:
	can_dodge = true


func _receieve_just_landed() -> void:
	var time_just_landed: int = Time.get_ticks_msec()
	_time_since_intent_and_floor = float(time_just_landed - _intent_start_time) / 1000.0	
#	prints(_intent_start_time, time_just_landed, _time_since_intent_and_floor, _in_air_buffer)
	if intent_to_dodge and _time_since_intent_and_floor > _in_air_buffer:
		intent_to_dodge = false
	_in_air = false
