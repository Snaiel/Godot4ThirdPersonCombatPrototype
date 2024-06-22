class_name AttackAnimations
extends BaseAnimations


signal secondary_movement(attack: AttackStrategy)
signal can_damage(flag: bool)
signal can_rotate(flag: bool)
signal can_attack_again(flag: bool)
signal can_play_animation
signal attacking_finished


@export var attacks: Array[AttackStrategy]


# this means if an attacking animation is currently occurring
var attacking: bool = false

# which attack to do, meant to control animations
# for successive attacks
var _level: int = 1

# this means that there is an intent to attack
var _intent_to_attack: bool = false

# this means that the attack animation can play
# meant to control when the next attack plays
# when doing successive attacks
var _can_play_animation: bool = false

# will be checked to decide whether to stop
# the attacking animatino
var _intend_to_stop_attacking: bool = true

# A flag for whether to start transitioning
# the blend of the legs with the attack
# animation if it's 1, to slow down the
# legs animation to come to a stop when
# it's -1, and to do nothing when it's 0
var _transition_legs: int = 0


func _ready() -> void:
	anim_tree["parameters/Attacking/blend_amount"] = 0.0


func _physics_process(_delta: float) -> void:
	if debug:
		pass
	
	if attacking:
		anim_tree["parameters/Attacking/blend_amount"] = lerp(
			anim_tree["parameters/Attacking/blend_amount"], 
			1.0, 
			0.15
		)
	else:
		anim_tree["parameters/Attacking/blend_amount"] = lerp(
			anim_tree["parameters/Attacking/blend_amount"], 
			0.0, 
			0.1
		)

	if _transition_legs  == 1:
		attacks[_level].perform_legs_transition()
	elif _transition_legs == -1:
		attacks[_level].end_legs_transition()
	
	if _can_play_animation and _intent_to_attack:
		
		_transition_legs = 0
		
		attacks[_level].play_attack()
		
		_can_play_animation = false
		_intent_to_attack = false


func attack(level: int, manually_set_level: bool = false) -> void:
	attacking = true
	_intent_to_attack = true
	_intend_to_stop_attacking = false
	if level == 1 or manually_set_level:
		_can_play_animation = true
	_level = level


func stop_attacking() -> void:
	_can_play_animation = true
	can_rotate.emit(true)
	attacking = false


func receive_prevent_rotation() -> void:
	can_rotate.emit(false)


func receive_secondary_movement() -> void:
	secondary_movement.emit(attacks[_level])


func recieve_can_play_animation() -> void:
	can_play_animation.emit()
	_can_play_animation = true


func receive_play_legs() -> void:
	_transition_legs = 1
	attacks[_level].play_legs()


func receive_stop_legs(which_attack: StringName) -> void:
	# having a check for the level originating from the animation
	# against the current attack _level to see whether
	# to actually transition out of the current animation's legs
	if which_attack == attacks[_level].attack_name:
		_transition_legs = -1


func receive_can_damage() -> void:
	can_damage.emit(true)


func receive_cannot_damage() -> void:
	can_damage.emit(false)


func receive_can_attack_again() -> void:
	can_attack_again.emit(true)
	_intend_to_stop_attacking = true


func receive_cannot_attack_again() -> void:
	can_attack_again.emit(false)
				


func receive_attack_finished() -> void:
	_level = 0
	if _intend_to_stop_attacking and attacking:
		attacking_finished.emit()
		stop_attacking()
