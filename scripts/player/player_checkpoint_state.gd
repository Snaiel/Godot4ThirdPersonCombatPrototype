class_name PlayerCheckpointState
extends PlayerStateMachine


var _exiting: bool = false

@onready var user_interface: UserInterface = Globals.user_interface
@onready var camera_controller: CameraController = Globals.camera_controller
@onready var lock_on_system: LockOnSystem = Globals.lock_on_system
@onready var checkpoint_system: CheckpointSystem = Globals.checkpoint_system


func _ready():
	super._ready()
	
	player.character.sitting_animations.sat_down.connect(
		func():
			if parent_state.current_state == self:
				user_interface.checkpoint_interface.show_menu()
	)
	
	player.character.sitting_animations.finished.connect(
		func():
			if parent_state.current_state == self:
				parent_state.transition_to_default_state()
	)
	
	user_interface.checkpoint_interface.exit_checkpoint.connect(
		_stand_up
	)


func enter():
	_exiting = false
	
	player.character.sitting_animations.sit_down()
	player.set_root_motion(true)
	player.hitbox_component.enabled = false
	player.rotation_component.target = checkpoint_system.current_checkpoint
	
	player.rotation_component.rotate_towards_target = true
	Globals.lock_on_system.reset_target()
	
	
	checkpoint_system.disable_hint()
	checkpoint_system.save_current_checkpoint()
	
	user_interface.hud.enabled = false


func process_player():
	pass

func process_movement_animations() -> void:
	player.character.movement_animations.move(
		Vector3.ZERO,
		player.lock_on_target != null, 
		false
	)


func exit():
	player.set_root_motion(false)
	player.rotation_component.can_rotate = true
	player.hitbox_component.enabled = true
	
	checkpoint_system.enable_hint()
	
	user_interface.hud.enabled = true
	user_interface.checkpoint_interface.visible = false
	
	player.rotation_component.rotate_towards_target = false
	player.rotation_component.target = null
	


func _stand_up() -> void:
	player.character.sitting_animations.stand_up()
	
	user_interface.checkpoint_interface.hide_menu()
	
	Input.mouse_mode = Input.MOUSE_MODE_CAPTURED
	_exiting = true
