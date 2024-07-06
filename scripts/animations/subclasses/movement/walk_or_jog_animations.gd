class_name WalkOrJogAnimations
extends BaseMovementAnimations


var can_change_state: bool = true
var can_change_speed: bool = true

var _walk: bool = true
var _default_walk_speed: float = 1


func _ready() -> void:
	anim_tree.set(&"parameters/Free Walk Speed/scale", _default_walk_speed)


func _physics_process(_delta) -> void:
	var blend = anim_tree.get(&"parameters/Free Walk Or Jog/blend_amount")
	if blend == null: return
	anim_tree.set(
		&"parameters/Free Walk Or Jog/blend_amount",
		lerp(
			float(blend),
			0.0 if _walk else 1.0,
			0.2
		)
	)


func reset_walk_speed() -> void:
	set_walk_speed(_default_walk_speed)


func set_walk_speed(speed: float) -> void:
	if not can_change_speed: return
	anim_tree.set(&"parameters/Free Walk Speed/scale", speed)
	anim_tree.set(&"parameters/Locked On Walk Speed/scale", speed)


func to_walking() -> void:
	if not can_change_state: return
	_walk = true


func to_jogging() -> void:
	if not can_change_state: return
	_walk = false
