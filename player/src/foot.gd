extends Sprite

onready var p: Player = get_node("../..")

func _process(delta):
	update()

func _draw():
	if p.has_double_jump:
		modulate = Color(1, 1, 1)
	else:
		modulate = Color(0.5, 0.5, 0.5)