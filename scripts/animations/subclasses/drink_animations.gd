class_name DrinkAnimations
extends BaseAnimations


signal gain_health
signal finished
signal interupted

@export var walk_or_jog_animations: WalkOrJogAnimations

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
	walk_or_jog_animations.set_walk_speed(0.5)
	walk_or_jog_animations.to_walking()
	walk_or_jog_animations.can_change_state = false
	walk_or_jog_animations.can_change_speed = false
	_blend_drinking = true
	_interupted = false
	anim_tree.set(&"parameters/Drinking Trim/seek_request", 1.5)
	anim_tree.set(&"parameters/Drinking Speed/scale", 1.5)

func interupt_drink() -> void:
	walk_or_jog_animations.reset_walk_speed()
	walk_or_jog_animations.to_jogging()
	_blend_drinking = false
	_interupted = true
	interupted.emit()

func receive_gain_health() -> void:
	if _interupted:
		return
	
	walk_or_jog_animations.can_change_state = true
	walk_or_jog_animations.can_change_speed = true
	gain_health.emit()

func receive_finished() -> void:
	if _interupted:
		return
	
	walk_or_jog_animations.reset_walk_speed()
	walk_or_jog_animations.to_jogging()
	_blend_drinking = false
	finished.emit()
