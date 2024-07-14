extends Label


func _physics_process(_delta: float) -> void:
	text = "FPS: " + str(Performance.get_monitor(Performance.TIME_FPS))
