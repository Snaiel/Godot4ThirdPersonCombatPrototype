class_name PlayerMovementState
extends PlayerStateMachine


@export var walk_state: PlayerWalkState
@export var run_state: PlayerRunState

var _holding_down_run: bool = false
var _holding_down_run_timer: Timer


func _ready():
	super._ready()
	
	_holding_down_run_timer = Timer.new()
	_holding_down_run_timer.timeout.connect(
		func():
			_holding_down_run = true
	)
	add_child(_holding_down_run_timer)


func process_player() -> void:
	print(current_state)
	
	# make sure the user is actually holding down
	# the run key to make the player run
	if Input.is_action_just_pressed("run"):
#		if dodge_component.can_set_intent_to_dodge and not attack_component.attacking:
#			dodge_component.intent_to_dodge = true
		_holding_down_run_timer.start(0.1)
	if Input.is_action_just_released("run"):
		_holding_down_run_timer.stop()
		_holding_down_run = false
	
	if _holding_down_run and current_state != run_state:
		change_state(run_state)
	elif not _holding_down_run and current_state != walk_state:
		change_state(walk_state)
	
	player.character.movement_animations.move(
		player.input_direction, 
		player.lock_on_target != null, 
		current_state is PlayerRunState
	)
