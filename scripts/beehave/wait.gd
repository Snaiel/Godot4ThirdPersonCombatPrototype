class_name Wait
extends ActionLeaf

@export var time: float
@export var wait_id: int

var _timer: Timer = Timer.new()
var _finished: bool = false
var _waiting: bool = false

func _ready():
	_timer.timeout.connect(_timer_finished)
	_timer.wait_time = time
	_timer.one_shot = true
	add_child(_timer)


## Executes this node and returns a status code.
## This method must be overwritten.
func tick(_actor: Node, blackboard: Blackboard) -> int:
	if blackboard.get_value("interrupt_timers", false):
		return FAILURE
	
	if blackboard.get_value("wait_" + str(wait_id), true):
		_finished = false
		if not _waiting:
			_waiting = true
			_timer.start()
		blackboard.set_value("wait_" + str(wait_id), false)
			
	if _finished:
		return SUCCESS
	else:
		return RUNNING


func _timer_finished() -> void:
	_finished = true
	_waiting = false
