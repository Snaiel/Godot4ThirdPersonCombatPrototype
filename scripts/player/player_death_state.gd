class_name PlayerDeathState
extends PlayerStateMachine


func _ready():
	super._ready()
	
	player.health_component.zero_health.connect(
		func():
			if parent_state.current_state != self:
				parent_state.change_state(self)
	)


func enter():
	player.set_root_motion(true)
	
	Globals.lock_on_system.enabled = false
	
	player.weapon.can_damage = false
	player.rotation_component.can_rotate = false
	player.head_rotation_component.enabled = false
	player.hitbox_component.enabled = false
	
	player.character.hit_and_death_animations.death_1()


func process_player():
	pass


#func process_movement_animations():
#	player.character.movement_animations.move(
#		player.input_direction,
#		player.lock_on_target != null, 
#		false
#	)


func exit():
	pass
