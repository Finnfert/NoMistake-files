extends CharacterBody2D

func _physics_process(delta: float) -> void:
	position = get_global_mouse_position()
	
	if $Area2D.has_overlapping_bodies() == true:
		get_parent().finish_drawing()
