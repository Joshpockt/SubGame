extends Node3D

@onready var interactor: InteractionBox3D = $Interactor
@onready var waterfx: GPUParticles3D = $waterfx
@onready var hole: MeshInstance3D = $hole
@onready var interaction_collider: CollisionShape3D = $Interactor/InteractionCollider

var holding=false
@export var PatchTime=3.0;
var patchProgress=0.0

@rpc("any_peer","call_local","reliable")
func destroy():
	hole.hide()
	waterfx.emitting=false
	interaction_collider.disabled=true
	await get_tree().create_timer(1.5).timeout
	queue_free()


func _ready() -> void:
	interactor.hovered.connect(func():
		holding=true)
	interactor.hoveredEND.connect(func():
		holding=false)
		
func _process(delta: float) -> void:
	
	if holding && Input.is_action_pressed("interact"):
		interactor.Progress=patchProgress/PatchTime
		patchProgress+=delta
	else:
		patchProgress=0
		interactor.Progress=1.0
	if patchProgress >= PatchTime:
		patchProgress=0
		rpc("destroy")
