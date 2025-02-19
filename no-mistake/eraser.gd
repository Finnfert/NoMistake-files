extends CharacterBody2D
@export var damage = 0.1
@export var target = Node
@export var speed = 50
@export var speedanimmod = 0.0
@export var health = 3

func _physics_process(delta: float) -> void:
	look_at(target.position)
	velocity = Vector2(speed * speedanimmod * delta, 0).rotated(rotation)
	rotation = 0 
	move_and_collide(velocity)
	
	if health <= 0:
		queue_free()
	
	if speed == 50:
		var animnames = ["Smallest", "Half", "Full"]
		if health <= 0:
			queue_free()
		$AnimatedSprite2D.play(animnames[health - 1])
