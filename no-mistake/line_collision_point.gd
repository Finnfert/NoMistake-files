extends Area2D
var health = 10
var point_ID = 0
# Called when the node enters the scene tree for the first time.
func _ready() -> void:
	pass # Replace with function body.


# Called every frame. 'delta' is the elapsed time since the previous frame.
func _process(delta: float) -> void:
	if has_overlapping_areas():
		for area in get_overlapping_areas():
			health -= area.get_parent().damage
			if health <=0:
				area.get_parent().health -= 1
	if health <= 0:
		kill()




func kill():
	get_parent().split_line_at_gap(point_ID, 30.0)
	queue_free()
