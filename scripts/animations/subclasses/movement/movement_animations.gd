class_name MovementAnimations
extends BaseAnimations


@export var audio_footsteps: AudioFootsteps

var movement_animations: Array[BaseMovementAnimations]

var speed: float = 1.0:
	set(value):
		if speed == value: return
		speed = value

var dir: Vector3 = Vector3.ZERO

var _input_dir: Vector2 = Vector2.ZERO


func _ready():
	for child in get_children():
		movement_animations.append(child)


func _physics_process(_delta: float) -> void:
	
	var param: StringName = &"parameters/Movement/blend_amount"
	var blend = anim_tree.get(param)
	anim_tree.set(
		param,
		lerp(
			float(blend),
			1.0 if _input_dir.length() > 0.5 else 0.0,
			0.1
		)
	)
	
	var new_dir = Vector2(dir.x, dir.z)
	_input_dir = _input_dir.lerp(new_dir, 0.3)
	
	for anim in movement_animations:
		anim.dir = _input_dir
		anim.speed = speed
	
	if _input_dir.length() > 0.01:
		audio_footsteps.can_play = true
	else:
		audio_footsteps.can_play = false


func set_state(anim_name: String) -> void:
	anim_tree.set(&"parameters/Movement Method/transition_request", anim_name)
