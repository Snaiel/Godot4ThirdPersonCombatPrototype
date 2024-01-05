class_name LeafExecuteExpression
extends Leaf

@export var enabled: bool = true
@export_placeholder(EXPRESSION_PLACEHOLDER) var expression_string: String = ""

@onready var _expression: Expression = _parse_expression(expression_string)


func tick(_actor: Node, blackboard: Blackboard) -> int:
	if not enabled:
		return FAILURE
	
	_expression.execute([], blackboard)
	
	if _expression.has_execute_failed():
		return FAILURE
	
	return SUCCESS
