@tool
extends Node3D
class_name Gauge

@export_range(0,1) var progress := 0.0

@export var use_decimals := false
@export var max_value := 100:
	set(value):
		max_value = value
		
		# NOTE: need to turn the labels into exports, will throw an error if the line below does not exist.
		if !is_node_ready(): return
		
		if use_decimals:
			label_1.text = str(float(0.0))
			label_2.text = str(float(max_value * 0.25))
			label_3.text = str(float(max_value * 0.5))
			label_4.text = str(float(max_value * 0.75))
			label_5.text = str(float(max_value))
		else:
			label_1.text = str(int(0.0))
			label_2.text = str(int(max_value * 0.25))
			label_3.text = str(int(max_value * 0.5))
			label_4.text = str(int(max_value * 0.75))
			label_5.text = str(int(max_value))

@export_range(0,1) var needle_range := 0.6:
	set(value):
		needle_range = value
		
		# NOTE: need to turn the labels into exports, will throw an error if the line below does not exist.
		if !is_node_ready(): return
		
		label_1.position.x = sin(needle_range * PI) * 0.07
		label_1.position.y = cos(needle_range * PI) * 0.07
		
		label_2.position.x = sin(needle_range * PI * 0.5) * 0.07
		label_2.position.y = cos(needle_range * PI * 0.5) * 0.07
		
		label_3.position.y = 0.07
		
		label_4.position.x = sin(-needle_range * PI * 0.5) * 0.07
		label_4.position.y = cos(-needle_range * PI * 0.5) * 0.07
		
		label_5.position.x = sin(-needle_range * PI) * 0.07
		label_5.position.y = cos(-needle_range * PI) * 0.07

@export var lerp_speed := 10.0

#@export_range(0,1) var needle_shake_start := 1.0
#@export_range(0,1) var needle_shake_fade_in := 0.0

@onready var needle_pivot: Node3D = $NeedlePivot

@onready var label_1: Label3D = $Label1
@onready var label_2: Label3D = $Label2
@onready var label_3: Label3D = $Label3
@onready var label_4: Label3D = $Label4
@onready var label_5: Label3D = $Label5

func _ready() -> void:
	max_value = max_value

var t := 0.0
func _process(delta: float) -> void:
	t += delta
	#var shake_weight : float = clamp(remap(progress, needle_shake_start, needle_shake_start + needle_shake_fade_in, 0.0, 1.0), 0.0, 1.0)
	#var shake = cos(t * 60) * PI * 0.05
	#shake *= shake_weight
	
	var rot = (((progress * 2) - 1) * PI * needle_range)# + (shake * 1)
	needle_pivot.rotation.z = lerp(needle_pivot.rotation.z, rot, lerp_speed * delta)


# NOTE: Shamelessly stolen from this talk by freya holmer ;-;
# https://www.youtube.com/watch?v=LSNQuFEDOyQ
func decay_lerp(a: float, b: float, decay: float, delta: float):
	return b + (a - b) * exp(-decay * delta)
	
	# NOTE: This shit dont work...
	# I mean its does, it just like nans everything lol.
	# i might try and get it to work later.
