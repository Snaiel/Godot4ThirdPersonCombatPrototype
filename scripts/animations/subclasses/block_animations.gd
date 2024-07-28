class_name BlockAnimations
extends BaseAnimations


@export var shield_component: ShieldComponent

var _blend: float = 0.0


func _ready() -> void:
	anim_tree.set(&"parameters/Block Trim/seek_request", 0.35)
	anim_tree.set(&"parameters/Block Speed/scale", 0.0)


func _physics_process(_delta: float) -> void:
	var blocking = shield_component.blocking
	
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
