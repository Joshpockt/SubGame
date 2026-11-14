extends Node

const FIRST_NAMES = [
	"Andrew",
	"Bob",
	"Betty",
	"Charles",
	"Donald",
	"Edward",
	"Frank",
	"George",
	"Harold",
	"Helen",
	"Irving",
	"John",
	"James",
	"Kenneth",
	"Lawrence",
	"Melvin",
	"Norman",
	# NOTE: to be continued...
	# Feel free to add your own!
]

const LAST_NAMES = [
	"Adams",
	"Apple",
	"Armstrong",
	"Barber",
	"Bartle",
	"Bart",
	"Beermann",
	"Berry",
	"Bond",
	"Bonner",
	"Brown",
	"Buck",
	"Burtz",
	"Cruze",
	"Cain",
	"Camp",
	"Carey",
	"Carr",
	"Chambers",
	"Clark",
	"Cole",
	"Cosgrove",
	"Hamm",
	"Smith",
	# NOTE: also, to be continued...
	# Feel free to add your own!
]

func get_random_name(s: int) -> Array[String]:
	var rng = RandomNumberGenerator.new()
	rng.seed = s
	return [
		FIRST_NAMES[rng.randi_range(0, FIRST_NAMES.size() -1)],
		LAST_NAMES[rng.randi_range(0, FIRST_NAMES.size() -1)]
		]

func _ready() -> void:
	for i in 1000:
		print(get_random_name(i))
