extends Node2D
class_name Player

const cell_size: int = 128  # projectSetting: phys/2d/cell_size
const tile_size: int = 64  # projectSetting: phys/2d/cell_size
const physical_size: int = 50

onready var physicalBody: KinematicBody2D = get_node("%Body")

# exports
export (int) var speed = 10 * cell_size
export (int) var jump_speed = -13 * cell_size
export (int) var air_jump_speed = -12 * cell_size
export (float, 0, 1.0) var acceleration = 0.25

export (int) var           hook_length = 12 * tile_size
export (int) var           hook_fire_speed = 80*2
export (int) var           hook_drag_speed = 15*2
export (float, 0, 1.0) var hook_drag_acceleration = 1.0

# inputs
var move_left: bool
var move_right: bool
var jump: bool
var hook: bool
var mouse_direction: Vector2

# state
var velocity = Vector2.ZERO
var has_double_jump: bool = true


func _process(delta):
	set_position(physicalBody.position)


func _physics_process(delta):
	get_input()
	velocity = physicalBody.move_and_slide(velocity, Vector2.UP)


func get_input():
	# keyboard
	move_left  = Input.is_action_pressed("+left")
	move_right = Input.is_action_pressed("+right")
	jump       = Input.is_action_just_pressed("+jump")
	if move_left and move_right:
		move_left  = false
		move_right = false

	# mouse
	hook            = Input.is_action_pressed("+hook")
	mouse_direction = get_local_mouse_position().normalized()
