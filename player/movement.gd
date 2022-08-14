class_name Movement
extends KinematicBody2D

export (int) var speed = 1200
export (int) var jump_speed = -1800
export (int) var gravity = 4000

export (float, 0, 1.0) var friction = 0.1
export (float, 0, 1.0) var acceleration = 0.25

# inputs
var move_left: bool
var move_right: bool
var jump: bool

# physics
var delta: float
var velocity = Vector2.ZERO

func _physics_process(_delta):
	delta = _delta
	
	get_input()
	gravity()
	walk()
	jump()
	
	velocity = move_and_slide(velocity, Vector2.UP)


func get_input():
	move_left  = Input.is_action_pressed("+left")
	move_right = Input.is_action_pressed("+right")
	jump       = Input.is_action_pressed("+jump")
	if move_left and move_right:
		move_left  = false
		move_right = false


func gravity():
	velocity.y += gravity * delta


func walk():
	var dir = (-1 * int(move_left)) + (1 * int(move_right))
	if dir != 0:
		velocity.x = lerp(velocity.x, dir * speed, acceleration)
	else:
		velocity.x = lerp(velocity.x, 0, friction)


func jump():
	if jump and is_on_floor():
		velocity.y = jump_speed
