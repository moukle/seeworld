extends Node
class_name Movement

# refs
onready var physicalBody: KinematicBody2D = get_node("%Body")
onready var p: Player = get_node("../..")

func _physics_process(delta):
	gravity(delta)
	walk()
	jump()


func gravity(delta):
	p.velocity.y += p.gravity * delta


func walk():
	var dir = (-1 * int(p.move_left)) + (1 * int(p.move_right))
	if dir != 0:
		p.velocity.x = lerp(p.velocity.x, dir * p.speed, p.acceleration)
	else:
		p.velocity.x = lerp(p.velocity.x, 0, p.friction)


func jump():
	if p.jump and physicalBody.is_on_floor():
		p.velocity.y = p.jump_speed
