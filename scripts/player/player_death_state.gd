class_name PlayerDeathState
extends PlayerStateMachine


@export var dizzy_hit_sfx: AudioStreamPlayer3D


func _ready():
	super._ready()
	
	player.health_component.zero_health.connect(
		func():
			if parent_state.current_state == self: return
			parent_state.change_state(self)
	)
	
	Globals.user_interface.death_screen.respawn.connect(
		func():
			if parent_state.current_state != self: return
			player.character.hit_and_death_animations.reset_death()
			player.character.sit_animations.blend_to_idle()
	)
	
	Globals.user_interface.death_screen.stand_up.connect(
		func():
			if parent_state.current_state != self: return
			player.character.sit_animations.stand_up()
	)
	
	player.character.sit_animations.finished.connect(
		func():
			if parent_state.current_state != self: return
			parent_state.transition_to_default_state()
	)


func enter() -> void:
	player.locomotion_component.set_active_strategy("root_motion")
	
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
	
	Globals.music_system.fade_out()
	
	if player.instability_component.is_full_instability():
		Globals.user_interface.hud.instability_bar.play_max_instability()
		dizzy_hit_sfx.play()


func process_player() -> void:
	pass


func process_movement_animations() -> void:
	player.character.idle_animations.active = player.lock_on_target != null
	player.character.movement_animations.dir = Vector3.ZERO


func exit() -> void:
	player.locomotion_component.set_active_strategy("programmatic")
	
	Globals.lock_on_system.enabled = true
	
	player.rotation_component.can_rotate = true
	player.head_rotation_component.enabled = true
	player.hitbox_component.enabled = true
	
	if Globals.checkpoint_system.current_checkpoint:
		Globals.checkpoint_system.enable_hint()
