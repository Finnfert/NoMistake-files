extends Node

var Materials := 100.0

func _process(delta: float) -> void:
	if not Input.is_action_pressed("click"):
		Materials += 0.04
	if Materials >= 100:
		Materials = 100
	if Materials <= 0:
		Materials = 0
