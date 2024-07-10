class_name MovementAnimations
extends BaseAnimations


@export var audio_footsteps: AudioFootsteps

var movement_animations: Array[BaseMovementAnimations]
var current_state: BaseMovementAnimations

var speed: float = 1.0:
	set(value):
		if speed == value: return
		speed = value

var dir: Vector3 = Vector3.ZERO

var _input_dir: Vector2 = Vector2.ZERO


func _ready():
	for child in get_children():
		movement_animations.append(child)
	current_state = movement_animations[0]


func _physics_process(_delta: float) -> void:
	var new_dir = Vector2(dir.x, dir.z)
	_input_dir = _input_dir.lerp(new_dir, 0.3)
	
	for anim in movement_animations:
		anim.move(
			_input_dir,
			anim == current_state
		)
		anim.speed = speed
	
	if _input_dir.length() > 0.01:
		audio_footsteps.can_play = true
	else:
		audio_footsteps.can_play = false


func set_state(anim_name: String) -> void:
	var child = get_node_or_null(anim_name.to_pascal_case())
	if not child: return
	if current_state == child: return
	current_state = child
