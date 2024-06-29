class_name SimpleSpellStrategy
extends SpellStrategy


@export var spell_name: String
@export var has_copy: bool = false

@export_category("Animation Settings")
@export var trim: float = 0.0
@export var animation_speed: float = 1.0


func play_attack():
	if not has_copy:
		_play_attack()
		return
	
	if _play_copy:
		anim_tree.set(
			"parameters/%s Copy/%s Trim/seek_request" % [spell_name, spell_name],
			trim
		)
		anim_tree.set(
			"parameters/%s Copy/%s Speed/scale" % [spell_name, spell_name],
			animation_speed
		)
		anim_tree.set(
			"parameters/Spell/transition_request",
			spell_name.to_snake_case() + "_copy"
		)
		_play_copy = false
	else:
		_play_attack()
		_play_copy = true


func _play_attack():
	anim_tree.set(
		"parameters/%s/%s Trim/seek_request" % [spell_name, spell_name],
		trim
	)
	anim_tree.set(
		"parameters/%s/%s Speed/scale" % [spell_name, spell_name],
		animation_speed
	)
	anim_tree.set(
		"parameters/Spell/transition_request",
		spell_name.to_snake_case()
	)
