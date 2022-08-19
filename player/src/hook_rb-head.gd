extends Node2D
class_name Hook2

# refs
onready var physicalBody: KinematicBody2D = get_node("%Body")
onready var p: Player = get_node("../..")

var hooking: bool = false
var connected: bool = false
var connectionPos: Vector2
var connectionNode: Node

var head: RigidBody2D
var headCollision: CollisionShape2D
var anchor: StaticBody2D
var joint: DampedSpringJoint2D
var dir: Vector2

onready var ray_cast: RayCast2D

# clean up vars
var remove_anchor: bool = false
var remove_joint: bool = false
var remove_head: bool = false

func _physics_process(delta):
	if p.hook and not hooking:
		shoot_hook()
	elif not p.hook and hooking:
		unhook()
	elif connected:
		# pull_by_interpolation()
		# pull_by_joint()
		pull_by_tw()

func _process(delta):
	update()


func _draw():
	if connected:
		draw_hook()


func shoot_hook():
	hooking = true
	dir = p.mouse_direction
	
	ray_cast = RayCast2D.new()
	ray_cast.cast_to = dir * 380*2
	ray_cast.position = p.position
	ray_cast.enabled = true
	add_child(ray_cast)
	
	
	
	# new_head()
	# var impulse = dir * p.hook_impulse
	# head.apply_impulse(Vector2.ZERO, impulse)


func unhook():
	remove_childs()
	hooking = false
	connected = false
	connectionNode = null


func new_head():
	remove_head = true
	
	head = RigidBody2D.new()
	head.position = p.position + dir * 100
	#head.linear_velocity = p.velocity
	head.name = "HookHead"
	
	head.continuous_cd = true     # otherwise glitches through walls
	head.contact_monitor = true   # used for hit detection
	head.contacts_reported = 5
	
	headCollision = CollisionShape2D.new()
	headCollision.shape = CircleShape2D.new()

	head.connect("body_entered", self, "set_collision_point")
	head.add_child(headCollision)
	add_child((head))


func set_collision_point(node: Node):
	if hooking and not connected:
		connected = true
		connectionPos = head.position

		if node.is_in_group("TileMap"):
			connectionNode = anchor_in_tilemap()
		else:
			connectionNode = node

		remove_child(head)
		remove_head = false


func pull_by_interpolation():
	var hook_length = (p.position - connectionNode.position).length()
	var pull_dir = (connectionNode.position - p.position).normalized()
	
	var hook_drag_speed = 1500 * pull_dir
	var hook_vel = pull_dir * hook_length

	var new_vel = p.velocity + hook_vel;
	
	if(new_vel.length() < hook_drag_speed.length()): # or new_vel.length() < p.velocity.length()):
		p.velocity = lerp(p.velocity, new_vel, p.hook_acceleration)
	#vel.x = lerp(vel.x, pull_dir.x * hook_length, p.hook_acceleration)
	#vel.y = lerp(vel.y, pull_dir.y * hook_length, p.hook_acceleration)


func pull_by_tw():
	var hook_drag_accel = 300
	var hook_drag_speed = 1500
	var pull_dir = (connectionNode.position - p.position).normalized()
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


func pull_by_joint():
	# TODO: check if hookable... 
	if not remove_joint:
		remove_joint = true

		joint = DampedSpringJoint2D.new()
		
		if connectionNode.is_in_group("TileMap"):
			connectionNode = anchor_in_tilemap()
			#connectionNode = get_node("%Anchor")

		joint.position = connectionNode.position
		joint.node_a = connectionNode.get_path()
		joint.node_b = physicalBody.get_path()
		joint.rest_length = 10
		
		joint.length = (connectionNode.position - physicalBody.position).length()
		
		joint.length = connectionNode.position.distance_to(physicalBody.position)
		joint.rotation = Vector2.UP.angle_to(connectionNode.position - physicalBody.position)

		joint.name = "Joint"
		add_child(joint)


func anchor_in_tilemap() -> StaticBody2D:
	remove_anchor = true
	anchor = StaticBody2D.new()
	anchor.position = connectionPos
	anchor.name = "Anchor"
	
	var col = CollisionShape2D.new()
	col.shape = CircleShape2D.new()
	col.shape.radius = 20
	col.disabled = true
	anchor.add_child(col)
	
	add_child(anchor)
	return anchor


func remove_childs():
	if remove_anchor:
		remove_child(anchor)
		remove_anchor = false
	if remove_joint:
		remove_child(joint)
		remove_joint = false
	if remove_head:
		remove_child(head)
		remove_head = false
	remove_child(ray_cast)

func draw_hook() -> void:
	draw_line(p.position, connectionNode.position, Color(0.5, 0.5, 0.5), 5)
