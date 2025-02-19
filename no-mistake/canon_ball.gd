extends CharacterBody2D

var direction := Vector2(0,0)

# Called every frame. 'delta' is the elapsed time since the previous frame.
func _process(delta: float) -> void:
	velocity = direction * 500
	
	move_and_slide()


func _on_area_2d_body_entered(body: Node2D) -> void:
	body.health -= 2
