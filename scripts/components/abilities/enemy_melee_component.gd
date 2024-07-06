class_name EnemyMeleeComponent
extends MeleeComponent


@export var entity: Enemy
@export var blackboard: Blackboard
@export var instability_component: InstabilityComponent
@export var outcomes_handler: OutcomesInteractionHandler


func _ready():
	super()
	entity.dead.connect(set_can_damage_of_all_weapons.bind(false))
	instability_component.full_instability.connect(interrupt_attack)
	outcomes_handler.interaction.connect(interrupt_attack)


func _process(_delta: float) -> void:
	if blackboard.get_value("can_attack", false) and \
	blackboard.get_value("attack", false):
		blackboard.set_value("can_attack", false)
		blackboard.set_value("attack", false)
		attack(blackboard.get_value("attack_level", 0))
	blackboard.set_value("attacking", attacking)
