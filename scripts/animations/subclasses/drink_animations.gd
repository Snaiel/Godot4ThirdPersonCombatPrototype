class_name DrinkAnimations
extends BaseAnimations


signal gain_health
signal finished
signal interupted


var _interupted: bool = false
var _blend_drinking: bool = false
var _blend: float = 0.0


func _physics_process(_delta):
	if BaseAnimations.should_return_blend(_blend_drinking, _blend): return
	
	var blend = anim_tree.get(&"parameters/Drink/blend_amount")
	if blend == null: return
	
	_blend = lerp(
		float(blend),
		1.0 if _blend_drinking else 0.0,
		0.05
	)
	
	anim_tree.set(
		&"parameters/Drink/blend_amount",
		_blend
	)


func drink() -> void:
	_blend_drinking = true
	_interupted = false
	anim_tree.set(&"parameters/Drink Trim/seek_request", 1.5)
	anim_tree.set(&"parameters/Drink Speed/scale", 1.5)


func interupt_drink() -> void:
	_blend_drinking = false
	_interupted = true
	interupted.emit()


func receive_gain_health() -> void:
	if _interupted: return
	gain_health.emit()


func receive_finished() -> void:
	if _interupted: return
	_blend_drinking = false
	finished.emit()
