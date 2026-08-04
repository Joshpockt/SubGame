extends Node3D



func ParascopeInteraction():
	pass


# Called when the node enters the scene tree for the first time.
func _ready() -> void:
	$Parascope/Interactor.interacted.connect(ParascopeInteraction)


# Called every frame. 'delta' is the elapsed time since the previous frame.
func _process(delta: float) -> void:
	pass
