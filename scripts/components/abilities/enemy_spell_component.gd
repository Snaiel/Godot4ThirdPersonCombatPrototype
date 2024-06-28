class_name EnemySpellComponent
extends SpellComponent


@export var blackboard: Blackboard


func _process(_delta: float) -> void:
	if blackboard.get_value("can_cast_spell", false) and blackboard.get_value("cast_spell", false):
		blackboard.set_value("can_cast_spell", false)
		blackboard.set_value("cast_spell", false)
		spell_index = blackboard.get_value("spell_index", 0)
		cast_spell()
	blackboard.set_value("executing_spelll", executing)
