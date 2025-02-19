extends Node2D
var animnames = ["Worst","Mid","Good"]
@export_range(1,3) var Base_Level = 1
@export_range(1,3) var Head_Level = 1
var target := CharacterBody2D
var has_targ = false
var cananball = load("res://canon_ball.tscn")
var r := 0 
var targets := []
# Called when the node enters the scene tree for the first time.
func _ready() -> void:
	$Base/BaseStates.play(animnames[Base_Level - 1])
	$"Head/Canon States".play(animnames[Head_Level - 1])


# Called every frame. 'delta' is the elapsed time since the previous frame.
func _process(delta: float) -> void:
	$"Radius of sight/CollisionShape2D".shape.radius = 50 * Head_Level
	if $Timer.time_left <= 0:
		find_target()
	if not $"Radius of sight".has_overlapping_bodies():
		has_targ = false
	if target == null:
		find_target()
	if has_targ:
		if not target == null:
			$Head.look_at(target.position)
			$Head.rotation +=45

func find_target():
	targets.clear()
	$"Radius of sight/CollisionShape2D".shape.radius = int(50 * Head_Level)
	var area = $"Radius of sight"
	
	if $"Radius of sight".has_overlapping_bodies():
		for body in $"Radius of sight".get_overlapping_bodies():
			if body.is_in_group("Eraser"):
				has_targ = true
				targets.insert(0,body)
				randomize()
				r = randi_range(0,targets.size() - 1)
				target = targets[r]
			else:
				has_targ = false
	else:
		has_targ = false



func _on_radius_of_sight_body_entered(body: Node2D) -> void:
	find_target()


func _on_firerate_timeout() -> void:
	if has_targ:
		shoot()

func shoot():
	var l = cananball.instantiate()
	l.direction = Vector2.RIGHT.rotated($Head.global_rotation - 45)
	l.position = position
	add_child(l)
