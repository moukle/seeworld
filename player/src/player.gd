extends Node2D
class_name Player

onready var physicalBody: KinematicBody2D = get_node("%Body")

# exports
export (int) var speed = 1200
export (int) var jump_speed = -1800
export (int) var gravity = 4000
export (float, 0, 1.0) var friction = 0.1
export (float, 0, 1.0) var acceleration = 0.25

export (int) var           hook_length = 380*2
export (int) var           hook_impulse = 2000
export (int) var           hook_fire_speed = 80
export (float, 0, 1.0) var hook_fire_acceleration = 0.3
export (float, 0, 1.0) var hook_acceleration = 0.5


# inputs
var move_left: bool
var move_right: bool
var jump: bool
var hook: bool
var mouse_direction: Vector2

# state
var velocity = Vector2.ZERO
const physical_size: int = 50

func _process(delta):
	set_position(physicalBody.position)


func _physics_process(delta):
	get_input()
	velocity = physicalBody.move_and_slide(velocity, Vector2.UP)


func get_input():
	# keyboard
	move_left  = Input.is_action_pressed("+left")
	move_right = Input.is_action_pressed("+right")
	jump       = Input.is_action_pressed("+jump")
	if move_left and move_right:
		move_left  = false
		move_right = false

	# mouse
	hook            = Input.is_action_pressed("+hook")
	mouse_direction = get_local_mouse_position().normalized()
