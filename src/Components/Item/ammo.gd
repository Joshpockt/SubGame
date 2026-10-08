extends Item
class_name AmmoItem

enum AmmunitionType {
	NONE,
	TORPEDO,
}

@export var ammunition_type : AmmunitionType = AmmunitionType.NONE
@export var ammo_count : int = 1
