class_name EnemyAttackComponent
extends AttackComponent


@export var blackboard: Blackboard


func _process(_delta: float) -> void:
	if blackboard.get_value("can_attack", false) and blackboard.get_value("attack", false):
		blackboard.set_value("can_attack", false)
		blackboard.set_value("attack", false)
		attack_level = blackboard.get_value("attack_level", 0)
		attack()
	blackboard.set_value("attacking", attacking)


func set_can_damage_of_all_weapons(flag: bool) -> void:
	super(flag)
