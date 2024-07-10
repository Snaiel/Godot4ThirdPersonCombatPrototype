class_name DrinkAnimations
extends BaseAnimations


signal gain_health
signal finished
signal interupted


var _blend_drinking: bool = false
var _interupted: bool = false

func _physics_process(_delta):
	var blend = anim_tree.get(&"parameters/Drinking/blend_amount")
	if blend == null: return
	anim_tree.set(
		&"parameters/Drinking/blend_amount",
		lerp(
			float(blend),
			1.0 if _blend_drinking else 0.0,
			0.05
		)
	)


func drink() -> void:
	_blend_drinking = true
	_interupted = false
	anim_tree.set(&"parameters/Drinking Trim/seek_request", 1.5)
	anim_tree.set(&"parameters/Drinking Speed/scale", 1.5)


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
