class_name BackstabInteractionHandler
extends InteractionHandler


@export var backstab_component: BackstabComponent
@export var health_component: HealthComponent
@export var locomotion_component: LocomotionComponent


func handle_interaction(incoming_damage_source: DamageSource) -> bool:
	if Globals.backstab_system.backstab_victim != backstab_component:
		return false
	
	interaction.emit()
	
	backstab_component.process_hit()
	health_component.incoming_damage(incoming_damage_source)
	locomotion_component.knockback(
		incoming_damage_source.damage_attributes.knockback,
		incoming_damage_source.entity.global_position
	)
	
	return true
