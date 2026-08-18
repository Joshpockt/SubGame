extends Node
class_name Game

#HACK: these should be loaded dynamically
@onready var exterior_world: Node = $ExteriorViewport/ExteriorWorld
@onready var sub_interior: SubInterior = $SubInterior
#@onready var sub_exterior: Submarine = $ExteriorViewport/ExteriorWorld/SubExterior

static var front_viewport : ViewportTexture

func _ready() -> void:
	pass
	#front_viewport = sub_exterior.front_viewport
