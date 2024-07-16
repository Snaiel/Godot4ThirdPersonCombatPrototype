class_name DizzyInteractionHandler
extends InteractionHandler


@export var dizzy_component: DizzyComponent
@export var health_component: HealthComponent
@export var instability_component: InstabilityComponent
@export var locomotion_component: LocomotionComponent


func handle_interaction(incoming_damage_source: DamageSource) -> bool:
	if Globals.dizzy_system.dizzy_victim != dizzy_component:
		return false
	
	interaction.emit()
	
	dizzy_component.process_hit(incoming_damage_source)
	health_component.incoming_damage(incoming_damage_source)
	if instability_component.full_instability_from_parry:
		locomotion_component.knockback(
			incoming_damage_source.damage_attributes.knockback,
			incoming_damage_source.entity.global_position
		)
	
	return true
