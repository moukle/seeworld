extends Node2D
class_name Hook

# refs
onready var pb: KinematicBody2D = get_node("%Body")
onready var p: Player = get_node("../..")

var hooking: bool = false
var shooting: bool = false
var connected: bool = false
var retract_hook: bool = false


var target_pos: Vector2
var target_node: Node


var dir: Vector2

onready var ray_cast: RayCast2D

# clean up vars
var remove_anchor: bool = false
var remove_joint: bool = false
var remove_head: bool = false

func _physics_process(delta):
	if p.hook and (not hooking or shooting):
		shoot_hook()
	elif not p.hook and hooking:
		unhook()
	elif connected:
		if not target_node.is_in_group("TileMap"):
			target_pos = target_node.position
		
		# pull_by_interpolation()
		# pull_by_joint()
		pull_by_tw()

func _process(delta):
	update()


func _draw():
	if connected:
		draw_hook()


func shoot_hook():
	# init
	if not shooting:
		dir = p.mouse_direction
		shooting = true
		hooking = true
		retract_hook = false
		
		ray_cast = RayCast2D.new()
		ray_cast.enabled = true
		ray_cast.cast_to = dir * 1.5 * p.physical_size;
		add_child(ray_cast)
	elif not retract_hook:
		var new_target = ray_cast.cast_to + dir * p.hook_fire_speed
		if new_target.length() > p.hook_length:
			new_target = dir * p.hook_length
			retract_hook = true
		ray_cast.cast_to = new_target
	"""
	elif retract_hook:
		var new_target = ray_cast.cast_to - dir * p.hook_fire_speed
		shooting = false
		hooking = false
		ray_cast.enabled = false
	"""
	"""
	if((!m_NewHook && distance(m_Pos, NewPos) > m_Tuning.m_HookLength) || (m_NewHook && distance(m_HookTeleBase, NewPos) > m_Tuning.m_HookLength))
	{
		m_HookState = HOOK_RETRACT_START;
		NewPos = m_Pos + normalize(NewPos - m_Pos) * m_Tuning.m_HookLength;
		m_Reset = true;
	}
	"""
		
	ray_cast.position = pb.position
	
	# found target
	if ray_cast.is_colliding():
		target_pos = ray_cast.get_collision_point()
		target_node = ray_cast.get_collider()
		shooting = false
		connected = true
		ray_cast.enabled = false


func unhook():
	#remove_childs()
	remove_child(ray_cast)
	hooking = false
	shooting = false
	connected = false


func pull_by_tw():
	var hook_drag_accel = 300
	var hook_drag_speed = 1500
	var pull_dir = (target_pos - pb.position).normalized()
	var pull_angle = pull_dir.angle()
	
	var hook_vel = pull_dir * hook_drag_accel;
	# the hook has more power to drag you up than down.
	# this makes it easier to get on top of a platform
	if(hook_vel.y > 0):
		hook_vel.y = hook_vel.y * 0.3

	# the hook will boost it's power if the player wants to move
	# in that direction. otherwise it will dampen everything abit
	if((hook_vel.x < 0 && pull_angle < 0) || (hook_vel.x > 0 && pull_angle > 0)):
		hook_vel.x *= 0.95;
	else:
		hook_vel.x *= 0.75;

	var new_vel = p.velocity + hook_vel;

	# check if we are under the legal limit for the hook
	if(new_vel.length() < hook_drag_speed or new_vel.length() < p.velocity.length()):
		p.velocity = new_vel # no problem. apply
	
		
	# handle hook influence
	"""
	if(!m_HookHitDisabled && m_HookedPlayer == i && m_Tuning.m_PlayerHooking):
		if(Distance > PhysicalSize() * 1.50f) # TODO: fix tweakable variable
		{
			float HookAccel = m_Tuning.m_HookDragAccel * (Distance / m_Tuning.m_HookLength);
			float DragSpeed = m_Tuning.m_HookDragSpeed;

			vec2 Temp;
			# add force to the hooked player
			Temp.x = SaturatedAdd(-DragSpeed, DragSpeed, pCharCore->m_Vel.x, HookAccel * Dir.x * 1.5f);
			Temp.y = SaturatedAdd(-DragSpeed, DragSpeed, pCharCore->m_Vel.y, HookAccel * Dir.y * 1.5f);
			pCharCore->m_Vel = ClampVel(pCharCore->m_MoveRestrictions, Temp);
			# add a little bit force to the guy who has the grip
			Temp.x = SaturatedAdd(-DragSpeed, DragSpeed, m_Vel.x, -HookAccel * Dir.x * 0.25f);
			Temp.y = SaturatedAdd(-DragSpeed, DragSpeed, m_Vel.y, -HookAccel * Dir.y * 0.25f);
			m_Vel = ClampVel(m_MoveRestrictions, Temp);
		}
	}
	"""

func draw_hook() -> void:
	draw_line(pb.position, target_pos, Color(0.5, 0.5, 0.5), 5)
