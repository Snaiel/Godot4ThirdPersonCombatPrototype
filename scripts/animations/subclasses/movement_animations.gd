class_name MovementAnimations
extends BaseAnimations


@export var enabled: bool = true
@export var movement_animations: Array[String]
@export var audio_footsteps: AudioFootsteps

var speed: float = 1.0:
	set(value):
		if speed == value: return
		speed = value

var dir: Vector3 = Vector3.ZERO

var _input_dir: Vector2 = Vector2.ZERO


func _ready():
	if movement_animations:
		set_state(movement_animations[0].to_lower())


func _physics_process(_delta: float) -> void:
	if not enabled: return
	
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
	
	# variable lerp done so that if the length of the input direction
	# is bigger than previous, we want a faster transition.
	# but if it's going to zero, let it be a smoother transition.
	_input_dir = _input_dir.lerp(
		new_dir,
		0.3 if (new_dir.length() - _input_dir.length()) > 0 else 0.1
	)
	
	for anim in movement_animations:
		anim_tree.set(
			"parameters/%s Direction/blend_position" % [anim],
			_input_dir
		)
		anim_tree.set(
			"parameters/%s Speed/scale" % [anim],
			speed
		)
	
	audio_footsteps.can_play = _input_dir.length() > 0.01


func set_state(anim_name: String) -> void:
	anim_tree.set(&"parameters/Movement Method/transition_request", anim_name)
