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
			user_interface.checkpoint_interface.show_menu = true
			Input.mouse_mode = Input.MOUSE_MODE_VISIBLE
	)
	
	player.character.sitting_animations.finished.connect(
		func():
			parent_state.transition_to_default_state()
	)
	
	user_interface.checkpoint_interface.return_button.pressed.connect(
		_stand_up
	)


func enter():
	_exiting = false
	
	player.rotation_component.can_rotate = false
	player.character.sitting_animations.sit_down()
	player.set_root_motion(true)
	player.hitbox_component.enabled = false
	
	checkpoint_system.disable_hint()
	checkpoint_system.sat_at_checkpoint()
	
	user_interface.hud.enabled = false
	
	user_interface.checkpoint_interface.visible = true
	user_interface.checkpoint_interface.recover_button.grab_focus()
	
	camera_controller.enabled = false
	lock_on_system.enabled = false


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
	
	camera_controller.enabled = true
	lock_on_system.enabled = true


func _stand_up() -> void:
	player.character.sitting_animations.stand_up()
	
	user_interface.checkpoint_interface.show_menu = false
	
	Input.mouse_mode = Input.MOUSE_MODE_CAPTURED
	_exiting = true
