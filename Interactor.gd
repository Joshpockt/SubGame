extends RayCast3D
var last=null
var circleLerp=.2
var hollowLerp=0.0
var ProgressLerp=1.0
var lerpSpeed=13
@onready var mover: CharacterBody3D = $"../../../Mover"

@onready var circle: ColorRect = $"../../../UI/Crosshair/circle"

@onready var syncronizer: MultiplayerSynchronizer = $"../../../Syncronizer"



func _ready() -> void:
	await get_tree().process_frame
	if !syncronizer.is_multiplayer_authority():
		set_process(false)
		

func _process(delta: float) -> void:
	circle.material.set_shader_parameter("circleSize", circleLerp)
	circle.material.set_shader_parameter("hollowSize", hollowLerp)
	circle.material.set_shader_parameter("progress", ProgressLerp)
	var area = get_collider()
	if (area is InteractionBox3D) && !mover.tabout:
		circleLerp=lerp(circleLerp,.4,lerpSpeed*delta)
		hollowLerp=lerp(hollowLerp,.25,lerpSpeed*delta)
		ProgressLerp=area.Progress
		area.hover()
		last=area
		if Input.is_action_just_pressed("interact"):
			area.interact()
	elif last != null:
		last.hoverEND()
		last=null;
	else:
		circleLerp=lerp(circleLerp,.2,lerpSpeed*delta)
		hollowLerp=lerp(hollowLerp,0.0,lerpSpeed*delta)
		ProgressLerp=lerp(ProgressLerp,1.0,lerpSpeed*delta)
