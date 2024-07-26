class_name  BaseAnimations
extends Node

@export var anim_tree: AnimationTree
@export var debug: bool = false


static func should_return_blend(flag: bool, blend: float) -> bool:
	return (flag and is_equal_approx(blend, 1.0)) or \
		(not flag and is_equal_approx(blend, 0.0))
