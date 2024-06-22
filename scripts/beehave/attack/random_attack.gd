class_name RandomAttackComposite
extends SequenceComposite


@export var weights: Array[float]
@export var attack_chooser: ChooseRandomAttackLeaf


func _enter_tree():
	attack_chooser.weights = weights
