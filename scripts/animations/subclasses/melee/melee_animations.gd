class_name MeleeAnimations
extends BaseAnimations


signal secondary_movement(attack: MeleeAttack)
signal can_damage(flag: bool, weapon_names: Array[StringName])
signal can_rotate(flag: bool)
signal can_attack_again(flag: bool)
signal can_play_animation
signal attacking_finished


var attacks: Array[MeleeAttack]

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
var _can_play_animation: bool = true

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
	anim_tree.set(&"parameters/Melee/blend_amount", 0.0)
	
	for child in get_children():
		attacks.append(child)


func _physics_process(_delta: float) -> void:
	if debug:
		pass
	
	if _transition_legs  == 1:
		attacks[_level].perform_legs_transition()
	elif _transition_legs == -1:
		attacks[_level].end_legs_transition()
	
	if _can_play_animation and _intent_to_attack:
		_transition_legs = 0
		attacks[_level].play_attack()
		_can_play_animation = false
		_intent_to_attack = false
	
	var blend = anim_tree.get(&"parameters/Melee/blend_amount")
	if blend == null: return
	anim_tree.set(
		&"parameters/Melee/blend_amount",
		lerp(
			float(blend), 
			1.0 if attacking else 0.0, 
			0.15
		)
	)


func attack(level: int, override_can_play: bool = false) -> void:
	attacking = true
	_intent_to_attack = true
	_intend_to_stop_attacking = false
	if override_can_play:
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


func receive_play_legs() -> void:
	_transition_legs = 1
	attacks[_level].play_legs()


func receive_stop_legs(which_attack: StringName) -> void:
	# having a check for the level originating from the animation
	# against the current attack _level to see whether
	# to actually transition out of the current animation's legs
	if which_attack == attacks[_level].attack_name:
		_transition_legs = -1


func receive_can_damage(weapon_names: Array = []) -> void:
	var typed_weapon_names: Array[StringName] = []
	typed_weapon_names.assign(weapon_names)
	can_damage.emit(true, typed_weapon_names)


func receive_cannot_damage(weapon_names: Array = []) -> void:
	var typed_weapon_names: Array[StringName] = []
	typed_weapon_names.assign(weapon_names)
	can_damage.emit(false, typed_weapon_names)


func receive_can_attack_again() -> void:
	can_attack_again.emit(true)
	_intend_to_stop_attacking = true


func receive_cannot_attack_again() -> void:
	can_attack_again.emit(false)


func receive_can_play_animation() -> void:
	can_play_animation.emit()
	_can_play_animation = true


func receive_attack_finished() -> void:
	_level = 0
	if _intend_to_stop_attacking and attacking:
		attacking_finished.emit()
		stop_attacking()
