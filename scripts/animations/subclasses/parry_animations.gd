class_name ParryAnimations
extends BaseAnimations


var _parrying: bool = false
var _blend: float = 0.0


func _physics_process(_delta) -> void:
	if BaseAnimations.should_return_blend(_parrying, _blend): return
	
	var blend = anim_tree.get(&"parameters/Parry/blend_amount")
	if debug: prints(_parrying, blend)
	if blend == null: return
	
	_blend = lerp(
		float(blend),
		1.0 if _parrying else 0.0,
		0.2 if _parrying else 0.15
	)
	
	anim_tree.set(
		&"parameters/Parry/blend_amount",
		_blend
	)


func parry() -> void:
	_parrying = true
	anim_tree.set(&"parameters/Parry Trim/seek_request", 0.35)
	anim_tree.set(&"parameters/Parry Speed/scale", 2.0)


func receive_parry_recovery() -> void:
	anim_tree.set(&"parameters/Parry Speed/scale", 0.5)


func receive_parry_finished() -> void:
	_parrying = false
