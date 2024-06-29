class_name ParryAnimations
extends BaseAnimations


var _parrying: bool = false


func _physics_process(_delta) -> void:
	var blend = anim_tree.get(&"parameters/Parry/blend_amount")
	if blend == null: return
	anim_tree.set(
		&"parameters/Parry/blend_amount",
		lerp(
			float(blend),
			1.0 if _parrying else 0.0,
			0.2 if _parrying else 0.15
		)
	)


func parry() -> void:
	_parrying = true
	anim_tree.set(&"parameters/Parry Trim/seek_request", 0.35)
	anim_tree.set(&"parameters/Parry Speed/scale", 2.0)


func receive_parry_recovery() -> void:
	anim_tree.set(&"parameters/Parry Speed/scale", 0.5)


func receive_parry_finished() -> void:
	_parrying = false
