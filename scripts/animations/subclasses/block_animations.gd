class_name BlockAnimations
extends BaseAnimations


var _blend: float = 0.0


func _ready() -> void:
	anim_tree.set(&"parameters/Block Trim/seek_request", 0.35)
	anim_tree.set(&"parameters/Block Speed/scale", 0.0)


func process_block(blocking: bool) -> void:
	if BaseAnimations.should_return_blend(blocking, _blend): return
	
	var blend = anim_tree.get(&"parameters/Block/blend_amount")
	if blend == null: return
	
	_blend = lerp(
		float(blend), 
		1.0 if blocking else 0.0, 
		0.2
	)
	
	anim_tree.set(
		&"parameters/Block/blend_amount",
		_blend
	)
