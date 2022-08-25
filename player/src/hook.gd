extends Node2D
class_name Hook

# refs
onready var pb: KinematicBody2D = get_node("%Body")
onready var p: Player = get_node("../..")

var hooking: bool = false
var shooting: bool = false
var retracting: bool = false
var connected: bool = false

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
	if connected or shooting:
		draw_hook()


func shoot_hook():
	# init
	var new_target: Vector2
	if not shooting:
		dir = p.mouse_direction
		shooting = true
		hooking = true
		retracting = false
		
		ray_cast = RayCast2D.new()
		ray_cast.enabled = true
		new_target = dir * 1.5 * p.physical_size;
		add_child(ray_cast)
	elif shooting and not retracting:
		new_target = ray_cast.cast_to + dir * p.hook_fire_speed
		if new_target.length() > p.hook_length:
			new_target = dir * p.hook_length
			retracting = true
	elif retracting:
		new_target = ray_cast.cast_to - dir * (p.hook_fire_speed / 1)
		if new_target.length() < 100:
			ray_cast.enabled = false
			shooting = false
	ray_cast.cast_to = new_target
	target_pos = p.position + ray_cast.cast_to
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
	
	if not target_node is Cube:
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
	if target_node is Cube:
		var cube = target_node
		var distance = (pb.position - cube.position).length()
		
		if(distance > p.physical_size * 3.5):
			var hook_accel = p.hook_drag_acceleration * (distance / p.hook_length)
			var drag_speed = p.hook_drag_speed * 128

			# add force to the hooked player
			var tmp: Vector2
			tmp = hook_accel * pull_dir * 1.5 * 128
			tmp.x = clamp(tmp.x, -drag_speed, drag_speed)
			tmp.y = clamp(tmp.y, -drag_speed, drag_speed)
			cube.velocity -= tmp

			# add a little bit force to the guy who has the grip
			tmp /= 6
			tmp.x = clamp(tmp.x, -drag_speed, drag_speed)
			tmp.y = clamp(tmp.y, -drag_speed, drag_speed)
			p.velocity += tmp

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
