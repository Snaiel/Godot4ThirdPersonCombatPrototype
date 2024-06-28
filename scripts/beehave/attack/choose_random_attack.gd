class_name ChooseRandomAttackLeaf
extends ActionLeaf


var weights: Array[float]

var _cumulative_weights: Array[float]
var _total_weight: float


func _ready() -> void:
	_cumulative_weights.append(weights[0])
	for i in range(1, len(weights)):
		_cumulative_weights.append(_cumulative_weights[i - 1] + weights[i])
	_total_weight = weights.reduce(func(accum, number): return accum + number)


func tick(_actor: Node, blackboard: Blackboard) -> int:
	var rng: float = RandomNumberGenerator.new().randf() * _total_weight
	var which_attack: int = 0
	
	for i in range(len(_cumulative_weights)):
		if rng <= _cumulative_weights[i]:
			which_attack = i
			break
	
	blackboard.set_value("attack_level", which_attack)
	return SUCCESS
