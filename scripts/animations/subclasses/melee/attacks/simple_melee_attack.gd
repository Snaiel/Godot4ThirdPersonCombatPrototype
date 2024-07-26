class_name SimpleMeleeAttack
extends MeleeAttack


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
	
	_play_attack(_play_copy)
	_play_copy = not _play_copy


func _play_attack(copy: bool = false):
	var prefix = "parameters/%s%s/%s " % [
		_attack_name, " Copy" if copy else "", _attack_name
	]
	anim_tree.set(prefix + "Trim/seek_request", trim)
	anim_tree.set(prefix + "Speed/scale", animation_speed)
	anim_tree.set(
		"parameters/Melee Attack/transition_request",
		 _attack_name.to_snake_case() + ("_copy" if copy else "")
	)
