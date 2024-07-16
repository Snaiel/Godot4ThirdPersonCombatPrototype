class_name HitInteractionHandler
extends InteractionHandler


@export var blackboard: Blackboard
@export var health_component: HealthComponent
@export var instability_component: InstabilityComponent
@export var locomotion_component: LocomotionComponent
@export var hit_and_death_animations: HitAndDeathAnimations
@export var hit_sfx: AudioStreamPlayer3D


func handle_interaction(incoming_damage_source: DamageSource) -> bool:
	interaction.emit()
	
	blackboard.set_value("got_hit", true)
	health_component.incoming_damage(incoming_damage_source)
	instability_component.increment_instability(
		incoming_damage_source.damage_attributes.hit_instability
	)
	hit_and_death_animations.hit()
	if hit_sfx: hit_sfx.play()
	
	return true
