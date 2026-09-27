extends Resource
class_name Item

@export var name := ""
@export var fuel_seconds := 0.0

func get_uid() -> String:
	return ResourceUID.path_to_uid(resource_path)

# in the future
#
# export model
# export animation set
# ect.
