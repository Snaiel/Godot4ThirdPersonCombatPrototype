class_name PlayerMovementState
extends PlayerStateMachine


@export var walk_state: PlayerWalkState
@export var run_state: PlayerRunState
@export var dodge_state: PlayerDodgeState

var holding_down_run: bool = false
var _holding_down_run_timer: Timer


func _ready():
	super._ready()
	
	_holding_down_run_timer = Timer.new()
	_holding_down_run_timer.timeout.connect(
		func():
			holding_down_run = true
	)
	add_child(_holding_down_run_timer)


func process_player() -> void:
	prints(current_state, previous_state, player.movement_component.speed)
	
	player.rotation_component.target = player.lock_on_target
	
	var _animation_input_dir: Vector3 = player.input_direction
	if player.locked_on_turning_in_place or \
	(
		player.dodge_component.dodging and \
		player.input_direction.length() < 0.1
	):
		_animation_input_dir = Vector3.FORWARD
	
	player.character.movement_animations.move(
		_animation_input_dir, 
		player.lock_on_target != null, 
		current_state is PlayerRunState
	)
	
	# make sure the user is actually holding down
	# the run key to make the player run
	if Input.is_action_just_pressed("run"):
		if player.dodge_component.can_set_intent_to_dodge and \
		not player.attack_component.attacking:
			player.dodge_component.intent_to_dodge = true
		_holding_down_run_timer.start(0.1)
	if Input.is_action_just_released("run"):
		_holding_down_run_timer.stop()
		holding_down_run = false
