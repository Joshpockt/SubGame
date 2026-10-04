extends Node3D

#var a = 0.0
#var t := 0.0
#func _process(delta: float) -> void:
	#t += delta * (0.5 + a)
	##a += 0.0001
	#
	#position.y = sin(t * 2) + 1
	#position.x = -sin(t) * 3
	#position.z = -cos(t) * 3

#var t = 0.0
#func _process(delta: float) -> void:
	#position.y = 1
	#
	#t += delta * 0.25
	#
	#if int(t) % 2 == 1:
		#position.x = -3
	#else:
		#position.x = 3

#var t = 0.0
#var rng := RandomNumberGenerator.new()
#
#func _process(delta: float) -> void:
	#t += delta * 0.3
	#rng.seed = floor(t)
	#var dir = Vector3(
		#rng.randf_range(-1,1),
		#rng.randf_range(-0.3,0.3),
		#rng.randf_range(-1,1),
	#).normalized() * 3
	#position = dir + Vector3.UP
