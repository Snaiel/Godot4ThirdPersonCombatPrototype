class_name BackstabInteractionHandler
extends InteractionHandler


@export var backstab_component: BackstabComponent
@export var health_component: HealthComponent
@export var locomotion_component: LocomotionComponent


func handle_interaction(incoming_weapon: Weapon) -> bool:
	if Globals.backstab_system.backstab_victim != backstab_component:
		return false
	
	interaction.emit()
	
	backstab_component.process_hit()
	health_component.damage_from_weapon(incoming_weapon)
	locomotion_component.knockback(incoming_weapon.entity.global_position)
	
	return true
