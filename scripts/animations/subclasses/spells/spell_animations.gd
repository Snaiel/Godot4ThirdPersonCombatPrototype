class_name SpellAnimations
extends BaseAnimations


signal can_rotate(flag: bool)
signal secondary_movement(spell: SpellStrategy)
signal release_spell
signal end_spell
signal can_cast_again(flag: bool)
signal can_play_animation
signal animation_finished

var spells: Array[SpellStrategy]

# this means if an active animation is currently occurring
var active: bool = false

# which spell to do, meant to control animations
# for successive spells
var _level: int = 1

# this means that there is an intent to cast a spell
var _intent_to_cast: bool = false

# this means that the spell animation can play.
# meant to control when the next cast anim plays
# when doing successive spells
var _can_play_animation: bool = false

# will be checked to decide whether to stop
# the active animation
var _intend_to_stop_casting: bool = true


func _ready() -> void:
	anim_tree.set(&"parameters/Spells/blend_amount", 0.0)
	
	for child in get_children():
		spells.append(child)


func _physics_process(_delta: float) -> void:
	if debug:
		pass
	
	if _can_play_animation and _intent_to_cast:
		
		spells[_level].play_attack()
		
		_can_play_animation = false
		_intent_to_cast = false
	
	var blend = anim_tree.get(&"parameters/Spells/blend_amount")
	if blend == null: return
	anim_tree.set(
		&"parameters/Spells/blend_amount",
		lerp(
			float(blend), 
			1.0 if active else 0.0,
			0.15
		)
	)


func cast_spell(level: int, manually_set_level: bool = false) -> void:
	active = true
	_intent_to_cast = true
	_intend_to_stop_casting = false
	if level == 1 or manually_set_level:
		_can_play_animation = true
	_level = level


func stop_attacking() -> void:
	_can_play_animation = true
	can_rotate.emit(true)
	active = false


func receive_prevent_rotation() -> void:
	can_rotate.emit(false)


func receive_secondary_movement() -> void:
	if not spells[_level].secondary_movement:
		return
	
	secondary_movement.emit(spells[_level])


func receive_release_spell() -> void:
	release_spell.emit()


func receive_end_spell() -> void:
	end_spell.emit()


func receive_can_cast_again() -> void:
	can_cast_again.emit(true)
	_intend_to_stop_casting = true


func receive_cannot_cast_again() -> void:
	can_cast_again.emit(false)


func recieve_can_play_animation() -> void:
	can_play_animation.emit()
	_can_play_animation = true


func receive_finished() -> void:
	_level = 0
	if _intend_to_stop_casting and active:
		animation_finished.emit()
		stop_attacking()
