class_name AttackAnimations
extends BaseAnimations

signal attacking_can_stop
signal attacking_finished

func prevent_rotation():
	var flag = false
	parent_animations.movement_animations.can_rotate.emit(flag)

func can_stop_attacking():
	attacking_can_stop.emit()
	
func can_attack_again():
	pass

func _on_animation_tree_animation_finished(anim_name):
	if "combat_animations_1" in anim_name:
		anim_tree["parameters/Attacking/transition_request"] = "not_attacking"
		attacking_finished.emit()
		parent_animations.movement_animations.can_rotate.emit(true)		
