class_name InteractionHandler
extends Node


@warning_ignore("unused_signal")
signal interaction


func handle_interaction(_incoming_damage_source: DamageSource) -> bool:
	return true
