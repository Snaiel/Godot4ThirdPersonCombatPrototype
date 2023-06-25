class_name HitboxComponent
extends Area3D

signal weapon_hit(damage: int, knockback: float)

var _weapons_in_hitbox = []

func _on_body_entered(body: Node3D):
	if body.is_in_group("weapon") and body not in _weapons_in_hitbox:
		var weapon: Sword = body
		weapon.weapon_impact.connect(_register_hit)
		_weapons_in_hitbox.append(weapon)

func _on_body_exited(body: Node3D):
	if body.is_in_group("weapon"):
		var weapon: Sword = body
		weapon.weapon_impact.disconnect(_register_hit)
		_weapons_in_hitbox.erase(weapon)

func _register_hit(damage: int, knockback: float):
	weapon_hit.emit(damage, knockback)
