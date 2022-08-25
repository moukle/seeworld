extends Node
class_name Movement

# refs
onready var physicalBody: KinematicBody2D = get_node("%Body")
onready var p: Player = get_node("../..")
onready var m: Map = get_node("/root/Scene/Map")


func _physics_process(delta):
	refill_jump()
	gravity()
	walk()
	jump()

func gravity():
	p.velocity.y += m.gravity

func walk():
	var dir = (-1 * int(p.move_left)) + (1 * int(p.move_right))
	if dir != 0:
		p.velocity.x = lerp(p.velocity.x, dir * p.speed, p.acceleration)
	else:
		p.velocity.x = lerp(p.velocity.x, 0, m.friction)

func jump():
	# floor jump
	if p.jump and physicalBody.is_on_floor():
		p.velocity.y = p.jump_speed

	# air jump
	elif p.jump and p.has_double_jump:
		p.has_double_jump = false
		p.velocity.y = p.air_jump_speed

func refill_jump():
	if physicalBody.is_on_floor():
		p.has_double_jump = true
