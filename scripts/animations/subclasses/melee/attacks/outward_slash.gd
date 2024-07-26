class_name OutwardMeleeAttack
extends MeleeAttack


@export var trim: float = 0.75
@export var speed: float = 1.8


func _ready():
	attack_name = "outward_slash"


func play_attack():
	if _play_copy:
		anim_tree.set(&"parameters/Attack Outward Slash Copy/Outward Slash and Walk Blend/blend_amount", 1.0)
		anim_tree.set(&"parameters/Attack Outward Slash Copy/Outward Slash Trim/seek_request", trim)
		anim_tree.set(&"parameters/Attack Outward Slash Copy/Outward Slash Speed/scale", speed)
		anim_tree.set(&"parameters/Attack Outward Slash Copy/Walk Forwards Trim/seek_request", 0.9)
		anim_tree.set(&"parameters/Attack Outward Slash Copy/Walk Forwards Speed/scale", 0.0)
		anim_tree.set(&"parameters/Melee Attack/transition_request", &"outward_slash_copy")
		_play_copy = false
	else:
		anim_tree.set(&"parameters/Attack Outward Slash/Outward Slash and Walk Blend/blend_amount", 1.0)
		anim_tree.set(&"parameters/Attack Outward Slash/Outward Slash Trim/seek_request", trim)
		anim_tree.set(&"parameters/Attack Outward Slash/Outward Slash Speed/scale", speed)
		anim_tree.set(&"parameters/Attack Outward Slash/Walk Forwards Trim/seek_request", 0.9)
		anim_tree.set(&"parameters/Attack Outward Slash/Walk Forwards Speed/scale", 0.0)
		anim_tree.set(&"parameters/Melee Attack/transition_request", &"outward_slash")
		_play_copy = true


func play_legs() -> void:
	anim_tree.set(&"parameters/Attack Outward Slash/Walk Forwards Speed/scale", 0.8)
	anim_tree.set(&"parameters/Attack Outward Slash Copy/Walk Forwards Speed/scale", 0.8)
	
	var params: Array[String] = [
		"parameters/Attack Outward Slash/Outward Slash and Walk Blend/blend_amount",
		"parameters/Attack Outward Slash Copy/Outward Slash and Walk Blend/blend_amount"
	]
	
	for param in params:
		create_tween().tween_property(
			anim_tree,
			param,
			1.0,
			0.3
		)


func perform_legs_transition():
	pass


func end_legs_transition():
	
	var scale = anim_tree.get(&"parameters/Attack Outward Slash/Walk Forwards Speed/scale")
	if scale == null: return
	
	var params: Array[String] = [
		"parameters/Attack Outward Slash/Walk Forwards Speed/scale",
		"parameters/Attack Outward Slash Copy/Walk Forwards Speed/scale"
	]
	
	for param in params:
		create_tween().tween_property(
			anim_tree,
			param,
			0.05,
			0.2
		)
