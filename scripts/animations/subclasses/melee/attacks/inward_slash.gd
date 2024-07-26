class_name InwardMeleeAttack
extends MeleeAttack


@export var trim: float = 0.3
@export var speed: float = 1.5


func _ready():
	attack_name = "inward_slash"


func play_attack():
	if _play_copy:
		anim_tree.set(&"parameters/Attack Inward Slash Copy/Inward Slash and Walk Blend/blend_amount", 0.0)
		anim_tree.set(&"parameters/Attack Inward Slash Copy/Inward Slash Trim/seek_request", trim)
		anim_tree.set(&"parameters/Attack Inward Slash Copy/Inward Slash Speed/scale", speed)
		anim_tree.set(&"parameters/Attack Inward Slash Copy/Walk Forwards Trim/seek_request", 0.55)
		anim_tree.set(&"parameters/Attack Inward Slash Copy/Walk Forwards Speed/scale", 0.0)
		anim_tree.set(&"parameters/Melee Attack/transition_request", &"inward_slash_copy")
		_play_copy = false
	else:
		anim_tree.set(&"parameters/Attack Inward Slash/Inward Slash and Walk Blend/blend_amount", 0.0)
		anim_tree.set(&"parameters/Attack Inward Slash/Inward Slash Trim/seek_request", trim)
		anim_tree.set(&"parameters/Attack Inward Slash/Inward Slash Speed/scale", speed)
		anim_tree.set(&"parameters/Attack Inward Slash/Walk Forwards Trim/seek_request", 0.55)
		anim_tree.set(&"parameters/Attack Inward Slash/Walk Forwards Speed/scale", 0.0)
		anim_tree.set(&"parameters/Melee Attack/transition_request", &"inward_slash")
		_play_copy = true


func play_legs() -> void:
	anim_tree.set(&"parameters/Attack Inward Slash/Walk Forwards Speed/scale", 0.8)
	anim_tree.set(&"parameters/Attack Inward Slash Copy/Walk Forwards Speed/scale", 0.8)
	
	var params: Array[String] = [
		"parameters/Attack Inward Slash/Inward Slash and Walk Blend/blend_amount",
		"parameters/Attack Inward Slash Copy/Inward Slash and Walk Blend/blend_amount"
	]
	
	for param in params:
		create_tween().tween_property(
			anim_tree,
			param,
			1.0,
			0.3
		)


func end_legs_transition():
	var scale = anim_tree.get(&"parameters/Attack Inward Slash/Walk Forwards Speed/scale")
	
	if scale == null: return
	
	var params: Array[String] = [
		"parameters/Attack Inward Slash/Walk Forwards Speed/scale",
		"parameters/Attack Inward Slash Copy/Walk Forwards Speed/scale"
	]
	
	for param in params:
		create_tween().tween_property(
			anim_tree,
			param,
			0.05,
			0.2
		)
