class_name NonMeleeAnimations
extends BaseAnimations


signal can_rotate(flag: bool)
signal secondary_movement(action: NonMeleeAction)
signal action_effect(index: int)
signal end_effect(index: int)
signal can_perform_again(flag: bool)
signal can_play_animation
signal animation_finished

var actions: Array[NonMeleeAction]

# this means if an active animation is currently occurring
var active: bool = false

# which action to do, meant to control animations
# for successive actions
var _level: int = 1

# this means that there is an intent to perform an action
var _intent_to_perform: bool = false

# this means that the action animation can play.
# meant to control when the next perform anim plays
# when doing successive actions
var _can_play_animation: bool = true

# will be checked to decide whether to stop
# the active animation
var _intend_to_stop_performing: bool = true


func _ready() -> void:
	anim_tree.set(&"parameters/Non Melee/blend_amount", 0.0)
	for child in get_children():
		actions.append(child)


func _physics_process(_delta: float) -> void:
	if debug:
		pass
	
	if _can_play_animation and _intent_to_perform:
		
		actions[_level].play_animation()
		_can_play_animation = false
		_intent_to_perform = false
	
	var blend = anim_tree.get(&"parameters/Non Melee/blend_amount")
	if blend == null: return
	anim_tree.set(
		&"parameters/Non Melee/blend_amount",
		lerp(
			float(blend), 
			1.0 if active else 0.0,
			0.15
		)
	)


func start_action(level: int, override_can_play: bool = false) -> void:
	print(level)
	active = true
	_intent_to_perform = true
	_intend_to_stop_performing = false
	if override_can_play:
		_can_play_animation = true
	_level = level


func stop_action() -> void:
	_can_play_animation = true
	can_rotate.emit(true)
	active = false


func receive_prevent_rotation() -> void:
	can_rotate.emit(false)


func receive_secondary_movement() -> void:
	if not actions[_level].secondary_movement:
		return
	secondary_movement.emit(actions[_level])


func receive_action_effect() -> void:
	action_effect.emit(_level)


func receive_end_effect() -> void:
	end_effect.emit(_level)


func receive_can_perform_again() -> void:
	can_perform_again.emit(true)
	_intend_to_stop_performing = true


func receive_cannot_perform_again() -> void:
	can_perform_again.emit(false)


func receive_can_play_animation() -> void:
	can_play_animation.emit()
	_can_play_animation = true


func receive_finished() -> void:
	_level = 0
	if _intend_to_stop_performing and active:
		animation_finished.emit()
		stop_action()
