@tool

class_name Wait
extends ActionLeaf

@export var time: float
@export var reset_wait_after: bool = false
@export var wait_id: int
@export var generate_wait_id: bool

var _timer: Timer = Timer.new()
var _finished: bool = false
var _waiting: bool = false


func _ready():
	if not Engine.is_editor_hint():
		_timer.timeout.connect(
			func():
				_finished = true
		)
		_timer.wait_time = time
		_timer.one_shot = true
		add_child(_timer)


func _process(_delta):
	if Engine.is_editor_hint() and generate_wait_id:
		generate_wait_id = false
		var rng = RandomNumberGenerator.new()
		wait_id = rng.randi_range(10000000, 99999999)


## Executes this node and returns a status code.
## This method must be overwritten.
func tick(_actor: Node, blackboard: Blackboard) -> int:
	# fail if interrupt_timers in blackboard is true
	if blackboard.get_value("interrupt_timers", false):
		_waiting = false
		return FAILURE
	
	if blackboard.get_value("wait_" + str(wait_id), true):
		# id in blackboard is true. this means start waiting.
		_finished = false
		if not _waiting:
			_waiting = true
			_timer.start()
		blackboard.set_value("wait_" + str(wait_id), false)
	elif not _waiting:
		# success if id is false and no waiting.
		# just a failsafe if the _finished flag doesn't work.
		return SUCCESS
	
	if _finished:
		# timer finished
		blackboard.set_value("wait_" + str(wait_id), reset_wait_after)
		_waiting = false
		return SUCCESS
	
	return RUNNING
