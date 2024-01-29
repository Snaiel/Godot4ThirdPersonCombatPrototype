class_name VoidDeathSystem
extends Area3D


func _ready():
	body_entered.connect(
		func(body: Node3D):
			prints("Fallen in to the void:", body)
	)
