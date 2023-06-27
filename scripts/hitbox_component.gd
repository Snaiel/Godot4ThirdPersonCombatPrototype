class_name HitboxComponent
extends Area3D

signal weapon_hit(weapn: Sword)

var _weapons_in_hitbox: Array[Sword] = []

func _process(_delta):
	if _weapons_in_hitbox:
		for weapon in _weapons_in_hitbox:
			if weapon.can_impact:
				weapon_hit.emit(weapon)
				_weapons_in_hitbox.erase(weapon)

func _on_body_entered(body: Node3D):
	if body.is_in_group("weapon") and body not in _weapons_in_hitbox:
		var weapon: Sword = body
		_weapons_in_hitbox.append(weapon)

func _on_body_exited(body: Node3D):
	if body.is_in_group("weapon"):
		var weapon: Sword = body
		if weapon in _weapons_in_hitbox:
			_weapons_in_hitbox.erase(weapon)
