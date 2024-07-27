class_name MovementAnimations
extends BaseAnimations


@export var enabled: bool = true
@export var movement_animations: Array[String]
@export var audio_footsteps: AudioFootsteps

var speed: float = 1.0:
	set(value):
		if speed == value: return
		speed = value
		for anim in movement_animations:
			anim_tree.set(
				"parameters/%s Speed/scale" % [anim],
				speed
			)

var dir: Vector3 = Vector3.ZERO

var _input_dir: Vector2 = Vector2.ZERO:
	set(value):
		if value == _input_dir: return
		var threshold: float = 0.02
		if _input_dir.length() > threshold and not audio_footsteps.can_play:
			audio_footsteps.can_play = true
		elif _input_dir.length() <= threshold and audio_footsteps.can_play:
			audio_footsteps.can_play = false
		_input_dir = value

var _blend: float = 0.0


func _ready():
	if movement_animations:
		set_state(movement_animations[0].to_lower())


func _physics_process(_delta: float) -> void:
	if not enabled: return
	
	var should_blend: bool = _input_dir.length() > 0.5
	if not BaseAnimations.should_return_blend(should_blend, _blend):
		var param: StringName = &"parameters/Movement/blend_amount"
		var blend = anim_tree.get(param)
	
		_blend = lerp(
			float(blend),
			1.0 if should_blend else 0.0,
			0.1
		)
		
		anim_tree.set(param, _blend)
	
	var new_dir = Vector2(dir.x, dir.z)
	if new_dir.is_equal_approx(_input_dir): return
	if _blend < 0.01: return
	
	# smoother transition if going to zero
	_input_dir = _input_dir.lerp(
		new_dir,
		0.3 if (new_dir.length() - _input_dir.length()) > 0 else 0.1
	)
	
	for anim in movement_animations:
		anim_tree.set(
			"parameters/%s Direction/blend_position" % [anim],
			_input_dir
		)


func set_state(anim_name: String) -> void:
	anim_tree.set(&"parameters/Movement Method/transition_request", anim_name)
