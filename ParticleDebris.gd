extends Node

func AddParticle(p:GPUParticles3D,_time:float,deathLocation):
	p.reparent(deathLocation)
	p.emitting=false
	await get_tree().create_timer(_time).timeout
	p.queue_free()
