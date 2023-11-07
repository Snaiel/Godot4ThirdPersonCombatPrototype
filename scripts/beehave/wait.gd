class_name Wait
extends ActionLeaf

@export var time: float

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
	if blackboard.get_value("wait_before_chase", true):
		_finished = false
		blackboard.set_value("wait_before_chase", false)
		
	if not _waiting:
		_waiting = true
		_timer.start()
			
	if _finished:
		return SUCCESS
	else:
		return RUNNING


func _timer_finished() -> void:
	_finished = true
	_waiting = false
