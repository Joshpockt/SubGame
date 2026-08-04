extends Node3D

@onready var interactor: InteractionBox3D = $Interactor
@export var roomManager:Node

var grabProgress=0.0
@export var GrabTime=3.0;
@export var CoalGiven=5;

var isGrabbing=false

var hovering=false

func _process(delta: float) -> void:
	isGrabbing=hovering && Input.is_action_pressed("interact") && roomManager.localplayer.coalHolding==0
	if isGrabbing:
		grabProgress+=delta
		interactor.Progress = grabProgress/GrabTime
		if grabProgress > GrabTime:
			roomManager.localplayer.coalHolding=CoalGiven
	else:
		grabProgress=0.0
		interactor.Progress=1.0
	interactor.get_child(0).disabled=!roomManager.localplayer.coalHolding==0
func _ready() -> void:
	interactor.hovered.connect(func(): 
		hovering=true)
	interactor.hoveredEND.connect(func(): 
		hovering=false)
