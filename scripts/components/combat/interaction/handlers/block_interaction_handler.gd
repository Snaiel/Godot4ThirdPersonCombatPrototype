class_name BlockInteractionHandler
extends InteractionHandler


@export var blackboard: Blackboard
@export var block_component: BlockComponent
@export var health_component: HealthComponent
@export var instability_component: InstabilityComponent
@export var block_sfx: AudioStreamPlayer3D


func handle_interaction(_incoming_damage_source: DamageSource) -> bool:
	interaction.emit()
	
	block_component.blocking = true
	block_component.blocked()
	if block_sfx: block_sfx.play()
	
	instability_component.process_block()
	instability_component.enabled = false
	health_component.enabled = false
	get_tree().create_timer(0.3).timeout.connect(
		func():
			block_component.blocking = false
			instability_component.enabled = true
			health_component.enabled = true
	)
	
	return true
