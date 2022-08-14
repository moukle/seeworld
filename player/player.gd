extends Node2D

onready var physicalPlayer = $Physics/Body

func _ready():
	pass


func _process(delta):
	set_position(physicalPlayer.position)
