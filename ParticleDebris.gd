extends Node

func SpawnParticle(path:String,_time:float,deathLocation:Node,pos:Vector3):
	var p = load(path).instantiate()
	deathLocation.add_child(p)
	p.global_position=pos
	p.emitting=true
	await get_tree().create_timer(_time).timeout
	p.queue_free()

func AddParticle(p:GPUParticles3D,_time:float,deathLocation:Node):
	p.reparent(deathLocation)
	p.emitting=false
	await get_tree().create_timer(_time).timeout
	p.queue_free()
