class_name Wait
extends ActionLeaf

@export var time: float

var _timer: Timer = Timer.new()
var _finished: bool = false

func _ready():
	_timer.timeout.connect(_timer_finished)
	_timer.wait_time = time
	_timer.one_shot = true
	add_child(_timer)

## Executes this node and returns a status code.
## This method must be overwritten.
func tick(_actor: Node, _blackboard: Blackboard) -> int:
	if _finished:
		return SUCCESS
	else:
		return RUNNING


## Called before the first time it ticks by the parent.
func before_run(_actor: Node, _blackboard: Blackboard) -> void:
	_timer.start()
	

func after_run(_actor: Node, _blackboard: Blackboard) -> void:
	_timer.stop()
	_finished = false
	

func _timer_finished():
	_finished = true
