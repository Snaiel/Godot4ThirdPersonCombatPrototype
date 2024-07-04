class_name InteractionComponent
extends Node


@export var hitbox_component: HitboxComponent


func _ready() -> void:
	hitbox_component.damage_source_hit.connect(_handle_incoming_damage_source)


func _handle_incoming_damage_source(incoming_damage_source: DamageSource) -> void:
	for child in get_children():
		var handler: InteractionHandler = child
		if handler.handle_interaction(incoming_damage_source):
			return
