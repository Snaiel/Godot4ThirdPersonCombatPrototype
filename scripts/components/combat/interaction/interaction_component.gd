class_name InteractionComponent
extends Node


@export var hitbox_component: HitboxComponent


func _ready() -> void:
	hitbox_component.weapon_hit.connect(_handle_incoming_weapon)


func _handle_incoming_weapon(incoming_weapon: Weapon) -> void:
	for child in get_children():
		var handler: InteractionHandler = child
		if handler.handle_interaction(incoming_weapon):
			return
