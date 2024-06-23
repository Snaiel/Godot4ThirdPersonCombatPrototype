class_name SimpleAttackStrategy
extends AttackStrategy


@export var _attack_name: String
@export var has_copy: bool = false

@export_category("Animation Settings")
@export var trim: float = 0.0
@export var animation_speed: float = 1.0


func _ready():
	attack_name = _attack_name


func play_attack():
	if not has_copy:
		_play_attack()
		return
	
	if _play_copy:
		anim_tree["parameters/%s Copy/%s Trim/seek_request" % [_attack_name, _attack_name]] = trim
		anim_tree["parameters/%s Copy/%s Speed/scale" % [_attack_name, _attack_name]] = animation_speed
		anim_tree["parameters/Attack/transition_request"] = _attack_name.to_snake_case() + "_copy"
		_play_copy = false
	else:
		_play_attack()
		_play_copy = true


func _play_attack():
	anim_tree["parameters/%s/%s Trim/seek_request" % [_attack_name, _attack_name]] = trim
	anim_tree["parameters/%s/%s Speed/scale" % [_attack_name, _attack_name]] = animation_speed
	anim_tree["parameters/Attack/transition_request"] = _attack_name.to_snake_case()
