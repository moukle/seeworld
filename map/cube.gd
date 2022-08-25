extends KinematicBody2D
class_name Cube

onready var m: Map = get_node("/root/Scene/Map")

var velocity: Vector2

func _process(delta):
	gravity(delta)
	velocity = move_and_slide(velocity, Vector2.UP)

func gravity(delta):
	velocity.y += m.gravity
