extends CanvasLayer

var dropped_passenger: Passenger
var passenger_queue = []
var passenger_groups = []
var left_seats = []
var right_seats = []
var front_seats = []

@export var num_seats = 8
@export var num_seats_front = 1
@onready var passengers = $WorldControl/Passengers
@onready var score_value_label = $Interface/MarginContainer/HBoxContainer/ScoreValueLabel
var score = 0

static var PASSENGER_QUEUE_OFFSET = 80

#adjacency tags
enum passenger_personality {NEUTRAL, INTROVERT, SOCIAL}
enum passenger_location {ANYWHERE, FRONT, BACK, LAST}

var passenger_type = {
	"couple":{
		"personality" : passenger_personality.NEUTRAL,
		"location" : passenger_location.ANYWHERE,
		"profit": 20,
		"number of stops" : 2,
		"min count": 2,
		"max count": 2
	},
	"group":{
		"personality" : passenger_personality.NEUTRAL,
		"location" : passenger_location.ANYWHERE,
		"profit": 20,
		"number of stops" : 2,
		"min count": 3,
		"max count": 4
	},
	"quick":{
		"personality" : passenger_personality.NEUTRAL,
		"location" : passenger_location.ANYWHERE,
		"profit": 5,
		"number of stops" : 1,
		"min count": 1,
		"max count": 1
	},
	"slow":{
		"personality" : passenger_personality.NEUTRAL,
		"location" : passenger_location.ANYWHERE,
		"profit": 20,
		"number of stops" : 3,
		"min count": 1,
		"max count": 1
	},
	"introvert":{
		"personality" : passenger_personality.INTROVERT,
		"location" : passenger_location.ANYWHERE,
		"profit": 20,
		"number of stops" : 2,
		"min count": 1,
		"max count": 1
	},
	"social":{
		"personality" : passenger_personality.SOCIAL,
		"location" : passenger_location.ANYWHERE,
		"profit": 20,
		"number of stops" : 2,
		"min count": 1,
		"max count": 1
	},
	"shotgun":{
		"personality" : passenger_personality.NEUTRAL,
		"location" : passenger_location.FRONT,
		"profit": 10,
		"number of stops" : 2,
		"min count": 1,
		"max count": 1
	},
	"elderly":{
		"personality" : passenger_personality.NEUTRAL,
		"location" : passenger_location.LAST,
		"profit": 10,
		"number of stops" : 2,
		"min count": 1,
		"max count": 1
	},
	"wife":{
		"personality" : passenger_personality.NEUTRAL,
		"location" : passenger_location.FRONT,
		"profit": 10,
		"number of stops" : 2,
		"min count": 1,
		"max count": 1
	}
}

func clear_passengers():
	for p in passenger_queue:
		if not p.is_seated:
			p.queue_free()
	passenger_queue.clear()

func populate_passengers(p_count):
	for i in p_count:
		spawn_passenger(passenger_type.keys()[ randi() % passenger_type.size() ]) 

func spawn_passenger(p):
	print(p)
	var g = []
	var j = randi_range(passenger_type[p]["min count"],passenger_type[p]["max count"])
	for i in range(0,j,1):
		var passenger_scene = load("res://passenger.tscn")
		var passenger = passenger_scene.instantiate()
		passengers.add_child(passenger)
		
		#set passenger attributes
		passenger.global_position = passengers.global_position - Vector2(PASSENGER_QUEUE_OFFSET * passenger_queue.size(),0)
		passenger.original_position = passenger.position
		passenger_queue.append(passenger)
		passenger.label.text = p
		passenger.personality = passenger_type[p]["personality"]
		passenger.location = passenger_type[p]["location"]
		passenger.profit = passenger_type[p]["profit"]
		passenger.number_of_stops = passenger_type[p]["number of stops"]
		g.append(passenger)
	
	if g.size() > 1:
		print("added to passenger group")
		passenger_groups.append(g)
	
	return j

func next_station():
	#change bg
	#repop passengers
	update_seats()
	clear_passengers()
	populate_passengers(4)
	#update score
	pass

func update_seats():
	for s in left_seats:
		s.on_next_station()
			

func update_score(s):
	score_value_label.text = str(score + s)

func game_over():
	pass

func _ready():
#	#test
#	var passenger: Passenger = $WorldControl/Passengers/Passenger
#	var passenger2: Passenger = $WorldControl/Passengers/Passenger2
#	#var passenger3: Passenger = $WorldControl/Passengers/Passenger3
#	var passenger4: Passenger = $WorldControl/Passengers/Passenger4
#
#	passenger.add_to_new_passenger_group()
#	passenger2.add_to_passenger_group(0)
#	#passenger3.add_to_passenger_group(0)
#
#	passenger4.location = passenger_location.LAST
	populate_passengers(4)


func _on_button_pressed():
	next_station()
