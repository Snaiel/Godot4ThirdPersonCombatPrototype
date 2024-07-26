class_name DizzyFinisherAnimations
extends BaseAnimations


signal dizzy_finisher_finished


# signifies that the character is in the process
# of performing the finisher on the dizzy victim
var attacking: bool = false

# flag that dictates whether to play the finisher anim
var _blend_dizzy_finisher: bool = false
var _blend: float = 0.0


func _physics_process(_delta):
	if BaseAnimations.should_return_blend(_blend_dizzy_finisher, _blend): return
	
	var blend = anim_tree.get(&"parameters/Dizzy Finisher/blend_amount")
	if blend == null: return
	
	_blend = move_toward(
		float(blend),
		1.0 if _blend_dizzy_finisher else 0.0,
		0.1
	)
	
	anim_tree.set(
		&"parameters/Dizzy Finisher/blend_amount",
		_blend
	)


func play_from_parry_pre_finisher() -> void:
	_blend_dizzy_finisher = true
	anim_tree.set(&"parameters/Dizzy Finisher Which One/transition_request", &"from_parry")
	anim_tree.set(&"parameters/Dizzy Finisher From Parry Speed/scale", 0.0)
	anim_tree.set(&"parameters/Dizzy Finisher From Parry Trim/seek_request", 0.0)


func play_from_parry_finisher() -> void:
	anim_tree.set(&"parameters/Dizzy Finisher From Parry Speed/scale", 1.5)


func play_from_damage_finisher() -> void:
	_blend_dizzy_finisher = true
	anim_tree.set(&"parameters/Dizzy Finisher Which One/transition_request", &"from_damage")
	anim_tree.set(&"parameters/Dizzy Finisher From Damage Trim/seek_request", 1.8)
	anim_tree.set(&"parameters/Dizzy Finisher From Damage Speed/scale", 1.5)


func set_dizzy_finisher(from_parry: bool) -> void:
	if from_parry:
		_blend_dizzy_finisher = true
		anim_tree.set(&"parameters/Dizzy Finisher Which One/transition_request", &"from_parry")
		if attacking:
			anim_tree.set(&"parameters/Dizzy Finisher From Parry Speed/scale", 1.5)
		else:
			anim_tree.set(&"parameters/Dizzy Finisher From Parry Speed/scale", 0.0)
			anim_tree.set(&"parameters/Dizzy Finisher From Parry Trim/seek_request", 0.0)
	elif attacking:
		attacking = false
		# if victim is dizzy from damage, we still want to be able
		# to walk around and do normal stuff. that's why
		# _blend_dizzy_finisher is only set to true only if attacking
		_blend_dizzy_finisher = true
		anim_tree.set(&"parameters/Dizzy Finisher Which One/transition_request", &"from_damage")
		anim_tree.set(&"parameters/Dizzy Finisher From Damage Trim/seek_request", 1.8)
		anim_tree.set(&"parameters/Dizzy Finisher From Damage Speed/scale", 1.5)


func receive_dizzy_finisher_finished() -> void:
	attacking = false
	_blend_dizzy_finisher = false
	dizzy_finisher_finished.emit()
