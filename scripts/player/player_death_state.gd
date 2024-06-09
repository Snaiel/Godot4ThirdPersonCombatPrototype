class_name PlayerDeathState
extends PlayerStateMachine


func _ready():
	super._ready()
	
	player.health_component.zero_health.connect(
		func():
			if parent_state.current_state != self:
				parent_state.change_state(self)
	)
	
	Globals.user_interface.death_screen.respawn.connect(
		func():
			if parent_state.current_state != self:
				return
			
			player.character.hit_and_death_animations.reset_death()
			player.character.sitting_animations.blend_to_idle()
	)
	
	Globals.user_interface.death_screen.stand_up.connect(
		func():
			if parent_state.current_state != self:
				return
			
			player.character.sitting_animations.stand_up()
	)
	
	player.character.sitting_animations.finished.connect(
		func():
			if parent_state.current_state != self:
				return
			
			parent_state.transition_to_default_state()
	)


func enter():
	player.set_root_motion(true)
	
	Globals.lock_on_system.reset_target()
	Globals.lock_on_system.enabled = false
	
	player.weapon.can_damage = false
	player.rotation_component.can_rotate = false
	player.head_rotation_component.enabled = false
	player.hitbox_component.enabled = false
	
	player.character.hit_and_death_animations.death_1()
	
	Globals.user_interface.death_screen.play_death_screen()
	
	player.set_rotation_target_to_lock_on_target()
	player.rotation_component.rotate_towards_target = false
	
	Globals.player._aggro_enemy_counter = 0
	Globals.music_system.fade_out()


func process_player():
	pass


func process_movement_animations():
	player.character.movement_animations.move(
		Vector3.ZERO,
		player.lock_on_target != null, 
		false
	)


func exit():
	player.set_root_motion(false)
	
	Globals.lock_on_system.enabled = true
	
	player.rotation_component.can_rotate = true
	player.head_rotation_component.enabled = true
	player.hitbox_component.enabled = true
