extends Node2D

var load_ = [load("res://eraser.tscn"),load("res://armoreraser.tscn"),load("res://lighteraser.tscn")]
# Called when the node enters the scene tree for the first time.
func _ready() -> void:
	pass

# Called every frame. 'delta' is the elapsed time since the previous frame.
func _process(delta: float) -> void:
	$Timer.wait_time = randf_range(0.1,3)

func spawnE():
	var etype = randi_range(0,2)
	var l = load_[etype].instantiate()
	randomize()
	var r = randi_range(1,$Line2D.get_point_count())
	l.position = $Line2D.get_point_position(r-1)
	l.target = get_parent().get_node("House")
	add_child(l)


func _on_timer_timeout() -> void:
	spawnE()
