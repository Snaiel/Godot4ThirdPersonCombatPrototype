class_name BaseMovementAnimations
extends BaseAnimations


@export var anim_name: String

var dir: Vector2
var speed: float = 1.0:
	set(value):
		if speed == value: return
		speed = value


func _physics_process(_delta: float) -> void:
	anim_tree.set(
		"parameters/%s Direction/blend_position" % [anim_name],
		dir
	)
	anim_tree.set(
		"parameters/%s Speed/scale" % [anim_name],
		speed
	)
