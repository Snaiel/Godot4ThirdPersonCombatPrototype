class_name HitboxComponent
extends Area3D

signal weapon_hit(weapon: Sword)

var _weapons_in_hitbox: Array[Sword] = []

func _process(_delta):
	if _weapons_in_hitbox:
		for weapon in _weapons_in_hitbox:
			if weapon.can_damage:
				weapon_hit.emit(weapon)
				_weapons_in_hitbox.erase(weapon)

func _on_area_entered(area: Area3D):
	if area.is_in_group("weapon") and area.get_parent() not in _weapons_in_hitbox:
		var weapon: Sword = area.get_parent()
		_weapons_in_hitbox.append(weapon)

func _on_area_exited(area: Area3D):
	if area.is_in_group("weapon"):
		var weapon: Sword = area.get_parent()
		if weapon in _weapons_in_hitbox:
			_weapons_in_hitbox.erase(weapon)
